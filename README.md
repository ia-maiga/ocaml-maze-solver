# Maze Solver & Generator in OCaml

[![CI](https://github.com/ia-maiga/ocaml-maze-solver/actions/workflows/ci.yml/badge.svg)](https://github.com/ia-maiga/ocaml-maze-solver/actions/workflows/ci.yml)

> A command-line tool that **reads, solves and generates mazes**, written in OCaml with a modular
> design (`Grid` / `Solver` / `Generator`) and a test suite of 49 automated checks.

University project for the *Introduction to Functional Programming* course (LDD2, **Université
Paris-Saclay**, 2025-2026), done in pairs.

---

## ✨ Demo

```console
$ maze solve examples/maze_6x6.laby
+-+-+-+-+-+-+
|SRR|    RRR|
+ +R+-+-+R+R+
| |RRRRRRR|R|
+ +-+-+-+-+R+
|   |     |R|
+ + + +-+-+R+
| | |RRRRRRR|
+-+ +R+-+-+-+
|   |RRRRRRE|
+ +-+-+-+-+-+
|           |
+-+-+-+-+-+-+
```

```console
$ maze random 8 4 42
+-+-+-+-+-+-+-+-+
|S|       |     |
+ + +-+-+ +-+-+ +
|   |   |     | |
+-+-+ +-+-+-+ + +
|     |     | | |
+ +-+-+ + +-+ + +
|       |      E|
+-+-+-+-+-+-+-+-+
```

---

## 📐 The `.laby` format

A maze is a rectangle of characters:

| Char | Meaning |
|------|---------|
| `+` `-` `\|` | walls |
| ` ` (space) | free cell |
| `S` | start (exactly one) |
| `E` | exit (exactly one) |
| `R` | cell of the solution path (written by `solve`) |

Moves are up, down, left and right (no diagonals). Sample files are in [`examples/`](examples/).

---

## 🧠 How it works

**Solving: recursive depth-first search** ([`src/solver.ml`](src/solver.ml))
From `S`, the search tries the four directions recursively and marks visited cells. When a call
reaches `E`, every call on the way back marks its cell with `R`, which draws the path. Thanks to
`||`, the search stops as soon as one direction succeeds.

**Generating: randomized depth-first search** ([`src/generator.ml`](src/generator.ml))
Starting with every wall closed, the generator walks from room to room, knocking down the wall
each time it enters an unvisited room, and backtracks at dead ends using an explicit stack.
Each room is entered exactly once, so the passages form a **spanning tree**: the maze is
*perfect* (every room is reachable and there is a single path between any two rooms). The same
seed always produces the same maze.

**Robust parsing** ([`src/grid.ml`](src/grid.ml))
Invalid files are rejected with a precise message instead of a crash:

```console
$ maze print broken.laby
Error: 'broken.laby' is not a valid maze: line 3 has length 4, expected 3 (grid not rectangular)
```

---

## 🚀 Build & run

Requirements: **OCaml ≥ 4.14** and **dune ≥ 3.0** (`opam install dune`).

```bash
git clone https://github.com/ia-maiga/ocaml-maze-solver.git
cd ocaml-maze-solver

dune build                                            # compile
dune test                                             # run the test suite

dune exec bin/maze.exe -- print examples/maze_4x8.laby
dune exec bin/maze.exe -- solve examples/maze_100x100.laby
dune exec bin/maze.exe -- random 20 10 42             # print a random maze
dune exec bin/maze.exe -- random 20 10 42 out.laby    # or save it to a file
dune exec bin/maze.exe -- --help
```

| Exit code | Meaning |
|-----------|---------|
| 0 | success |
| 1 | invalid command line |
| 2 | file cannot be opened |
| 3 | invalid maze file |
| 4 | the maze has no solution |
| 5 | maze too large for the recursive solver |

---

## 📂 Project structure

```
├── bin/maze.ml          command-line interface
├── src/
│   ├── grid.ml(i)       maze type, parsing, validation, printing
│   ├── solver.ml(i)     recursive DFS solver
│   └── generator.ml(i)  random perfect-maze generator
├── test/test_maze.ml    49 unit tests (parsing, errors, solver, generator)
└── examples/            sample mazes, from 2x1 to 100x100
```

Each module has an interface file (`.mli`) with documentation comments, so its internal
representation stays hidden from the rest of the program.

---

## 🔧 Improvements after the course

After the project was graded, I reworked it to make it cleaner and more reliable:

- **New generator**: the original one drew a single random staircase path and walled off
  everything else. It is now a real randomized DFS that produces perfect mazes, in linear time.
- **Parsing bug fixed**: the original check only compared lines 1-2, 3-4, … so some badly formed
  files crashed the program. Every line is now checked, and `S` / `E` are validated.
- **Clear errors and exit codes** instead of uncaught exceptions; `--help`; the `random` command
  now matches its documentation.
- **Simpler data model**: a `char array array` with an abstract type `Grid.t`, instead of records
  with unused fields.
- **Automated tests** (`dune test`) and **continuous integration** with GitHub Actions.

---

## 👥 Authors

**Ibrahim Aboubakarine Maiga** & **Walid Bouzid**
Double Bachelor's in Mathematics & Computer Science, Université Paris-Saclay

> *If you are currently taking this course: this repository is shared as a portfolio.
> Please write your own code; copying it would be plagiarism.*
