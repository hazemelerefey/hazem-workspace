---
name: proposal
description: "Generate professional freelance proposals in Egyptian formal Arabic for client projects"
---

# Proposal Writer

When triggered with `/proposal`, generate a professional freelance proposal in Egyptian formal Arabic (formal slang — baladi but polished).

## First Invocation — Collect User Identity

On the FIRST `/proposal` call, ask the user:
"قبل ما نبدأ، محتاج منك اسمك اللي هتقدم بيه على المنصة، والمسمى الوظيفي. ممكن تجيبهم من بروفايلك على المنصة علشان يكونوا متطابقين."

Store the name and job title for all future proposals in this session. Do NOT hardcode any name in the skill.

## Workflow

1. Ask the user for:
   - **Client name** (اسم العميل)
   - **Project description** (وصف المشروع — what the client needs)
   - **Country** (البلد — if relevant for documents/requirements)

2. Generate the proposal with this exact structure:
   - Greeting: السلام عليكم أستاذ [اسم العميل]
   - Self-intro: [الاسم], [المسمى الوظيفي], خبرة أكثر من ٣ سنين في [التخصص]
   - Intro line: بخصوص.getProject دا حابب اوضحلك ايه الليهيتم بالظبط
   - Steps of execution (numbered ١. ٢. ٣.)
   - What's needed from the client (numbered)
   - Important notes (realistic, specific tools/examples — no vague language)
   - Closing: في انتظار رد حضرتك
   - Signature: [الاسم] only (no phone, no email)

3. Output the proposal ready to copy-paste — no markdown headers, no code blocks, just clean text.

## Style Rules

- Egyptian formal Arabic — professional but warm, not stiff
- Brief and direct — no fluff, no filler
- Sound human — no AI signatures, no "أنا هنا لمساعدتك" vibes
- Use Arabic numerals (١, ٢, ٣) not Western (1, 2, 3)
- Use numbered lists (١. ٢. ٣.) with natural spacing — NO bullet symbols, NO dashes (—), NO asterisks
- NO tashkeel/diacritics on any word (no ّ َ ُ ِ etc.)
- Keep paragraphs short
- End with في انتظار رد حضرتك
- Signature: name only — no phone number, no email (not allowed on platforms)
- Do NOT include مدة التنفيذ or قيمة العرض in the proposal body — these have dedicated fields on the freelancing platform

## حضرتك Usage

- Use "حضرتك" maximum 1-2 times in the proposal (for initial respect)
- After that, use casual respectful forms: "محتاج منك", "لو عايز", "هنتفق", etc.
- Do NOT overuse "حضرتك" — it feels stiff and robotic

## Important Notes Style

When writing important notes or caveats:
- Be realistic and specific — mention actual tools, methods, or examples
- Never use vague language like "أدوات وأساليب متقدمة"
- Example of GOOD: "هيتم استخدام anti-detect browser زي GoLogin أو Multilogin مع proxies مختلفة"
- Example of BAD: "هيتم باستخدام أدوات وأساليب متقدمة"

## Smart Tone

Adjust proposal length and detail based on project complexity:
- **Simple projects** (account creation, data entry, basic tasks): Short, direct, minimal detail
- **Complex projects** (automation systems, full integrations, technical builds): Longer, more detailed, professional structure

Read the project description and decide automatically. Do NOT ask the user about this.

## Freelancing Platform Fields

When the user needs to submit on a freelancing platform, suggest separately (NOT in the proposal text):
- **مدة التنفيذ:** adjust based on project complexity
- **قيمة العرض:** adjust based on scope

## Recall Command

`/proposal` — triggers this skill to generate a new proposal.
