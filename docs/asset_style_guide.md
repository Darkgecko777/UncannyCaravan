# Uncanny Caravan — Pixel Art Asset Style Guide & Prompts

**Target Aesthetic**: Retro pixel art, Dark Sun / Dune Trader on Athas. Harsh, utilitarian, desperate beauty. High readability at 32x32 or smaller.

## Core Palette (28 colors max — use sparingly)
- Dusty Ochre: #C9A16B (primary sand/cloth)
- Blood Red: #8B2E2E (danger, emphasis)
- Bone White: #E8DFC9 (highlights, bone, ceramic)
- Obsidian Black: #1F1F24 (outlines, metal, night)
- Turquoise Accent: #3A9B9B (magic, water, value)
- Deep Umber: #5C4033 (wood, leather, earth)
- Faded Parchment: #D4C4A8 (paper, old cloth)
- Dark Teal: #2A4A4A (shadows, silt)

**Lighting rule**: Strong top-left key light, hard shadows. No soft gradients.

## Generation Rules for Grok Imagine
Always include the full style prefix + subject.

**Master Prompt Prefix** (copy-paste every time):
```
32x32 pixel art icon, retro 16-bit style, sharp clean pixels with no anti-aliasing or blur, limited 28-color Athas desert palette: dusty ochre #C9A16B, blood red #8B2E2E, bone white #E8DFC9, obsidian black #1F1F24, turquoise accent #3A9B9B, deep umber #5C4033, faded parchment #D4C4A8, dark teal #2A4A4A. High contrast, readable at small size, harsh top-left lighting, utilitarian worn look for Dark Sun / Dune Trader trading goods. Solid background or subtle sand texture. 
```

Then append the specific subject description.

## MVP Asset Priority (Generate in this order)
1. All 10 goods + Ceramic Bits pouch (highest leverage for UI)
2. Caravan sprites (at least 2 states: small guarded, damaged)
3. 9-slice UI frame (desert bone + leather motif, 24-32px source)
4. City sigils / banners (5)
5. Simple dune background layers for parallax

## Generated So Far
- bloodglass (obsidian shards) — session images/1.jpg
- sunsteel (iron ingot) — session images/2.jpg

**Next step**: Manually review, convert to clean PNG if needed (nearest-neighbor scale to 32x32 if the model gave higher res), place in `assets/icons/goods/<id>.png`, set import to Lossless + No Mipmaps.

## Import Settings (Godot)
- Mode: Lossless
- Mipmaps: Disabled
- In project or per-texture: Canvas Texture Filter = Nearest

## Example Full Prompt (Bloodglass)
[see above + "Icon of a stack of dark volcanic obsidian shards / bloodglass, chipped and sharp, simple but distinctive silhouette."]

Keep a log of every prompt used here for reproducibility and consistency fixes.
