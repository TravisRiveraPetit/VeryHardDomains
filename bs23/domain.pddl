; Travis Rivera Petit, 2026
; Word problem for finitely presented groups as fixed-position tape rewriting

(define (domain word-problem-relator-7)
  (:requirements
    :strips
    :typing
    :negative-preconditions
  )

  (:types
    pos
    sym
  )

  (:predicates
    (NEXT ?x ?y - pos)
    (INVERSE ?s ?si - sym)
    (RELATOR ?s1 ?s2 ?s3 ?s4 ?s5 ?s6 ?s7 - sym)

    (has-element ?p - pos ?s - sym)
    (empty ?p - pos)
  )

  (:action free-reduce
    :parameters (?x ?y - pos ?s ?si - sym)
    :precondition
      (and
        (NEXT ?x ?y)
        (has-element ?x ?s)
        (has-element ?y ?si)
        (INVERSE ?s ?si)
      )
    :effect
      (and
        (not (has-element ?x ?s))
        (not (has-element ?y ?si))
        (empty ?x)
        (empty ?y)
      )
  )

  (:action free-insert
    :parameters (?x ?y - pos ?s ?si - sym)
    :precondition
      (and
        (NEXT ?x ?y)
        (empty ?x)
        (empty ?y)
        (INVERSE ?s ?si)
      )
    :effect
      (and
        (not (empty ?x))
        (not (empty ?y))
        (has-element ?x ?s)
        (has-element ?y ?si)
      )
  )

  (:action relator-reduce-7
    :parameters
      (?p1 ?p2 ?p3 ?p4 ?p5 ?p6 ?p7 - pos
       ?s1 ?s2 ?s3 ?s4 ?s5 ?s6 ?s7 - sym)
    :precondition
      (and
        (NEXT ?p1 ?p2)
        (NEXT ?p2 ?p3)
        (NEXT ?p3 ?p4)
        (NEXT ?p4 ?p5)
        (NEXT ?p5 ?p6)
        (NEXT ?p6 ?p7)

        (has-element ?p1 ?s1)
        (has-element ?p2 ?s2)
        (has-element ?p3 ?s3)
        (has-element ?p4 ?s4)
        (has-element ?p5 ?s5)
        (has-element ?p6 ?s6)
        (has-element ?p7 ?s7)

        (RELATOR ?s1 ?s2 ?s3 ?s4 ?s5 ?s6 ?s7)
      )
    :effect
      (and
        (not (has-element ?p1 ?s1))
        (not (has-element ?p2 ?s2))
        (not (has-element ?p3 ?s3))
        (not (has-element ?p4 ?s4))
        (not (has-element ?p5 ?s5))
        (not (has-element ?p6 ?s6))
        (not (has-element ?p7 ?s7))

        (empty ?p1)
        (empty ?p2)
        (empty ?p3)
        (empty ?p4)
        (empty ?p5)
        (empty ?p6)
        (empty ?p7)
      )
  )

  (:action relator-insert-7
    :parameters
      (?p1 ?p2 ?p3 ?p4 ?p5 ?p6 ?p7 - pos
       ?s1 ?s2 ?s3 ?s4 ?s5 ?s6 ?s7 - sym)
    :precondition
      (and
        (NEXT ?p1 ?p2)
        (NEXT ?p2 ?p3)
        (NEXT ?p3 ?p4)
        (NEXT ?p4 ?p5)
        (NEXT ?p5 ?p6)
        (NEXT ?p6 ?p7)

        (empty ?p1)
        (empty ?p2)
        (empty ?p3)
        (empty ?p4)
        (empty ?p5)
        (empty ?p6)
        (empty ?p7)

        (RELATOR ?s1 ?s2 ?s3 ?s4 ?s5 ?s6 ?s7)
      )
    :effect
      (and
        (not (empty ?p1))
        (not (empty ?p2))
        (not (empty ?p3))
        (not (empty ?p4))
        (not (empty ?p5))
        (not (empty ?p6))
        (not (empty ?p7))

        (has-element ?p1 ?s1)
        (has-element ?p2 ?s2)
        (has-element ?p3 ?s3)
        (has-element ?p4 ?s4)
        (has-element ?p5 ?s5)
        (has-element ?p6 ?s6)
        (has-element ?p7 ?s7)
      )
  )

  (:action slide-left
    :parameters (?x ?y - pos ?s - sym)
    :precondition
      (and
        (NEXT ?x ?y)
        (empty ?x)
        (has-element ?y ?s)
      )
    :effect
      (and
        (not (empty ?x))
        (not (has-element ?y ?s))
        (has-element ?x ?s)
        (empty ?y)
      )
  )

  (:action slide-right
    :parameters (?x ?y - pos ?s - sym)
    :precondition
      (and
        (NEXT ?x ?y)
        (has-element ?x ?s)
        (empty ?y)
      )
    :effect
      (and
        (not (has-element ?x ?s))
        (not (empty ?y))
        (empty ?x)
        (has-element ?y ?s)
      )
  )
)
