; Travis Rivera Petit, 2026
; A self-programming robot goes on a painting quest

(define (domain bit-painter)
  (:requirements
    :strips
    :typing
    :negative-preconditions
    :disjunctive-preconditions
    :conditional-effects)

  (:types loc)

  (:predicates
    (at ?l - loc)

    (ABOVE ?from ?to - loc)
    (BELOW ?from ?to - loc)
    (LEFT-OF ?from ?to - loc)
    (RIGHT-OF ?from ?to - loc)

    (blank ?l - loc)
    (red ?l - loc)
    (green ?l - loc)
    (blue ?l - loc)

    (b0)
    (b1)
    (b2)
    (b3)

    (phase-wf)
    (phase-fx)
    (phase-wb)
    (phase-bx)
  )

  (:action flip-b0
    :parameters ()
    :precondition
      (or
        (phase-wf)
        (phase-wb))
    :effect
      (and
        (when (b0) (not (b0)))
        (when (not (b0)) (b0))
        (when (phase-wf)
          (and
            (not (phase-wf))
            (phase-fx)))
        (when (phase-wb)
          (and
            (not (phase-wb))
            (phase-bx)))))

  (:action flip-b1
    :parameters ()
    :precondition
      (or
        (phase-wf)
        (phase-wb))
    :effect
      (and
        (when (b1) (not (b1)))
        (when (not (b1)) (b1))
        (when (phase-wf)
          (and
            (not (phase-wf))
            (phase-fx)))
        (when (phase-wb)
          (and
            (not (phase-wb))
            (phase-bx)))))

  (:action flip-b2
    :parameters ()
    :precondition
      (or
        (phase-wf)
        (phase-wb))
    :effect
      (and
        (when (b2) (not (b2)))
        (when (not (b2)) (b2))
        (when (phase-wf)
          (and
            (not (phase-wf))
            (phase-fx)))
        (when (phase-wb)
          (and
            (not (phase-wb))
            (phase-bx)))))

  (:action flip-b3
    :parameters ()
    :precondition
      (or
        (phase-wf)
        (phase-wb))
    :effect
      (and
        (when (b3) (not (b3)))
        (when (not (b3)) (b3))
        (when (phase-wf)
          (and
            (not (phase-wf))
            (phase-fx)))
        (when (phase-wb)
          (and
            (not (phase-wb))
            (phase-bx)))))

  ;; Instruction set for forward execution:
  ;; 0000 paint-blue-right
  ;; 0001 move-left
  ;; 0010 paint-red-down
  ;; 0011 paint-green-up
  ;; 0100 move-down
  ;; 0101 paint-blue-left
  ;; 0110 paint-red-right
  ;; 0111 paint-green-down
  ;; 1000 paint-red-left
  ;; 1001 move-up
  ;; 1010 paint-blue-down
  ;; 1011 paint-green-right
  ;; 1100 paint-blue-up
  ;; 1101 paint-red-up
  ;; 1110 move-right
  ;; 1111 paint-green-left

  (:action exec-forward-paint-blue-right
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (not (b0))
        (not (b1))
        (not (b2))
        (not (b3))
        (at ?from)
        (RIGHT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (blue ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-move-left
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (not (b0))
        (not (b1))
        (not (b2))
        (b3)
        (at ?from)
        (LEFT-OF ?from ?to))
    :effect
      (and
        (not (at ?from))
        (at ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-red-down
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (not (b0))
        (not (b1))
        (b2)
        (not (b3))
        (at ?from)
        (BELOW ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (red ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-green-up
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (not (b0))
        (not (b1))
        (b2)
        (b3)
        (at ?from)
        (ABOVE ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (green ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-move-down
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (not (b0))
        (b1)
        (not (b2))
        (not (b3))
        (at ?from)
        (BELOW ?from ?to))
    :effect
      (and
        (not (at ?from))
        (at ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-blue-left
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (not (b0))
        (b1)
        (not (b2))
        (b3)
        (at ?from)
        (LEFT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (blue ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-red-right
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (not (b0))
        (b1)
        (b2)
        (not (b3))
        (at ?from)
        (RIGHT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (red ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-green-down
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (not (b0))
        (b1)
        (b2)
        (b3)
        (at ?from)
        (BELOW ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (green ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-red-left
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (b0)
        (not (b1))
        (not (b2))
        (not (b3))
        (at ?from)
        (LEFT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (red ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-move-up
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (b0)
        (not (b1))
        (not (b2))
        (b3)
        (at ?from)
        (ABOVE ?from ?to))
    :effect
      (and
        (not (at ?from))
        (at ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-blue-down
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (b0)
        (not (b1))
        (b2)
        (not (b3))
        (at ?from)
        (BELOW ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (blue ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-green-right
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (b0)
        (not (b1))
        (b2)
        (b3)
        (at ?from)
        (RIGHT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (green ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-blue-up
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (b0)
        (b1)
        (not (b2))
        (not (b3))
        (at ?from)
        (ABOVE ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (blue ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-red-up
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (b0)
        (b1)
        (not (b2))
        (b3)
        (at ?from)
        (ABOVE ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (red ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-move-right
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (b0)
        (b1)
        (b2)
        (not (b3))
        (at ?from)
        (RIGHT-OF ?from ?to))
    :effect
      (and
        (not (at ?from))
        (at ?to)
        (not (phase-fx))
        (phase-wb)))

  (:action exec-forward-paint-green-left
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-fx)
        (b0)
        (b1)
        (b2)
        (b3)
        (at ?from)
        (LEFT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (green ?to)
        (not (phase-fx))
        (phase-wb)))

  ;; Instruction set for backward execution
  ;; 0000 paint-blue-right
  ;; 0001 paint-red-left
  ;; 0010 move-down
  ;; 0011 paint-blue-up
  ;; 0100 paint-red-down
  ;; 0101 paint-blue-down
  ;; 0110 paint-red-right
  ;; 0111 move-right
  ;; 1000 move-left
  ;; 1001 move-up
  ;; 1010 paint-blue-left
  ;; 1011 paint-red-up
  ;; 1100 paint-green-up
  ;; 1101 paint-green-right
  ;; 1110 paint-green-down
  ;; 1111 paint-green-left

  (:action exec-backward-paint-blue-right
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (not (b3))
        (not (b2))
        (not (b1))
        (not (b0))
        (at ?from)
        (RIGHT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (blue ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-move-left
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (not (b3))
        (not (b2))
        (not (b1))
        (b0)
        (at ?from)
        (LEFT-OF ?from ?to))
    :effect
      (and
        (not (at ?from))
        (at ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-red-down
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (not (b3))
        (not (b2))
        (b1)
        (not (b0))
        (at ?from)
        (BELOW ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (red ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-green-up
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (not (b3))
        (not (b2))
        (b1)
        (b0)
        (at ?from)
        (ABOVE ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (green ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-move-down
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (not (b3))
        (b2)
        (not (b1))
        (not (b0))
        (at ?from)
        (BELOW ?from ?to))
    :effect
      (and
        (not (at ?from))
        (at ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-blue-left
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (not (b3))
        (b2)
        (not (b1))
        (b0)
        (at ?from)
        (LEFT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (blue ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-red-right
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (not (b3))
        (b2)
        (b1)
        (not (b0))
        (at ?from)
        (RIGHT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (red ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-green-down
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (not (b3))
        (b2)
        (b1)
        (b0)
        (at ?from)
        (BELOW ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (green ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-red-left
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (b3)
        (not (b2))
        (not (b1))
        (not (b0))
        (at ?from)
        (LEFT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (red ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-move-up
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (b3)
        (not (b2))
        (not (b1))
        (b0)
        (at ?from)
        (ABOVE ?from ?to))
    :effect
      (and
        (not (at ?from))
        (at ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-blue-down
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (b3)
        (not (b2))
        (b1)
        (not (b0))
        (at ?from)
        (BELOW ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (blue ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-green-right
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (b3)
        (not (b2))
        (b1)
        (b0)
        (at ?from)
        (RIGHT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (green ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-blue-up
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (b3)
        (b2)
        (not (b1))
        (not (b0))
        (at ?from)
        (ABOVE ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (blue ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-red-up
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (b3)
        (b2)
        (not (b1))
        (b0)
        (at ?from)
        (ABOVE ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (red ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-move-right
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (b3)
        (b2)
        (b1)
        (not (b0))
        (at ?from)
        (RIGHT-OF ?from ?to))
    :effect
      (and
        (not (at ?from))
        (at ?to)
        (not (phase-bx))
        (phase-wf)))

  (:action exec-backward-paint-green-left
    :parameters (?from ?to - loc)
    :precondition
      (and
        (phase-bx)
        (b3)
        (b2)
        (b1)
        (b0)
        (at ?from)
        (LEFT-OF ?from ?to)
        (blank ?to))
    :effect
      (and
        (not (blank ?to))
        (green ?to)
        (not (phase-bx))
        (phase-wf)))
)
