---
name: claude-design
description: >
  Apply Anthropic Claude design language (warm cream canvas, coral accent, editorial
  serif/sans split, color-block elevation) to UI work. Use when the user mentions
  Claude style, DESIGN.md, Anthropic look, warm editorial UI, "像 Claude", redesign
  visual language, or runs /claude-design. Source of truth: repo DESIGN.md and
  references/DESIGN.md (from VoltAgent/awesome-design-md claude).
---

# Claude Design Language Skill

You are implementing **Claude / Anthropic marketing + product warmth** for **this Flutter mobile journal app** (time-journal). Do **not** merely swap hex codes. The brand is **cream + coral + dark-navy pacing + literary type**, not "orange SaaS buttons on beige".

## Sources (read before changing UI)

1. Repo root `DESIGN.md` (Claude analysis from awesome-design-md)
2. This skill's `references/DESIGN.md` (same content, skill-local)
3. Optional live reference: https://claude.com / https://www.anthropic.com (cream canvas, coral CTAs, generous type)
4. Collection: https://github.com/VoltAgent/awesome-design-md

## Core trinity (never invent a fourth brand surface)

| Role | Hex | Use |
|------|-----|-----|
| Canvas | `#faf9f5` | Scaffold, page floor |
| Surface card | `#efe9de` | Feature / section cards (darker cream than canvas) |
| Soft surface | `#f5f0e8` | Soft bands, chips background |
| Primary coral | `#cc785c` | Primary CTA, scarce accents only |
| Primary active | `#a9583e` | Pressed primary |
| Ink | `#141413` | Headlines |
| Body | `#3d3d3a` | Running text |
| Muted | `#6c6a64` | Secondary |
| Muted soft | `#8e8b82` | Captions |
| Hairline | `#e6dfd8` | 1px borders (not dark ink lines) |
| Surface dark | `#181715` | Focus immersive / rare dark chrome |
| Accent teal | `#5db8a6` | Sleep secondary only, sparse |

## Typography rules (the part color-only ports miss)

| Role | Font | Weight | Tracking | Mobile size |
|------|------|--------|----------|-------------|
| Display / date / section display | **Cormorant Garamond** (or EB Garamond) | **400–500 never 700** | slight negative | 28–34 date, 20–22 section |
| Titles / UI labels | **Inter** | 500 | 0 | 15–16 |
| Body | **Inter** | 400 | 0 | 14–16, height 1.5–1.55 |
| Caption / chips | **Inter** | 500 | 0 | 12–13 |
| Buttons | **Inter** | 500 | 0 | 14 |

**Do not** use black heavy sans for page titles. **Do not** bold serif to 700.

Flutter: use `google_fonts` — `GoogleFonts.cormorantGaramond` / `GoogleFonts.inter`.

## Elevation philosophy

- **Color-block first, shadow rare.** Depth = canvas vs `surface-card` vs dark, not gray Material elevation.
- Borders = hairline cream, never charcoal.
- Max shadow: `0 1px 3px rgba(20,20,19,0.06)` optional on floating chrome only.
- **No** double thick borders + heavy left color bars + lined paper texture.

## Radius hierarchy

- Buttons / inputs: **8px** (`radiusMd`)
- Content cards: **12px** (`radiusLg`)
- Large sheets / hero: **16px** (`radiusXl`)
- Badges: pill

## Component recipes (mobile journal)

### Page
- Scaffold background: canvas `#faf9f5` (soft gradient to `#f5f0e8` OK)
- No ruled notebook lines
- List padding bottom ≥ 100 for tab bar

### Section / feature card
- Background: **`surface-card` `#efe9de`** OR lifted white `#fffcf7` with hairline — prefer **surface-card** for true Claude feature feel
- Padding: 16–20 horizontal, 14–18 vertical (generous, not cramped)
- Title: Inter 16 w500 **or** Cormorant 20 w500 for editorial sections
- Subtitle: muted 13
- Optional coral 3px vertical marker — thin, soft radius 2

### Primary button
- Fill coral `#cc785c`, white text, h40, radius 8, padding 12×20, weight 500
- No elevation

### Secondary button
- Canvas fill + hairline border + ink text, same height

### Status / badge
- Pill, surface-card or primary-soft bg, caption 12–13 w500
- Coral fill only for "现在" / high-priority status

### Bottom nav
- Canvas/card cream, hairline top
- Selected: soft coral wash `#f3e6df`, icon+label coral w500
- Unselected: muted-soft

### Focus immersive
- Dark surface `#181715`, on-dark cream text — product chrome contrast

### Sleep secondary
- Teal `#5db8a6` only for sleep accents, not primary brand

## Anti-patterns (fix these when you see them)

1. Pure white cards + gray borders (generic Material)
2. Tomato red that's too crimson / saturated vs muted coral
3. Heavy `FontWeight.w700` everywhere
4. Lined paper / scrapbook kitsch (Claude is literary, not stationery sticker)
5. Coral used on every chip, border, and icon (coral is scarce)
6. Cool blue primary
7. Dense 8px-padded cards with dark dividers
8. "Just recolor theme.dart and stop"

## Workflow when invoked

1. Re-read `DESIGN.md` Overview + Do's/Don'ts.
2. State scope: which screens/components.
3. Prefer **structure + type + surface rhythm** changes over hex-only.
4. After UI edits: `flutter analyze` + `flutter test` under `app/`.
5. If packaging: stamped APK to outbox via existing scripts (CI preferred).
6. Update `.memory/SESSION_LOG.md` with what visual systems changed.

## Flutter mapping checklist

- [ ] `AppTheme` tokens match table above
- [ ] `ThemeData.textTheme` uses Cormorant for display/headline, Inter for body
- [ ] `SectionCard` uses surface-card + hairline + soft title weight
- [ ] `PaperBackground` = cream wash only
- [ ] `FilledButton` radius 8, coral, no elev
- [ ] Comparison slot cards: soft cream, hairline, coral only for "now"
- [ ] Date header: serif display
- [ ] Bottom nav: cream + soft selected pill

## Quote for self-check

> "Claude reads like a long-form magazine column rather than a marketing template."  
> Mobile journal should feel **calm editorial tool**, not **productivity dashboard**.
