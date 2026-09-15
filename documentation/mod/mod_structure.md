# Mod structure

The mod must be a folder in the [mod folder](../../mod/) called `mod-name` or `mode-name_version`.

- [Mod structure](#mod-structure): Explain how a mod internal structure must be to be loaded in the game.
  - [Files](#files): The files that the game reads when loading the mod.
    - [infos.json](#infosjson): Defines what the file must and can contain.
  - [Subfolders](#subfolders): The folders the game can read for some more informations.

## Files

Inside the mod folder, the game will read the following files:

- `infos.json`: A mandatory file. Must be a valid JSON file. Define general informations about the mod.

### infos.json

Here are the fields the `infos.json` file supports:

- **name**:  
  Type: `string`, **Mandatory**  
  The name of the mod. Must be between 3 and 60 alphanumeric characters.
- **version**:  
  Type: `string`, **Mandatory**  
  The version of the name. A version is compared through the sort algorithm to see which version is more recent than another one.
- **title**:  
  Type: `string`, **Mandatory**  
  The display name of the mod. Can be any character. Must be shorter than 120 characters.
- **author**:  
  Type: `string`, **Mandatory**  
  The name of the author.
- **game_version**:  
  Type: `string`  
  The version of the game compatible with the mod. It can be a `number.number` for major and minor version, or just a `number` for the major version. If the value don't match, the mod won't load.
- **requirements**:  
  Type: `[string]`  
  A list of mode name that define what other mod must be, or must not be, present.  
  By default, the `core` mod, the game base, is included by default at the game version.

  Example: `["a", "! b", "? c > 4.0.8"]`

  Must follow this syntax: `<prefix> mode-name <operator> <version>`:
  - Operator is either `<`, `<=`, `=`, `>`, `>=`, used to compare the version of the mod required.
  - Prefix is either `!`, `?`, or no prefix:
    - `!` to exclude the given mod.
    - `?` to say it's an optional mod.
    - Nothing to require the mod.

## Subfolders
