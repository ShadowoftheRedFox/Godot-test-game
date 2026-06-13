# Code

This document tells what to do and not do when writting cod ein this project.

- [Code](#code)
  - [Naming convention](#naming-convention)


## Naming convention

Quick references:
| Context                 | Case  | Uppercase | Prefix | Can be combined with other rules |
| ----------------------- | :---: | :-------: | :----: | :------------------------------: |
| Class name              | Title |           |        |                                  |
| Enum name               | Title |           |        |                                  |
| Constant name           | Snake |     ✅     |        |                ✅                 |
| Property name           | Snake |           |        |                ✅                 |
| Function name           | Snake |           |        |                ✅                 |
| -                       |   -   |     -     |   -    |                -                 |
| Listening to a signal   |       |           |  `on`  |                ✅                 |
| "Private" to the script |       |           |  `_`   |                ✅                 |
| Function returns `bool` |       |           |  `is`  |                ✅                 |


This project follow a nameing convention for clarity:
- Title case: for class names and enums. Exemple: `InGameMenu`
- Snake case: for class everything else. Exemple: `everything_else_is_snake`
  - Uppercase: for constants. Exemple: `ITEM_RARITY_COLOR`
- If this property/function is internal, and should not be called outside of the script where is is defined, prefix it with an underscore. Exemple: `_very_touchy`
- If this function exists for the sole purpose to listen to a signal, prefix it with `_on`. It should also follow the same name as the event it's connecting to. Exemple: Signal `visibility_changed` -> `_on_visibility_changed`

All functions and variables should have a declared type. The use or the `Variant` type is prohibited unless strictly necessary.
