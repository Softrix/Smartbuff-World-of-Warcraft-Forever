# SmartBuff changes

## r1.041126 - 2026-11-04 20:37

- Release for World of Warcraft: Forever. This is a big update in terms of file structure, functions, and so on, so it is strongly advised that you completely clear your SmartBuff WTF Lua files if you previously tried a Classic Era version on Forever. As always, join Discord and report any errors you encounter.

## r1.191026 - 2026-10-19 13:55

- Kings no longer treats Mark of the Wild or Gift of the Wild as the same buff. Wisdom no longer treats Arcane Intellect or Arcane Brilliance as the same buff. In Forever those auras stack, so the old links were skipping the cast. Each spell now links only to its own greater version.

## r1.191026 - 2026-10-19 14:02

- Spells that `C_Spell.IsSpellUsable` reports as not usable are no longer queued. The old test never ran because `not` bound tighter than `==`.
- Druid form checks compare spell names, so Moonkin can still buff and cat-only Track Humanoids is allowed only in Cat Form.
- Thorns uses rank levels 6, 14, 24, 34, 44, and 54 instead of always the highest rank.
- An aura with no remaining time is treated as ready to rebuff instead of having hours left.
- Sharpening stones and weightstones match the item name, and weapon subtypes match both singular and plural names. A missing weapon link no longer stops the buff check.
- The in-combat cast sequence is written while still out of combat and kept when combat lockdown blocks a new stamp.
- Conjured-item icons fall back to the item texture, and buff-timer resets no longer write a global `n`.

## r1.191026 - 2026-10-19 14:16

- Scroll zoom returns after a buff lands. An aura with no clock time was treated as expired, so every scroll still tried to cast it and the camera stayed locked. A real future expiration still uses the rebuff window.

## r1.191026 - 2026-10-19 14:24

- Scroll zoom works again after the first buff. The in-combat cast sequence was being written onto the scroll-wheel button while out of combat, so later scrolls ran that macro instead of zooming. The sequence is only stamped when combat starts. A wheel click that does not report key-down no longer keeps the camera locked.
