# UI/UX Pro Max — Design Intelligence Skill

AI-powered design system generation with 161 industry-specific reasoning rules, 67 UI styles, 161 color palettes, 57 font pairings, 99 UX guidelines, 25 chart types, and 15 tech stack guides. Includes a BM25 search engine for intelligent recommendations.

> **Source:** [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) v2.5.0  
> **License:** MIT

## When to Use

Activate this skill when the task involves **UI structure, visual design decisions, interaction patterns, or user experience quality control**.

### Must Use
- Designing new pages (landing, dashboard, admin, SaaS, mobile app)
- Creating or refactoring UI components (buttons, modals, forms, tables, charts)
- Choosing color schemes, typography, spacing, or layout systems
- Reviewing UI code for UX, accessibility, or visual consistency
- Implementing navigation, animations, or responsive behavior
- Making product-level design decisions (style, hierarchy, brand expression)

### Skip
- Pure backend logic, API/database design, infrastructure, DevOps
- Performance optimization unrelated to the interface
- Non-visual scripts or automation tasks

## Prerequisites

Python 3.x must be installed. Verify with:
```bash
python3 --version || python --version
```

## How to Use

### Step 1: Generate a Design System (RECOMMENDED START)

Run the design system generator to get a complete recommendation tailored to your product:

```bash
python3 SKILL_DIR/scripts/search.py "<product_type> <industry> <keywords>" --design-system -p "ProjectName"
```

This runs 5 parallel searches (product, style, color, landing, typography), applies reasoning rules, and returns: pattern + style + colors + typography + effects + anti-patterns + checklist.

**Examples:**
```bash
python3 SKILL_DIR/scripts/search.py "beauty spa wellness service" --design-system -p "Serenity Spa"
python3 SKILL_DIR/scripts/search.py "fintech banking dark theme" --design-system -p "NeoBank"
python3 SKILL_DIR/scripts/search.py "SaaS dashboard analytics" --design-system -p "DataFlow"
python3 SKILL_DIR/scripts/search.py "e-commerce luxury fashion" --design-system -p "LuxeStore"
```

**Output formats:**
```bash
# ASCII box (default, best for terminal)
python3 SKILL_DIR/scripts/search.py "fintech crypto" --design-system

# Markdown (best for docs/files)
python3 SKILL_DIR/scripts/search.py "fintech crypto" --design-system -f markdown
```

### Step 2: Persist Design System (Master + Overrides)

Save the design system for cross-session retrieval:

```bash
# Save to design-system/<project>/MASTER.md
python3 SKILL_DIR/scripts/search.py "SaaS dashboard" --design-system --persist -p "MyApp"

# Also create page-specific override
python3 SKILL_DIR/scripts/search.py "SaaS dashboard" --design-system --persist -p "MyApp" --page "dashboard"
```

Creates:
```
design-system/<project>/
├── MASTER.md           # Global Source of Truth
└── pages/
    └── dashboard.md    # Page-specific overrides (deviations from Master)
```

**Usage pattern:** When building a page, check `design-system/<project>/pages/<page>.md` first. If it exists, its rules override MASTER.md.

### Step 3: Domain-Specific Searches

Deep-dive into specific domains:

```bash
python3 SKILL_DIR/scripts/search.py "<keyword>" --domain <domain> [-n <max_results>]
```

| Domain | Use For | Example |
|--------|---------|---------|
| `style` | UI styles, effects | `--domain style "glassmorphism dark"` |
| `color` | Color palettes by product | `--domain color "healthcare calming"` |
| `typography` | Font pairings | `--domain typography "elegant serif"` |
| `google-fonts` | Individual font lookup | `--domain google-fonts "sans serif variable"` |
| `product` | Product type patterns | `--domain product "SaaS dashboard"` |
| `landing` | Page structure, CTAs | `--domain landing "hero social-proof"` |
| `chart` | Chart type recommendations | `--domain chart "real-time dashboard"` |
| `ux` | Best practices, anti-patterns | `--domain ux "animation accessibility"` |
| `react` | React/Next.js performance | `--domain react "memo suspense bundle"` |
| `web` | App interface (iOS/Android) | `--domain web "touch targets safe areas"` |
| `icons` | Icon libraries, usage | `--domain icons "navigation settings"` |

### Step 4: Stack-Specific Guidelines

Get implementation best practices for your framework:

