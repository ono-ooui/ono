# unreleased

# 0.1 - 2025-12-16

- first version

# 0.2 - 2026-02-04

## Added

- factorial.wat + cram test (préliminaire 1) (#6)
- square.wat + cram test (préliminaire 2) (#7)
- function print_i64 (préliminaire 2) (#7)

# 0.3 - 2026-02-11

## Added

- option seed for function random_i32 (préliminaire 3) + cram tests (#5)

## Changed

- factorial.wat is now a tail call

# 0.4 - 2026-02-19

# Added

- function sleep (Interface textuelle)
- function print_cell (Interface textuelle)
- function newline (Interface textuelle)
- function clear_screen (Interface textuelle)

- global variable to define height, width (Interface textuelle, wasm 1)
- initial state saved in lineare memory (Interface textuelle, wasm 2)

# 0.4 - 2026-02-20

# Added

- function read_int (Interface textuelle (extension))

# Changed

- func init in textual.wat now reads user input for width and height
