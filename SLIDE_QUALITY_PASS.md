# Slide Quality Pass - First 4 Slides

Date: 2026-05-15

Scope locked to `cs-frontier-iconic`, `cs-1m8`, `cs-a7m1`, `cs-1bm1` in `GnR_deck.html`.

## cs-frontier-iconic

### Plan

Current strengths: full-bleed hero treatment is already in place; the four-line headline structure preserves the core thesis; brand emphasis colors are tuned for contrast against the warm image.

Identified weaknesses: the slide has no explicit GnR mark in the upper-right corner even though the hero-slide convention calls for one; the headline has strong text shadow already, but the block should be capped slightly tighter so it reads as intentional thesis typography rather than a wide paragraph.

Sharpening moves: add a small upper-right GnR mark using the existing blue/gold/rust wordmark treatment; tighten the headline max-width enough to keep the line rhythm deliberate while preserving the existing four-line span structure, copy, colors, and shadows.

Will not touch: hero image generation, image asset, line copy, four-line headline text, full-bleed treatment, entry animation.

### After

Added the missing upper-right GnR mark with the deck's blue/gold/rust treatment and tightened the headline measure from 1180px to 1120px. The full-bleed image, four-line headline text, emphasis colors, quiet-zone placement, and entry animation were preserved.

## cs-1m8

### Plan

Current strengths: 4-stage reveal is intact; the wordmark, caption columns, contact card, and dated alignment comments are preserved; right caption translateX(86px) carries Dave's latest visual-center correction.

Identified weaknesses: the caption typography uses darker ad hoc blue/red variants (`#3a73b8`, `#c94d32`) in label positions where the design system wants exact brand blue/rust; the stage container can use a little more vertical breathing room without changing the animation mechanics; contact card contrast is acceptable but slightly quiet.

Sharpening moves: tune caption label colors back to exact brand colors while preserving inline content and transforms; give the stage stack a modest vertical balance adjustment only if it does not disturb the 4-stage reveal; lift contact-card readability a notch by increasing the email underline contrast and body opacity.

Will not touch: the 4-stage click reveal, `cs1m8Advance`, `cs1m8Reverse`, wordmark span structure, caption text, contact card content, right-caption `translateX(86px)`, dated comments, or any JS controller.

### After

Normalized the two caption labels to exact brand blue `#5B8FD4` and rust `#c8462c`, while preserving the wordmark, caption copy, staged reveal, and right-caption `translateX(86px)`. Increased the contact card's supporting text/email contrast slightly without changing content or placement.

## cs-a7m1

### Plan

Current strengths: the stacked comparison now reads problem-to-vision; both cards are flippable; Dave's restored 3-stick-figure SVG and newer entry animation sequence are intact.

Identified weaknesses: the right card's dashed ring is still quieter than the left orb's dashed border at presentation scale; the back captions can carry slightly stronger contrast without changing their wording; the card vertical rhythm is close but the two-card gap can be tightened a touch so the slide reads as one comparison unit.

Sharpening moves: boost the right dashed ring opacity/stroke very slightly; align the left orb dashed border visibility to the same system; raise caption contrast through CSS weight/shadow-free color tuning; reduce the stacked card gap slightly while preserving both flip faces and all animation selectors.

Will not touch: both flippable card structures, front/back content, restored 3-stick-figure SVG, stacked-envelope SVG, `data-flipped` behavior, entry animation timing, or deleted-content comments.

### After

Tightened the stacked-card gap from 28px to 24px, strengthened the dashed ring language on both cards, and slightly increased caption weight/line rhythm for readability. Preserved both flip-card structures, the restored 3-stick-figure SVG, the stacked-envelope back face, and the newer staggered entry animation sequence.

## cs-1bm1

### Plan

Current strengths: both chart cards preserve the full visual argument; the double-arrow bridge and independent card flipping are intact; dated comments capture the bar-order and placeholder history.

Identified weaknesses: the main headline is a little small for a thesis slide; the gold void labels and question mark can read too quiet next to the filled bars; dashed void tracks have the right behavior but could use more visual punch after flip.

Sharpening moves: increase headline scale slightly and cap its width for cleaner line rhythm; deepen/punch the void-row gold labels and question mark without changing copy; strengthen dashed void tracks by a small opacity/box-shadow adjustment while preserving animation and card flip mechanics.

Will not touch: chart content, logo SVGs, bar widths, bridge, left/right flip interactivity, bottom community icons, dated iteration comments, or `cs1bm1Toggle`.

### After

Raised the thesis headline scale/weight and capped its measure for cleaner line rhythm. Increased the void-row dashed tracks, pulse, question mark, and "real human connection" labels for clearer contrast, and normalized the tech card heading to exact brand blue. Preserved both charts, bar widths, logo SVGs, bridge, click-to-flip behavior, and dated iteration comments.

## Deferred - Needs Dave Decision

None yet.
