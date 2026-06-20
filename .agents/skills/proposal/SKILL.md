---
name: proposal
description: "Generate professional freelance proposals in Egyptian formal Arabic for client projects"
---

# Proposal Writer

When triggered with `/proposal`, generate a professional freelance proposal in Egyptian formal Arabic (formal slang — baladi but polished). The proposal is written from Hazem Khaled's perspective.

## Identity

- **Name:** حازم خالد
- **Role:** محلل بيانات
- **Experience:** أكثر من ٣ سنين
- **Expertise:** تحليل البيانات، بناء أنظمة الأتمتة، وكلاء الذكاء الاصطناعي

## Workflow

1. Ask the user for:
   - **Client name** (اسم العميل)
   - **Project description** (وصف المشروع — what the client needs)
   - **Country** (البلد — if relevant for documents/requirements)

2. Generate the proposal with this exact structure:
   - Greeting: السلام عليكم أستاذ [اسم العميل]
   - Self-introduction (identity above)
   - Intro line: بخصوص المشروع دا حابب اوضحلك ايه اللي هيتم بالظبط :
   - Steps of execution (numbered ١. ٢. ٣.)
   - What's needed from the client (numbered)
   - Important notes (realistic, specific tools/examples — no vague language)
   - Closing: في انتظار رد حضرتك
   - Signature: حازم خالد only (no phone, no email)

3. Output the proposal ready to copy-paste — no markdown headers, no code blocks, just clean text.

## Style Rules

- Egyptian formal Arabic — professional but warm, not stiff
- Brief and direct — no fluff, no filler
- Sound human — no AI signatures, no "أنا هنا لمساعدتك" vibes
- Use Arabic numerals (١, ٢, ٣) not Western (1, 2, 3)
- Use numbered lists (١. ٢. ٣.) with natural spacing — NO bullet symbols, NO dashes (—), NO asterisks
- Keep paragraphs short
- End with في انتظار رد حضرتك
- Signature: حازم خالد only — no phone number, no email (not allowed on platforms)
- Do NOT include مدة التنفيذ or قيمة العرض in the proposal body — these have dedicated fields on the freelancing platform

## Important Notes Style

When writing important notes or caveats:
- Be realistic and specific — mention actual tools, methods, or examples
- Never use vague language like "أدوات وأساليب متقدمة"
- Example of GOOD: "هيتم استخدام anti-detect browser زي GoLogin أو Multilogin مع proxies مختلفة"
- Example of BAD: "هيتم باستخدام أدوات وأساليب متقدمة"

## Freelancing Platform Fields

When the user needs to submit on a freelancing platform, suggest separately (NOT in the proposal text):
- **مدة التنفيذ:** adjust based on project complexity
- **قيمة العرض:** adjust based on scope

## Recall Command

`/proposal` — triggers this skill to generate a new proposal.
