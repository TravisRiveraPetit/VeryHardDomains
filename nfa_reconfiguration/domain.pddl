; Travis Rivera Petit, 2026
; Inspired by the post on TCS stack exchange:
; https://cstheory.stackexchange.com/questions/55063/multiple-paths-in-nfa-open-problem

(define (domain path-2p-nfa)
  (:requirements
    :typing
    :equality
    :negative-preconditions
    :conditional-effects
    :universal-preconditions
    :existential-preconditions
    :derived-predicates
  )

  (:types
    index
    layer
    state
  )

  (:predicates
    (WORD-0 ?i - index)
    (WORD-1 ?i - index)
    (SUCC ?current ?next - index)
    (FIRST ?i - index)
    (LAST ?i - index)
    (START ?l - layer)
    (FINAL ?l - layer)
    (STEP ?l1 - layer ?i - index ?l2 - layer)
    (INIT ?s - state)

    (p1 ?i - index ?s - state)
    (p2 ?i - index ?s - state)

    (edge0 ?a ?b - state)
    (edge1 ?a ?b - state)

    (accept ?s - state)

    (paths-different)
    (exact ?l - layer ?s - state)
    (diff ?l - layer ?s - state)
    (bad-word)
    (valid-2p)
  )

  (:derived (edge0 ?a ?b - state)
    (or
      (exists (?i - index)
        (and
          (FIRST ?i)
          (WORD-0 ?i)
          (INIT ?a)
          (p1 ?i ?b)
        )
      )

      (exists (?j ?i - index)
        (and
          (SUCC ?j ?i)
          (WORD-0 ?i)
          (p1 ?j ?a)
          (p1 ?i ?b)
        )
      )

      (exists (?i - index)
        (and
          (FIRST ?i)
          (WORD-0 ?i)
          (INIT ?a)
          (p2 ?i ?b)
        )
      )

      (exists (?j ?i - index)
        (and
          (SUCC ?j ?i)
          (WORD-0 ?i)
          (p2 ?j ?a)
          (p2 ?i ?b)
        )
      )
    )
  )

  (:derived (edge1 ?a ?b - state)
    (or
      (exists (?i - index)
        (and
          (FIRST ?i)
          (WORD-1 ?i)
          (INIT ?a)
          (p1 ?i ?b)
        )
      )

      (exists (?j ?i - index)
        (and
          (SUCC ?j ?i)
          (WORD-1 ?i)
          (p1 ?j ?a)
          (p1 ?i ?b)
        )
      )

      (exists (?i - index)
        (and
          (FIRST ?i)
          (WORD-1 ?i)
          (INIT ?a)
          (p2 ?i ?b)
        )
      )

      (exists (?j ?i - index)
        (and
          (SUCC ?j ?i)
          (WORD-1 ?i)
          (p2 ?j ?a)
          (p2 ?i ?b)
        )
      )
    )
  )

  (:derived (accept ?s - state)
    (or
      (exists (?i - index)
        (and
          (LAST ?i)
          (p1 ?i ?s)
        )
      )
      (exists (?i - index)
        (and
          (LAST ?i)
          (p2 ?i ?s)
        )
      )
    )
  )

  (:derived (paths-different)
    (exists (?i - index ?s1 ?s2 - state)
      (and
        (p1 ?i ?s1)
        (p2 ?i ?s2)
        (not (= ?s1 ?s2))
      )
    )
  )

  (:derived (exact ?l - layer ?s - state)
    (or
      (and
        (START ?l)
        (INIT ?s)
      )

      (exists (?l0 - layer ?i - index ?q - state)
        (and
          (STEP ?l0 ?i ?l)
          (exact ?l0 ?q)
          (or
            (and
              (WORD-0 ?i)
              (edge0 ?q ?s)
            )
            (and
              (WORD-1 ?i)
              (edge1 ?q ?s)
            )
          )
        )
      )
    )
  )

  (:derived (diff ?l - layer ?s - state)
    (or
      (exists (?l0 - layer ?i - index ?q - state)
        (and
          (STEP ?l0 ?i ?l)
          (diff ?l0 ?q)
          (or
            (edge0 ?q ?s)
            (edge1 ?q ?s)
          )
        )
      )

      (exists (?l0 - layer ?i - index ?q - state)
        (and
          (STEP ?l0 ?i ?l)
          (exact ?l0 ?q)
          (or
            (and
              (WORD-0 ?i)
              (edge1 ?q ?s)
            )
            (and
              (WORD-1 ?i)
              (edge0 ?q ?s)
            )
          )
        )
      )
    )
  )

  (:derived (bad-word)
    (exists (?l - layer ?s - state)
      (and
        (FINAL ?l)
        (accept ?s)
        (diff ?l ?s)
      )
    )
  )

  (:derived (valid-2p)
    (and
      (paths-different)
      (not (bad-word))
    )
  )

  (:action mutate-merge-p1
    :parameters (
      ?i - index
      ?old ?new - state
      ?keep ?kill - state
    )

    :precondition (and
      (p1 ?i ?old)
      (not (= ?keep ?kill))
      (not (INIT ?kill))
    )

    :effect (and
      (not (p1 ?i ?old))

      (forall (?j - index)
        (when
          (and
            (not (= ?j ?i))
            (p1 ?j ?kill)
          )
          (and
            (not (p1 ?j ?kill))
            (p1 ?j ?keep)
          )
        )
      )

      (forall (?j - index)
        (when
          (p2 ?j ?kill)
          (and
            (not (p2 ?j ?kill))
            (p2 ?j ?keep)
          )
        )
      )

      (when
        (= ?new ?kill)
        (p1 ?i ?keep)
      )

      (when
        (not (= ?new ?kill))
        (p1 ?i ?new)
      )
    )
  )

  (:action mutate-merge-p2
    :parameters (
      ?i - index
      ?old ?new - state
      ?keep ?kill - state
    )

    :precondition (and
      (p2 ?i ?old)
      (not (= ?keep ?kill))
      (not (INIT ?kill))
    )

    :effect (and
      (not (p2 ?i ?old))

      (forall (?j - index)
        (when
          (p1 ?j ?kill)
          (and
            (not (p1 ?j ?kill))
            (p1 ?j ?keep)
          )
        )
      )

      (forall (?j - index)
        (when
          (and
            (not (= ?j ?i))
            (p2 ?j ?kill)
          )
          (and
            (not (p2 ?j ?kill))
            (p2 ?j ?keep)
          )
        )
      )

      (when
        (= ?new ?kill)
        (p2 ?i ?keep)
      )

      (when
        (not (= ?new ?kill))
        (p2 ?i ?new)
      )
    )
  ))
