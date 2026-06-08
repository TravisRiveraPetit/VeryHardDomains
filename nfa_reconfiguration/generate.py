import sys
import random
from pathlib import Path

random.seed(404)

DOMAIN = "path-2p-nfa"


def induced_edges(word, p1, p2):
    e0 = set()
    e1 = set()

    for p in (p1, p2):
        prev = 0
        for bit, s in zip(word, p):
            if bit == 0:
                e0.add((prev, s))
            else:
                e1.add((prev, s))
            prev = s

    return e0, e1


def valid(word, p1, p2):
    if not any(a != b for a, b in zip(p1, p2)):
        return False

    e0, e1 = induced_edges(word, p1, p2)
    accept = {p1[-1], p2[-1]}

    exact = {0}
    diff = set()

    for bit in word:
        good = e0 if bit == 0 else e1
        bad = e1 if bit == 0 else e0

        next_exact = {b for a, b in good if a in exact}
        next_diff = {b for a, b in e0 | e1 if a in diff}
        next_diff |= {b for a, b in bad if a in exact}

        exact = next_exact
        diff = next_diff

    return not any(s in accept for s in diff)


def apply_move(side, p1, p2, i, new, keep, kill):
    def merge(s):
        return keep if s == kill else s

    q1 = [merge(s) for s in p1]
    q2 = [merge(s) for s in p2]

    if side == 1:
        q1[i] = merge(new)
    else:
        q2[i] = merge(new)

    return q1, q2


def random_valid_move(word, p1, p2, states):
    used = set(p1 + p2 + [0])
    unused = [s for s in states if s not in used and s != 0]

    for _ in range(2000):
        side = random.choice([1, 2])
        i = random.randrange(len(word))

        if unused and random.random() < 0.75:
            new = random.choice(unused)
        else:
            new = random.choice(states)

        if unused and random.random() < 0.85:
            kill = random.choice(unused)
        else:
            kill = random.choice([s for s in states if s != 0])

        keep = random.choice([s for s in states if s != kill])

        q1, q2 = apply_move(side, p1, p2, i, new, keep, kill)

        if valid(word, q1, q2) and (q1 != p1 or q2 != p2):
            return q1, q2

    return p1, p2


def generate(k):
    n = k + 1
    steps = 5 * k
    num_states = 2 * n + steps

    states = list(range(num_states))
    word = [random.randrange(2) for _ in range(n)]

    p1_start = list(range(1, n + 1))
    p2_start = list(range(n + 1, 2 * n + 1))

    p1 = p1_start[:]
    p2 = p2_start[:]

    for _ in range(steps):
        p1, p2 = random_valid_move(word, p1, p2, states)

    return word, states, p1_start, p2_start, p1, p2


def chunks(xs, n):
    return [xs[i:i + n] for i in range(0, len(xs), n)]


def pddl(name, word, states, p1_start, p2_start, p1_goal, p2_goal):
    n = len(word)

    indices = [f"i{i}" for i in range(1, n + 1)]
    layers = [f"l{i}" for i in range(0, n + 1)]
    qs = [f"q{s}" for s in states]

    out = []

    out.append(f"(define (problem {name})")
    out.append(f"  (:domain {DOMAIN})")
    out.append("  (:objects")

    for xs in chunks(indices, 20):
        out.append("    " + " ".join(xs) + " - index")

    for xs in chunks(layers, 20):
        out.append("    " + " ".join(xs) + " - layer")

    for xs in chunks(qs, 20):
        out.append("    " + " ".join(xs) + " - state")

    out.append("  )")
    out.append("  (:init")

    for i, bit in zip(indices, word):
        out.append(f"    (WORD-{bit} {i})")

    for a, b in zip(indices, indices[1:]):
        out.append(f"    (SUCC {a} {b})")

    out.append(f"    (FIRST {indices[0]})")
    out.append(f"    (LAST {indices[-1]})")

    out.append(f"    (START {layers[0]})")
    out.append(f"    (FINAL {layers[-1]})")

    for l1, i, l2 in zip(layers, indices, layers[1:]):
        out.append(f"    (STEP {l1} {i} {l2})")

    out.append("    (INIT q0)")

    for i, s in zip(indices, p1_start):
        out.append(f"    (p1 {i} q{s})")

    for i, s in zip(indices, p2_start):
        out.append(f"    (p2 {i} q{s})")

    out.append("  )")
    out.append("  (:goal")
    out.append("    (and")
    out.append("      (valid-2p)")

    for i, s in zip(indices, p1_goal):
        out.append(f"      (p1 {i} q{s})")

    for i, s in zip(indices, p2_goal):
        out.append(f"      (p2 {i} q{s})")

    out.append("    )")
    out.append("  )")
    out.append(")")

    return "\n".join(out) + "\n"


def main():
    n = int(sys.argv[1])

    for k in range(1, n + 1):
        word, states, p1_start, p2_start, p1_goal, p2_goal = generate(k)
        Path(f"p{k}.pddl").write_text(
            pddl(f"p{k}", word, states, p1_start, p2_start, p1_goal, p2_goal)
        )
        w = "".join(str(x) for x in word)
        print(f"p{k}.pddl word={w} length={len(word)} states={len(states)}")


if __name__ == "__main__":
    main()
