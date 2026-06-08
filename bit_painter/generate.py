import sys
import random
from pathlib import Path

random.seed(404)

DOMAIN = "bit-painter"

COLORS = ["red", "green", "blue"]

MOVES = {
    "0001": "left",
    "0100": "down",
    "1001": "up",
    "1110": "right",
}

PAINTS = {
    "0000": ("blue", "right"),
    "0010": ("red", "down"),
    "0011": ("green", "up"),
    "0101": ("blue", "left"),
    "0110": ("red", "right"),
    "0111": ("green", "down"),
    "1000": ("red", "left"),
    "1010": ("blue", "down"),
    "1011": ("green", "right"),
    "1100": ("blue", "up"),
    "1101": ("red", "up"),
    "1111": ("green", "left"),
}


def dims(k):
    return 10 + (k - 1) // 2, 10 + k // 2


def loc(r, c):
    return f"l{r}-{c}"


def neighbor(rows, cols, r, c, d):
    if d == "up":
        return (r - 1) % rows, c
    if d == "down":
        return (r + 1) % rows, c
    if d == "left":
        return r, (c - 1) % cols
    return r, (c + 1) % cols


def word(bits, forward):
    if forward:
        return "".join(str(x) for x in bits)
    return "".join(str(x) for x in reversed(bits))


def initial_colors(rows, cols, count):
    cells = [(r, c) for r in range(rows) for c in range(cols)]
    random.shuffle(cells)
    return {cell: random.choice(COLORS) for cell in cells[:count]}


def applicable(rows, cols, colors, pos, bits, forward):
    w = word(bits, forward)

    if w in MOVES:
        return True

    color, d = PAINTS[w]
    tr, tc = neighbor(rows, cols, pos[0], pos[1], d)
    return (tr, tc) not in colors


def execute(rows, cols, colors, pos, bits, forward):
    w = word(bits, forward)

    if w in MOVES:
        return colors, neighbor(rows, cols, pos[0], pos[1], MOVES[w])

    color, d = PAINTS[w]
    tr, tc = neighbor(rows, cols, pos[0], pos[1], d)
    colors[(tr, tc)] = color
    return colors, pos


def generate(k):
    rows, cols = dims(k)
    area = rows * cols
    init_target = area // 10
    goal_target = (2 * area) // 3

    best_init = None
    best_goal = None

    for _ in range(100):
        init = initial_colors(rows, cols, init_target)
        colors = dict(init)

        bits = [0, 0, 0, 0]
        pos = (0, 0)
        forward = True
        limit = 300 * area

        for _ in range(limit):
            if len(colors) >= goal_target:
                break

            choices = list(range(4))
            random.shuffle(choices)

            candidates = []

            for i in choices:
                trial = list(bits)
                trial[i] ^= 1

                if applicable(rows, cols, colors, pos, trial, forward):
                    w = word(trial, forward)
                    score = 1 if w in PAINTS else 0
                    candidates.append((score, i, trial))

            if not candidates:
                break

            best_score = max(score for score, _, _ in candidates)
            candidates = [x for x in candidates if x[0] == best_score]

            _, i, bits = random.choice(candidates)
            colors, pos = execute(rows, cols, colors, pos, bits, forward)
            forward = not forward

        if best_goal is None or len(colors) > len(best_goal):
            best_init = dict(init)
            best_goal = dict(colors)

        if len(colors) >= goal_target:
            return rows, cols, init, colors

    return rows, cols, best_init, best_goal


def pddl(name, rows, cols, init_colors, goal_colors):
    cells = [loc(r, c) for r in range(rows) for c in range(cols)]
    out = []

    out.append(f"(define (problem {name})")
    out.append(f"  (:domain {DOMAIN})")
    out.append("  (:objects")

    for i in range(0, len(cells), 12):
        out.append("    " + " ".join(cells[i:i + 12]) + " - loc")

    out.append("  )")
    out.append("  (:init")

    for r in range(rows):
        for c in range(cols):
            x = loc(r, c)
            u = loc(*neighbor(rows, cols, r, c, "up"))
            d = loc(*neighbor(rows, cols, r, c, "down"))
            l = loc(*neighbor(rows, cols, r, c, "left"))
            rr = loc(*neighbor(rows, cols, r, c, "right"))

            out.append(f"    (ABOVE {x} {u})")
            out.append(f"    (BELOW {x} {d})")
            out.append(f"    (LEFT-OF {x} {l})")
            out.append(f"    (RIGHT-OF {x} {rr})")

    out.append(f"    (at {loc(0, 0)})")
    out.append("    (phase-wf)")

    for r in range(rows):
        for c in range(cols):
            cell = (r, c)
            if cell in init_colors:
                out.append(f"    ({init_colors[cell]} {loc(r, c)})")
            else:
                out.append(f"    (blank {loc(r, c)})")

    out.append("  )")
    out.append("  (:goal")
    out.append("    (and")

    for r in range(rows):
        for c in range(cols):
            cell = (r, c)
            if cell in goal_colors:
                out.append(f"      ({goal_colors[cell]} {loc(r, c)})")
            else:
                out.append(f"      (blank {loc(r, c)})")

    out.append("    )")
    out.append("  )")
    out.append(")")

    return "\n".join(out) + "\n"


def main():
    n = int(sys.argv[1])

    for k in range(1, n + 1):
        rows, cols, init_colors, goal_colors = generate(k)
        Path(f"p{k}.pddl").write_text(
            pddl(f"p{k}", rows, cols, init_colors, goal_colors)
        )
        print(
            f"p{k}.pddl grid={rows}x{cols} "
            f"init={len(init_colors)} goal={len(goal_colors)} "
            f"added={len(goal_colors) - len(init_colors)}"
        )


if __name__ == "__main__":
    main()
