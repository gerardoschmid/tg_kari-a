---
name: Jungle Education System
colors:
  surface: '#f7fbf0'
  surface-dim: '#d7dbd2'
  surface-bright: '#f7fbf0'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f5eb'
  surface-container: '#ebefe5'
  surface-container-high: '#e5eadf'
  surface-container-highest: '#e0e4da'
  on-surface: '#181d17'
  on-surface-variant: '#40493d'
  inverse-surface: '#2d322b'
  inverse-on-surface: '#eef2e8'
  outline: '#707a6c'
  outline-variant: '#bfcaba'
  surface-tint: '#1b6d24'
  primary: '#0d631b'
  on-primary: '#ffffff'
  primary-container: '#2e7d32'
  on-primary-container: '#cbffc2'
  inverse-primary: '#88d982'
  secondary: '#705d00'
  on-secondary: '#ffffff'
  secondary-container: '#fcd400'
  on-secondary-container: '#6e5c00'
  tertiary: '#ac101f'
  on-tertiary: '#ffffff'
  tertiary-container: '#cf2f34'
  on-tertiary-container: '#ffeeec'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a3f69c'
  primary-fixed-dim: '#88d982'
  on-primary-fixed: '#002204'
  on-primary-fixed-variant: '#005312'
  secondary-fixed: '#ffe16d'
  secondary-fixed-dim: '#e9c400'
  on-secondary-fixed: '#221b00'
  on-secondary-fixed-variant: '#544600'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ae'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#930015'
  background: '#f7fbf0'
  on-background: '#181d17'
  surface-variant: '#e0e4da'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  karina-text:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  spanish-translation:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 26px
  label-caps:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
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
  unit: 8px
  container-padding: 24px
  card-gap: 16px
  section-margin: 32px
  button-depth: 4px
---

## Brand & Style

The design system is a **Premium Flat/Cartoon** aesthetic that prioritizes gamification, warmth, and cultural preservation. It balances the playful energy of mobile learning apps with a refined, contemporary finish. The emotional response is one of encouragement, vitality, and discovery.

The style leverages **tactile interaction cues**—specifically 3D-effect buttons with thick bottom borders—to make the interface feel physically rewarding to touch. This approach makes the learning process feel like a high-end educational game rather than a static digital textbook.

## Colors

The palette is rooted in a "Jungle Green" that represents growth and the cultural heritage of the Kariña language.

- **Primary (Jungle Green):** Used for headers, progress bars, and successful interaction states.
- **Secondary (Vibrant Gold):** Reserved for rewards, streaks, and "Level Up" moments to create high-value contrast.
- **Tertiary (Coral Red):** High-visibility color for hearts, lives, and error states.
- **Background (Soft Mint/Bone):** A gentle, low-strain canvas that provides better readability than pure white.
- **Text:** High-contrast dark green-blacks are used instead of pure black to maintain the organic, natural feel of the design system.

## Typography

This design system utilizes **Plus Jakarta Sans** for its soft, rounded terminals that complement the "cartoon" style while remaining highly legible. 

A specific hierarchy is established for bilingual content:
1. **Kariña Terms:** Always appear in the `karina-text` style—bold, larger, and primary-colored.
2. **Spanish Translations:** Use the `spanish-translation` style—smaller, regular weight, and often italicized to signify it as a secondary reference.

Headlines use heavy weights (700-800) to ensure the UI feels bold and confident.

## Layout & Spacing

The layout follows a **fluid-to-fixed** model. On mobile, content uses a 24px safe margin to ensure accessibility for younger or older learners. 

- **Grid:** A 4-column grid for mobile and 12-column for desktop.
- **Rhythm:** An 8px base unit drives all padding and margins. 
- **Touch Targets:** All interactive elements maintain a minimum height of 56px to accommodate the large border radii and thick tactile borders.
- **Bilingual Stacking:** Translations should be positioned directly beneath the primary term with 4px of vertical spacing to maintain clear association.

## Elevation & Depth

Depth is conveyed through **Tactile Flat Design** rather than realistic lighting.
- **Surface Layer:** Cards and containers use a subtle, extra-diffused shadow (`0px 4px 12px rgba(46, 125, 50, 0.08)`) to lift them slightly off the Soft Mint background.
- **Interaction Layer:** Buttons do not use traditional shadows. Instead, they use a "3D thick bottom border" (a solid fill color 20% darker than the surface) to create a mechanical, pressable appearance.
- **Active State:** When pressed, the button's Y-offset increases by 2-4px, and the thick bottom border "disappears," simulating a physical press.

## Shapes

The design system uses high-radius geometry to feel friendly and safe. 
- **Standard Cards/Buttons:** 20px radius.
- **Featured Banners:** 24px radius.
- **Chips/Status Labels:** Fully pill-shaped for maximum distinction from buttons.

## Components

### Tactile Buttons
Buttons must have a `4px` solid bottom border. The "Primary" button uses Jungle Green with a darker green base. The "Reward" button uses Gold with a bronze base.

### Lesson Cards
Cards should feature a white background with a subtle border in the primary color (1px, 10% opacity). They should display the Kariña word prominently, followed by the Spanish translation in a muted gray-green.

### Gamified Progress Bar
A thick, rounded track (Jungle Green at 20% opacity) with a solid Jungle Green indicator. The indicator should have a rounded leading edge to maintain the soft aesthetic.

### Match Pairs
In matching exercises, "Active" chips should gain a primary color border and a slight glow, while "Matched" chips should dim to 50% opacity with a checkmark icon.

### Heart/Lives Counter
The Coral Red heart icon should be paired with a bold, large number. On losing a life, the heart should trigger a shake animation and desaturate to gray.