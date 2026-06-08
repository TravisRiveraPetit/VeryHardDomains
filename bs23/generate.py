import sys
import random
from pathlib import Path

random.seed(404)

DOMAIN = "word-problem-relator-7"

SYMS = ["a", "ai", "b", "bi"]

INVERSE = {
    "a": "ai",
    "ai": "a",
    "b": "bi",
    "bi": "b",
}

RELATORS = [
    ["b", "a", "a", "bi", "ai", "ai", "ai"],
    ["a", "a", "a", "b", "ai", "ai", "bi"],
]


def windows(length, width):
    return [list(range(i, i + width)) for i in range(length - width + 1)]


def free_insert(tape):
    candidates = []
    for i, j in windows(len(tape), 2):
        if tape[i] is None and tape[j] is None:
            for s in SYMS:
                candidates.append((i, j, s, INVERSE[s]))
    if not candidates:
        return False
    i, j, s, si = random.choice(candidates)
    tape[i] = s
    tape[j] = si
    return True


def relator_insert(tape):
    candidates = []
    for w in windows(len(tape), 7):
        if all(tape[i] is None for i in w):
            for r in RELATORS:
                candidates.append((w, r))
    if not candidates:
        return False
    w, r = random.choice(candidates)
    for i, s in zip(w, r):
        tape[i] = s
    return True


def free_reduce(tape):
    candidates = []
    for i, j in windows(len(tape), 2):
        if tape[i] is not None and tape[j] is not None and INVERSE[tape[i]] == tape[j]:
            candidates.append((i, j))
    if not candidates:
        return False
    i, j = random.choice(candidates)
    tape[i] = None
    tape[j] = None
    return True


def relator_reduce(tape):
    candidates = []
    for w in windows(len(tape), 7):
        if [tape[i] for i in w] in RELATORS:
            candidates.append(w)
    if not candidates:
        return False
    w = random.choice(candidates)
    for i in w:
        tape[i] = None
    return True


def slide(tape):
    candidates = []
    for i, j in windows(len(tape), 2):
        if (tape[i] is None) != (tape[j] is None):
            candidates.append((i, j))
    if not candidates:
        return False
    i, j = random.choice(candidates)
    tape[i], tape[j] = tape[j], tape[i]
    return True


def move(tape):
    moves = (
        [free_insert] * 4
        + [relator_insert] * 3
        + [free_reduce] * 2
        + [relator_reduce]
        + [slide] * 4
    )
    random.shuffle(moves)
    for f in moves:
        if f(tape):
            return True
    return False


def crop_tape(tape, max_nonempty):
    occupied = [i for i, x in enumerate(tape) if x is not None]

    if not occupied:
        return [None] * max(14, max_nonempty + 14)

    lo = min(occupied)
    hi = max(occupied)

    cropped = tape[lo : hi + 1]
    needed = max(len(cropped), max_nonempty) + 14

    extra = needed - len(cropped)
    left = extra // 2
    right = extra - left

    return [None] * left + cropped + [None] * right


def generate(k):
    steps = 10 * k
    tape = [None] * (7 * steps + 28)
    max_nonempty = 0

    for _ in range(steps):
        move(tape)
        max_nonempty = max(max_nonempty, sum(x is not None for x in tape))

    if all(x is None for x in tape):
        relator_insert(tape)
        max_nonempty = max(max_nonempty, 7)

    return crop_tape(tape, max_nonempty)


def pddl(name, tape):
    ps = [f"p{i}" for i in range(1, len(tape) + 1)]
    out = []

    out.append(f"(define (problem {name})")
    out.append(f"  (:domain {DOMAIN})")
    out.append("  (:objects")

    for i in range(0, len(ps), 20):
        out.append("    " + " ".join(ps[i:i + 20]) + " - pos")

    out.append("    a ai b bi - sym")
    out.append("  )")
    out.append("  (:init")

    for x, y in zip(ps, ps[1:]):
        out.append(f"    (NEXT {x} {y})")

    out.append("    (INVERSE a ai)")
    out.append("    (INVERSE ai a)")
    out.append("    (INVERSE b bi)")
    out.append("    (INVERSE bi b)")

    out.append("    (RELATOR b a a bi ai ai ai)")
    out.append("    (RELATOR a a a b ai ai bi)")

    for p, s in zip(ps, tape):
        if s is None:
            out.append(f"    (empty {p})")
        else:
            out.append(f"    (has-element {p} {s})")

    out.append("  )")
    out.append("  (:goal")
    out.append("    (and")

    for p in ps:
        out.append(f"      (empty {p})")

    out.append("    )")
    out.append("  )")
    out.append(")")

    return "\n".join(out) + "\n"


def main():
    n = int(sys.argv[1])

    for k in range(1, n + 1):
        tape = generate(k)
        Path(f"p{k}.pddl").write_text(pddl(f"p{k}", tape))
        print(f"p{k}.pddl tape={len(tape)} nonempty={sum(x is not None for x in tape)}")


if __name__ == "__main__":
    main()
