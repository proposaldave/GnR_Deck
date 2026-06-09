# GnR Deck Image Generation Style Kit

Use this when asking ChatGPT to generate or edit bitmap image slides for the Give n Receive deck.

## Paste-Ready Prompt

You are generating a 16:9 image slide or image background for the Give n Receive investor deck.

Design system:
- Warm editorial investor-deck style, not generic SaaS.
- Cream paper base, ink typography, gold/red/blue accents.
- Palette: warm cream #fbf7ef / #f3ead8, ink #1a1612, gold #b8954a, red #c8462c, blue #5B8FD4.
- No green. No blue-purple tech gradients. No generic AI stock-art glow.
- Use watercolor/editorial/cinematic realism, warm light, human community, reciprocity, contribution, measurable connection, real-world clubs, pickleball/community scenes where relevant.
- Keep compositions simple enough for a pitch deck: one clear idea, generous negative space, readable silhouette, no cluttered tiny text.
- Prefer large background scenes with safe blank space for HTML-rendered text.
- Do not bake final slide copy into the image unless I explicitly ask for a flat image-only slide.
- If labels must appear inside the image, keep them minimal, large, and few; avoid paragraphs.
- Avoid distorted logos, fake UI, fake brand marks, unreadable microtext, warped hands/faces, and over-detailed dashboards.
- Match the deck's visual language: warm paper texture, subtle grain, restrained borders, elegant editorial scale, Fraunces/Playfair-like serif energy, Manrope-like uppercase eyebrow energy, gold/red accent logic.

Output requirements:
- 16:9 aspect ratio, ideally 1600x900 or larger.
- Text-free bitmap by default.
- Leave space for top-left eyebrow and large HTML headline when possible.
- If it is a full slide image, keep the composition balanced with no important content under the right-side navigation dots or bottom-right controls.
- Provide 3-6 concept variants when exploring.

Task:
Target slide/story beat: [describe the slide]
Image role: [full-bleed background / side visual / pure image slide / section breaker]
Must show: [specific visual elements]
Must avoid: [specific unwanted elements]
Text handling: render final copy separately in HTML unless this request explicitly asks for a flat image-only slide.

## Fast Prompt Pattern

Create a text-free 16:9 bitmap background for the Give n Receive deck.
Story beat: [human value / reciprocity / measurable connection / real-world community / pickleball silliness / invitation graph].
Style: warm editorial watercolor/cinematic realism, cream paper, ink, gold/red/blue accents, restrained, premium investor deck.
Avoid: green, generic SaaS/AI stock art, blue-purple gradients, fake app UI, dense text, tiny labels, warped logos.
Leave safe blank space for HTML text and keep important visual content away from the right-side nav dots and bottom-right controls.

## Flat Image-Only Slide Pattern

Create a finished 16:9 image-only slide for the Give n Receive deck.
Use the deck style: warm cream paper, ink serif headline energy, gold/red/blue accents, subtle texture, editorial simplicity.
Keep the slide visually strong at presentation scale.
Use only the following text, large and readable: [exact text].
Avoid all extra microtext, generic UI, green, blue-purple gradients, and clutter.

## Quality Bar

Accept only images that:
- communicate the story before reading any text
- feel warm, human, specific, and premium
- leave room for the deck UI and annotation controls
- can survive being placed inside `GnR_deck.html` without rebuilding the slide
- do not require manual cleanup of unreadable baked-in words

