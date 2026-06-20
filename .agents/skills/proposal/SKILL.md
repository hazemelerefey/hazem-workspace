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
   - Explain what will be done (step by step, clear and brief)
   - List what's needed from the client (documents, access, info)
   - Important notes/caveats
   - Closing with availability for questions
   - Signature: الاسم + رقم التليفون + الإيميل

3. Output the proposal ready to copy-paste — no markdown headers, no code blocks, just clean text.

## Style Rules

- Egyptian formal Arabic — professional but warm, not stiff
- Brief and direct — no fluff, no filler
- Sound human — no AI signatures, no "أنا هنا لمساعدتك" vibes
- Use Arabic numerals (١, ٢, ٣) not Western (1, 2, 3)
- Use bullet points with dashes (—) for lists
- Keep paragraphs short
- End with في انتظار رد حضرتك

## Freelancing Platform Fields

When the user needs to submit on a freelancing platform, suggest:
- **مدة التنفيذ:** ١٤ يوم (adjust based on project complexity)
- **قيمة العرض:** $300-500 (adjust based on scope)

## Recall Command

`/proposal` — triggers this skill to generate a new proposal.
