# NFA Reconfiguration Problem

[Inspired by this post](https://cstheory.stackexchange.com/questions/55063/multiple-paths-in-nfa-open-problem).
This domain models a reconfiguration problem for NFAs.

The goal is to transform an NFA into another using local moves, while preserving the following properties at every step for a fixed `w`.

1. `w` is accepted by two distinct accepting paths,
2. no other word `w'` with `|w'| = |w|` is accepted.
