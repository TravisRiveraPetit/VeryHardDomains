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


def free_insert(w):
    i = random.randrange(len(w) + 1)
    s = random.choice(SYMS)
    return w[:i] + [s, INVERSE[s]] + w[i:]


def relator_insert(w):
    i = random.randrange(len(w) + 1)
    r = random.choice(RELATORS)
    return w[:i] + r + w[i:]


def free_reduce(w):
    candidates = []
    for i in range(len(w) - 1):
        if INVERSE[w[i]] == w[i + 1]:
            candidates.append(i)

    if not candidates:
        return w

    i = random.choice(candidates)
    return w[:i] + w[i + 2:]


def relator_reduce(w):
    candidates = []
    for i in range(len(w) - 6):
        if w[i:i + 7] in RELATORS:
            candidates.append(i)

    if not candidates:
        return w

    i = random.choice(candidates)
    return w[:i] + w[i + 7:]


def move(w, k):
    if k <= 3:
        moves = (
            [free_insert] * 6
            + [relator_insert] * 1
            + [free_reduce] * 4
            + [relator_reduce] * 1
        )
    elif k <= 7:
        moves = (
            [free_insert] * 5
            + [relator_insert] * 2
            + [free_reduce] * 3
            + [relator_reduce] * 1
        )
    else:
        moves = (
            [free_insert] * 4
            + [relator_insert] * 3
            + [free_reduce] * 2
            + [relator_reduce] * 1
        )

    random.shuffle(moves)

    for f in moves:
        nw = f(w)
        if nw != w or f in (free_insert, relator_insert):
            return nw

    return w


def generate_word(k):
    w = []
    max_len = 0
    steps = 2 * k + 2

    for _ in range(steps):
        w = move(w, k)
        max_len = max(max_len, len(w))

    if not w:
        w = random.choice(RELATORS)[:]
        max_len = max(max_len, len(w))

    return w, max_len

def pddl(name, word, max_len):
    tape_len = max(len(word) + 14, max_len + 14, 20)
    ps = [f"p{i}" for i in range(1, tape_len + 1)]

    left_pad = (tape_len - len(word)) // 2
    contents = [None] * tape_len

    for i, s in enumerate(word):
        contents[left_pad + i] = s

    word_string = " ".join(word)

    out = []

    out.append(f"; word: {word_string}")

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

    for p, s in zip(ps, contents):
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
        w, max_len = generate_word(k)
        tape_len = max(len(w) + 14, max_len + 14, 20)
        Path(f"p{k}.pddl").write_text(pddl(f"p{k}", w, max_len))
        print(f"p{k}.pddl word={len(w)} max={max_len} tape={tape_len}")


if __name__ == "__main__":
    main()
