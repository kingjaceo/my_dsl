#lang br/quicklang
(require brag/support)
(require "TADA_Racket.rkt")

; SYNTAX HELPERS (phase 1, mirrors professor's pattern)
(begin-for-syntax
  (require racket/list)

  ; find-property: searches a list of syntax nodes for one that
  ; starts with a given symbol, returns the rest of its contents
  ; mirrors professor's find-property exactly
  (define (find-property which stx-list)
    (for/first ([stx (in-list (syntax->list stx-list))]
                #:when (and (syntax->list stx)
                            (eq? which (syntax->datum4
                                        (car (syntax->list stx))))))
      (cdr (syntax->list stx))))  ; return all children, not just first

  ; find-definitions: like find-property but returns ALL matching nodes
  ; mirrors professor's find-definitions exactly
  (define (find-definitions which stx-list)
    (for/list ([stx (in-list (syntax->list stx-list))]
               #:when (and (syntax->list stx)
                           (eq? which (syntax->datum
                                       (car (syntax->list stx))))))
      stx)))


; expands a character node — ignored for now
(define-macro (character KEYWORD FEATURE ...)
  #'(displayln "--- character macro ran (ignored for now) ---"))


; macros (following professor's define-macro style)
; expands a room node into a define that calls make-room
; (room "create_room" (name "cave") (links "a" "b") ...)
; →
; (define cave (make-room "cave" '("a" "b") '() '() 0 0 10 10))
(define-macro (room KEYWORD FEATURE ...)
  (with-pattern
      ; each of these binds a LIST of syntax children
      ([NAME-PARTS   (or (find-property 'name       #'(FEATURE ...)) #'())]
       [LINKS-PARTS  (or (find-property 'links      #'(FEATURE ...)) #'())]
       [SIZE-PARTS   (or (find-property 'size       #'(FEATURE ...)) #'())]
       [CHARS-PARTS  (or (find-property 'characters #'(FEATURE ...)) #'())]
       [ITEMS-PARTS  (or (find-property 'items      #'(FEATURE ...)) #'())])
    #'(displayln 'NAME-PARTS)
    (room-register!
     (make-room
      (car 'NAME-PARTS)             ; single string → "The Bar"
      (map (lambda (s)
             (make-connection s 0 0))
           'LINKS-PARTS)            ; list of strings → connections
      'CHARS-PARTS                  ; list (empty for now)
      'ITEMS-PARTS                  ; list (empty for now)
      0 0 10 10))))                 ; size — see note below

; top-level: expands the whole program
; (program room-defn ... char-defn ...)
; →
; (#%module-begin (define cave ...) (define windy-hall ...) ...)
(define-macro (program DEFN ...)
  (with-pattern
      ([(ROOM-DEFN ...)  (find-definitions 'room      #'(DEFN ...))]
       [(CHAR-DEFN ...)  (find-definitions 'character #'(DEFN ...))])
    #'(#%module-begin
       (displayln "=== expander running ===")
       ; (displayln (format "rooms found: ~a" '(ROOM-DEFN ...)))
       ROOM-DEFN ...
       ; CHAR-DEFN ...
       (game-loop)
       (displayln "=== done ==="))))


(provide read-syntax)
(provide (rename-out [program #%module-begin]))
(provide room character make-room)