```bash
python3 SKILL_DIR/scripts/search.py "<keyword>" --stack <stack>
```

**Available stacks:** `react`, `nextjs`, `vue`, `nuxtjs`, `nuxt-ui`, `svelte`, `astro`, `angular`, `html-tailwind`, `shadcn`, `laravel`, `swiftui`, `react-native`, `flutter`, `jetpack-compose`, `threejs`

---

## Quick Reference (Critical Rules)

### 1. Accessibility (CRITICAL)
- **Contrast:** Minimum 4.5:1 for normal text (3:1 for large text)
- **Focus states:** Visible focus rings on all interactive elements (2–4px)
- **Keyboard nav:** Tab order matches visual order; full keyboard support
- **Alt text:** Descriptive alt text for meaningful images
- **Aria labels:** `aria-label` for icon-only buttons
- **Reduced motion:** Respect `prefers-reduced-motion`
- **Dynamic type:** Support system text scaling

### 2. Touch & Interaction (CRITICAL)
- **Touch targets:** Minimum 44×44px (Apple) / 48×48dp (Material)
- **Touch spacing:** Minimum 8px gap between targets
- **Hover vs tap:** Use click/tap for primary interactions; don't rely on hover alone
- **Cursor pointer:** Add `cursor-pointer` to all clickable elements
- **Loading feedback:** Disable button during async; show spinner

### 3. Performance (HIGH)
- **Images:** WebP/AVIF, responsive srcset, lazy loading
- **CLS:** Reserve space for async content (CLS < 0.1)
- **Fonts:** `font-display: swap`; preload critical fonts only
- **Lists:** Virtualize 50+ items
- **Skeleton screens:** Use shimmer for >1s operations

### 4. Style Selection (HIGH)
- **Consistency:** Same style across all pages
- **No emoji icons:** Use SVG (Heroicons, Lucide)
- **Elevation:** Consistent shadow scale
- **Dark mode:** Design light/dark together

### 5. Layout & Responsive (HIGH)
- **Mobile-first:** Design mobile, scale up
- **Breakpoints:** 375 / 768 / 1024 / 1440
- **Font size:** Minimum 16px body on mobile
- **No horizontal scroll:** Content fits viewport

### 6. Typography & Color (MEDIUM)
- **Line height:** 1.5–1.75 for body text
- **Line length:** 65–75 chars per line
- **Semantic tokens:** Use `--color-primary` not raw hex

### 7. Animation (MEDIUM)
- **Duration:** 150–300ms for micro-interactions
- **Transform only:** Animate transform/opacity, not width/height
- **Easing:** ease-out for entering, ease-in for exiting
- **Exit faster:** ~60–70% of enter duration

---

## Pre-Delivery Checklist

Before delivering UI code, verify:

- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] `cursor-pointer` on all clickable elements
- [ ] Hover states with smooth transitions (150–300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard navigation
- [ ] `prefers-reduced-motion` respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px
- [ ] No content hidden behind fixed navbars
- [ ] No horizontal scroll on mobile
- [ ] All touch targets ≥ 44px

---

## Architecture

```
ui-ux-pro-max/
├── SKILL.md              # This file
├── scripts/
│   ├── core.py           # BM25 search engine + CSV loader
│   ├── search.py         # CLI entry point
│   └── design_system.py  # Design system generator + formatter
└── data/
    ├── styles.csv        # 67 UI styles with effects, colors, checklist
    ├── colors.csv        # 161 industry-specific color palettes
    ├── typography.csv    # 57 font pairings with Google Fonts URLs
    ├── products.csv      # 161 product types with style recommendations
    ├── ui-reasoning.csv  # 161 reasoning rules (pattern + style + color + anti-patterns)
    ├── landing.csv       # Landing page patterns
    ├── charts.csv        # 25 chart types
    ├── ux-guidelines.csv # 99 UX best practices
    ├── google-fonts.csv  # Google Fonts database
    ├── icons.csv         # Icon library reference
    ├── react-performance.csv  # React/Next.js performance
    ├── app-interface.csv      # iOS/Android/React Native guidelines
    ├── styles.csv        # Style implementation details
    └── stacks/           # 15 tech stack guides
        ├── react.csv
        ├── nextjs.csv
        ├── vue.csv
        ├── html-tailwind.csv
        ├── shadcn.csv
        └── ... (16 stacks total)
```

Replace `SKILL_DIR` in commands with the actual path to this skill directory.
