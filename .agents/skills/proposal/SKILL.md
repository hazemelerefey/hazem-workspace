---
name: proposal
description: "Generate professional freelance proposals in Egyptian formal Arabic for client projects"
---

# Proposal Writer

When triggered with `/proposal`, generate a professional freelance proposal in Egyptian formal Arabic (formal slang — baladi but polished).

## User Identity

Ask the user ONCE for their name and job title. Store for all future proposals in this session.

## Workflow

1. Ask the user for:
   - **Client name** (اسم العميل)
   - **Project description** (وصف المشروع — what the client needs)
   - **Country** (البلد — if relevant for documents/requirements)
   - **Do you have a sample/previous work?** (عندك شغل سابق أو عينه تقدر توريها للعميل؟) — YES or NO

2. Read the project description and decide: is it a **simple task** or a **complex project**?

3. Generate the proposal based on complexity:

### Simple Task (CV, data entry, account creation, basic work)

- Greeting: السلام عليكم أستاذ [اسم العميل]
- Self-intro: أنا [الاسم], [المسمى الوظيفي]
- Go straight to: حابب اوضحلك ايه اللي هيتم بالظبط
- Steps (numbered ١. ٢. ٣.)
- What's needed from client (numbered)
- Brief notes
- If user has a sample: add line like "هسيبلك عينه من [النوع] عشان تشوف النتيجة مبدأيا هتبقى ازاي"
- If user has NO sample: skip this line entirely
- NO experience mention, NO "بخصوص.getProject", NO final signature

### Complex Project (automation systems, full integrations, technical builds)

- Greeting: السلام عليكم أستاذ [اسم العميل]
- Self-intro: أنا [الاسم], [المسمى الوظيفي], خبرة أكثر من ٣ سنين في [التخصص]
- Intro: حابب اوضحلك ايه اللي هيتم بالظبط
- Steps (numbered ١. ٢. ٣.)
- What's needed from client (numbered)
- Detailed notes with specific tools/examples
- Closing: في انتظار رد حضرتك
- Signature: [الاسم] only

## Style Rules

- Egyptian formal Arabic — professional but warm, not stiff
- Brief and direct — no fluff, no filler
- Sound human — no AI signatures
- Use Arabic numerals (١, ٢, ٣) not Western (1, 2, 3)
- Use numbered lists (١. ٢. ٣.) with natural spacing — NO bullet symbols, NO dashes (—), NO asterisks
- NO tashkeel/diacritics on any word (no ّ َ ُ ِ etc.)
- NO non-Arabic characters mixed in text (no Chinese, no English embedded in Arabic words)
- EVERY word must be valid Arabic — double-check each word before outputting. If a word looks wrong or unfamiliar, replace it with a simple Arabic alternative
- Avoid made-up or broken Arabic words — use common, simple Egyptian Arabic words everyone understands
- Keep paragraphs short
- Signature: name only — no phone number, no email (not allowed on platforms)
- Do NOT include مدة التنفيذ or قيمة العرض in the proposal body

## حضرتك Usage

- Use "حضرتك" maximum 1-2 times (for initial respect)
- After that: "محتاج منك", "لو عايز", "هنتفق", etc.

## Important Notes Style

- Be realistic and specific — mention actual tools, methods, or examples
- Never use vague language like "أدوات وأساليب متقدمة"
- GOOD: "هيتم استخدام anti-detect browser زي GoLogin أو Multilogin مع proxies مختلفة"
- BAD: "هيتم باستخدام أدوات وأساليب متقدمة"

## Freelancing Platform Fields

When the user needs to submit on a freelancing platform, suggest separately (NOT in the proposal text):
- **مدة التنفيذ:** adjust based on project complexity
- **قيمة العرض:** adjust based on scope

## Recall Command

`/proposal` — triggers this skill to generate a new proposal.
