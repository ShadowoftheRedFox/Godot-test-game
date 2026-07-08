# Documentation

## About the code

- [Code layout](./code_layout.gd): Details about what to expect when writing GD Script.
- Each function must be commented to be understood at a glance. It doesn't need to have a comment on each line, just enough. If the code is really hard to understand (lots of logic or math), you can comment each line, or even add links to documentation.

### Logging

- `assert`: Must be used to assert condition when debugging, meaning **ALL** assert errors must be fixed before building to production. If the code should run in production but still make the check, then use an `if` instead.
- `print` and `printerr`: Only use those if it is useful information to display in the console for production, such as save or load file errors.
- `pusj_warning` and `push_error`: Use when this information is only needed for debugging, but not for production.
