---
name: Obsidian Scholar
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#908fa0'
  outline-variant: '#464554'
  surface-tint: '#c0c1ff'
  primary: '#c0c1ff'
  on-primary: '#1000a9'
  primary-container: '#8083ff'
  on-primary-container: '#0d0096'
  inverse-primary: '#494bd6'
  secondary: '#4edea3'
  on-secondary: '#003824'
  secondary-container: '#00a572'
  on-secondary-container: '#00311f'
  tertiary: '#ffb2b7'
  on-tertiary: '#67001b'
  tertiary-container: '#ff516a'
  on-tertiary-container: '#5b0017'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffdadb'
  tertiary-fixed-dim: '#ffb2b7'
  on-tertiary-fixed: '#40000d'
  on-tertiary-fixed-variant: '#92002a'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
    fontFamily: Sora
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Sora
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Sora
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Sora
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 32px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 28px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  container-max: 1200px
  gutter: 20px
---

## Brand & Style
The design system is engineered for high-density micro-learning, prioritizing focus, speed, and intellectual rigor. The brand personality is "Sophisticated Intelligence"—it avoids the gamified, "childish" tropes of traditional EdTech in favor of a sleek, high-performance interface that feels more like a professional developer tool or a premium news terminal.

The aesthetic follows a **Modern Minimalist** approach with **Glassmorphic** accents. The interface relies on deep obsidian layers to create a sense of infinite depth, allowing content cards to float with clarity. Visual noise is aggressively reduced to ensure that the cognitive load remains entirely on the learning material. The emotional response should be one of calm, focused productivity and premium quality.

## Colors
This design system is a **dark-first** palette optimized for OLED displays and reduced eye strain during long study sessions.

- **Primary (Electric Indigo):** Used for primary actions, active progress states, and brand highlights. It provides a high-energy contrast against the dark background.
- **Secondary (Soft Mint):** Reserved for success states, completed milestones, and positive reinforcement.
- **Tertiary (Rose):** Used sparingly for errors, warnings, or destructive actions to maintain a professional tone.
- **Neutrals:** The background is a layered composition of **Obsidian (#020617)** for the base and **Deep Charcoal (#0F172A)** for surface containers. This ensures hierarchical separation without the need for heavy borders.

## Typography
The typography strategy balances character with utility. **Sora** is used for headings to provide a modern, geometric feel that reflects the technical nature of the content. **Inter** is used for all body and UI text to ensure maximum readability at high densities.

Generous line heights (1.6x - 1.8x) are applied to body text to prevent "text-wall" fatigue. For high-density micro-learning, specific focus is placed on `body-lg` to ensure that even complex information feels digestible. Label styles utilize uppercase with tracking to differentiate metadata from core content.

## Layout & Spacing
The design system utilizes a **4px baseline grid** to ensure mathematical harmony across all components. 

The layout follows a **Fluid-Fixed Hybrid** model:
- **Mobile:** A single-column vertical flow with full-bleed cards or 16px side margins. 
- **Desktop/Tablet:** A centralized fixed-width container (1200px) that centers the learning experience to prevent eye-scan fatigue. 
- **Micro-Learning Verticality:** Content is structured into "Full-screen vertical cards" for mobile, mimicking the "Stories" or "Reels" pattern but with high-contrast text blocks. These cards should snap to the viewport height on mobile devices.

## Elevation & Depth
Depth is created through **Tonal Layering** and **Glassmorphism** rather than traditional shadows.

1.  **Level 0 (Base):** Obsidian (#020617).
2.  **Level 1 (Card/Surface):** Deep Charcoal (#0F172A).
3.  **Level 2 (Overlays/Modals):** A semi-transparent blur (Backdrop Filter: 12px) using primary color tints at 5% opacity. This creates the "Glassmorphism" effect for navigation bars and supplemental info panels.
4.  **Interactive States:** Elements lift using a subtle 1px inner-border (stroke) of white at 10% opacity, simulating a "beveled edge" light catch.

## Shapes
Shapes are disciplined and modern. A `0.5rem (8px)` base radius is used for standard components (buttons, inputs), while `1rem (16px)` is reserved for larger content cards. This "Soft" but structured approach maintains a professional tone without feeling overly "bubbly" or playful.

Progress indicators and status tags use a full pill-shape to distinguish them from actionable buttons.

## Components
- **Full-Screen Cards:** The core learning vessel. Use 100vh height on mobile with a consistent 24px padding. Backgrounds should be strictly #0F172A to differentiate from the app shell.
- **Interactive Buttons:** Primary buttons use a solid Electric Indigo fill. Secondary buttons use a "Ghost" style with a 1px Indigo border. No heavy gradients; use subtle transitions on hover.
- **Progress Indicators:** Slim, 4px height linear bars. Use Soft Mint for progress and Electric Indigo for the "current" segment.
- **High-Contrast Text Blocks:** For critical definitions or quotes, use a left-border accent (4px width) of Electric Indigo with a slightly lighter background surface than the base card.
- **Chips/Tags:** Small, low-contrast background (white at 5% opacity) with `label-md` typography.
- **Input Fields:** Obsidian backgrounds with a 1px charcoal border. The border shifts to Electric Indigo on focus. No drop shadows.