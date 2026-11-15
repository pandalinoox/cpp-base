# Vim Competitive Programming Setup

A small Vim config for competitive programming in C++20. It opens a three-pane layout (`main.cpp`, `input.txt`, `output.txt`), compiles and runs with one key, and prints results, stderr, and runtime errors in `output.txt`.

Original config: [pandalinoox/vim/vimrc](https://github.com/pandalinoox/vim/blob/main/vimrc)

## Commands

| Command | Description |
|---|---|
| `:CompileAndRun` | Saves all files, compiles `main.cpp`, runs it with `input.txt` as stdin, and writes the output to `output.txt`. |
| `:ResetTemplate` | Clears `input.txt` and `output.txt` and resets `main.cpp` to the template (asks for confirmation first). |

## Shortcuts

| Key | Action |
|---|---|
| `Ctrl-'` | Compile and run (`:CompileAndRun`) |
| `<leader>rt` | Reset template (`:ResetTemplate`) |

## Usage

1. Open Vim in a folder containing `main.cpp`, `input.txt` and `output.txt`.
2. Paste your test input into `input.txt`.
3. Press `Ctrl-'` to compile and run.
4. Read the result in `output.txt`. Compile errors, stderr (`dbg(x)` output) and runtime errors appear there too.
