export const meta = {
  name: 'implement',
  description: 'planner → implementer → reviewer を順に連携させて実装・修正を行う',
  whenToUse:
    'plugin追加、moduleやflakeの変更、不具合修正など、Nixコードを変更する作業。argsに依頼内容を文字列で渡す。',
  phases: [
    { title: 'Plan', detail: 'plannerが上流とnixpkgsを調べて実装計画を立てる' },
    { title: 'Implement', detail: 'implementerが計画に沿って実装し、検証まで通す' },
    { title: 'Review', detail: 'reviewerが変更を確認する。指摘があればimplementerに差し戻す' },
  ],
}

// reviewerの指摘をimplementerに差し戻す回数の上限。超えたら未解決の指摘を残したまま返す。
const MAX_FIX_ROUNDS = 2

const PLAN_SCHEMA = {
  type: 'object',
  properties: {
    plan: {
      type: 'string',
      description: '計画の全文(目的 / 調査結果 / 手順 / 検証 / リスク)。implementerにそのまま渡す。',
    },
    openQuestions: {
      type: 'array',
      items: { type: 'string' },
      description:
        '依頼者の回答がないと実装を始められない未決事項。妥当な既定値を選んで進められるものは含めず、計画の中に選んだ値と理由を書く。なければ空配列。',
    },
  },
  required: ['plan', 'openQuestions'],
}

const REVIEW_SCHEMA = {
  type: 'object',
  properties: {
    verdict: {
      type: 'string',
      enum: ['approve', 'request_changes'],
      description:
        'request_changesは、マージ前に直すべき指摘が1つでもある場合。なければapprove。',
    },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          location: { type: 'string', description: 'path:line' },
          problem: { type: 'string', description: '何が問題か' },
          impact: { type: 'string', description: 'どういう状況で何が起きるか' },
          verified: {
            type: 'boolean',
            description: '実行して確認したことならtrue、コードを読んだうえでの推測ならfalse',
          },
          blocking: { type: 'boolean', description: 'マージ前に直すべきならtrue' },
        },
        required: ['location', 'problem', 'impact', 'verified', 'blocking'],
      },
    },
    commands: {
      type: 'string',
      description: '実行したコマンドとその結果、確認できなかった範囲',
    },
  },
  required: ['verdict', 'findings', 'commands'],
}

const task = typeof args === 'string' ? args : args?.task
if (!task) {
  throw new Error('argsに依頼内容を文字列で渡してください')
}

const formatFindings = (findings) =>
  findings
    .map(
      (f, i) =>
        `${i + 1}. ${f.location}\n   問題: ${f.problem}\n   影響: ${f.impact}\n   根拠: ${f.verified ? '実行して確認' : 'コードからの推測'}`,
    )
    .join('\n')

const planned = await agent(
  `次の依頼について実装計画を立ててください。

<依頼>
${task}
</依頼>

planには報告の全文を入れてください。このあとimplementerがplanだけを見て実装します。openQuestionsには、依頼者の回答がないと実装を始められないものだけを入れてください。1つでもあると実装には進まず、依頼者への確認に戻ります。`,
  { agentType: 'planner', phase: 'Plan', label: 'plan', schema: PLAN_SCHEMA },
)
if (!planned) {
  throw new Error('plannerが計画を返しませんでした')
}
if (planned.openQuestions.length > 0) {
  log(`未決事項が${planned.openQuestions.length}件あるため、実装に進まず終了します`)
  return {
    status: 'needs_decision',
    plan: planned.plan,
    openQuestions: planned.openQuestions,
  }
}

let implementation = await agent(
  `次の計画に沿って実装し、検証まで完了させてください。コミットはしないでください。

<依頼>
${task}
</依頼>

<計画>
${planned.plan}
</計画>

計画はplannerが上流とnixpkgsを調べて立てたものです。実装中に計画の前提が事実と違うとわかった場合は、事実に合わせて実装し、どこをなぜ変えたかを報告に書いてください。`,
  { agentType: 'implementer', phase: 'Implement', label: 'implement' },
)
if (!implementation) {
  throw new Error('implementerが結果を返しませんでした')
}

let review = null
let fixRounds = 0
for (;;) {
  review = await agent(
    `次の依頼に対する実装をレビューしてください。

<依頼>
${task}
</依頼>

<計画>
${planned.plan}
</計画>

<implementerの報告>
${implementation}
</implementerの報告>

レビュー対象は今回の依頼による変更です。報告にあるファイルを起点にし、\`git status\`で報告から漏れた変更がないかも確認してください。作業ツリーには今回の依頼と無関係な未コミットの変更が含まれている場合があり、それは対象外です。

報告はimplementer自身の申告です。検証が通ったという記述も含めて鵜呑みにせず、自分で実行して確かめてください。計画どおりかどうかではなく、依頼を満たしていて壊れていないかを見てください。${
      fixRounds > 0
        ? `\n\nこれは${fixRounds}回目の差し戻し後の再レビューです。前回の指摘が直っているかに加えて、修正によって新しく壊れた箇所がないかも見てください。`
        : ''
    }`,
    {
      agentType: 'reviewer',
      phase: 'Review',
      label: fixRounds === 0 ? 'review' : `review:${fixRounds + 1}`,
      schema: REVIEW_SCHEMA,
    },
  )
  if (!review) {
    throw new Error('reviewerが結果を返しませんでした')
  }

  const blocking = review.findings.filter((f) => f.blocking)
  if (review.verdict === 'approve' || blocking.length === 0) {
    break
  }
  if (fixRounds >= MAX_FIX_ROUNDS) {
    log(`差し戻しが上限(${MAX_FIX_ROUNDS}回)に達しました。未解決の指摘が${blocking.length}件残っています`)
    break
  }
  fixRounds++
  log(`reviewerの指摘${blocking.length}件をimplementerに差し戻します(${fixRounds}/${MAX_FIX_ROUNDS})`)

  implementation = await agent(
    `あなたが行った実装にreviewerから指摘がありました。指摘を修正し、検証まで完了させてください。コミットはしないでください。

<依頼>
${task}
</依頼>

<計画>
${planned.plan}
</計画>

<前回の報告>
${implementation}
</前回の報告>

<指摘>
${formatFindings(blocking)}
</指摘>

「コードからの推測」とある指摘は、まず実際に問題が起きるかを確かめてください。確かめた結果、指摘が当たっていないとわかった場合は、修正せずにその根拠を報告に書いてください。報告には今回の修正だけでなく、依頼全体に対する変更の全体像を含めてください。`,
    { agentType: 'implementer', phase: 'Implement', label: `fix:${fixRounds}` },
  )
  if (!implementation) {
    throw new Error('implementerが修正結果を返しませんでした')
  }
}

const unresolved = review.findings.filter((f) => f.blocking)
return {
  status: unresolved.length === 0 ? 'approved' : 'changes_remaining',
  fixRounds,
  plan: planned.plan,
  implementation,
  review,
}
