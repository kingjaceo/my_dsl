#lang br/quicklang
(require brag/support)
(require "TADA_Racket.rkt")

; SYNTAX HELPERS 
(begin-for-syntax
  (require racket/list)

  ; find-property: searches a list of syntax nodes for one that
  ; starts with a given symbol, returns the rest of its contents
  ; mirrors professor's find-property exactly
  (define (find-property which stx-list)
    (for/first ([stx (in-list (syntax->list stx-list))]
                #:when (and (syntax->list stx)
                            (eq? which (syntax->datum
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
; (define cave (make-room "cave" '("a" "b") '() '() 0 0 10 10))
(define-macro (room-def FEATURE ...)
  (with-pattern
      ([NAME-PARTS  (or (find-property 'rname      #'(FEATURE ...)) #'())]
       [SIZE-PARTS  (or (find-property 'size       #'(FEATURE ...)) #'())]
       [CHARS-PARTS (or (find-property 'characters #'(FEATURE ...)) #'())]
       [ITEMS-PARTS (or (find-property 'room-items #'(FEATURE ...)) #'())]
       [LINK-PARTS  (or (find-property 'links      #'(FEATURE ...)) #'())])
 
    ; pull the single name string (first child of rname node)
    (define name-stx
      (let ([parts (syntax->list #'NAME-PARTS)])
        (if (null? parts) #'"unnamed" (car parts))))
 
    ; pull size coords; default to 0 0 10 10 if size absent
    (define size-list (syntax->list #'SIZE-PARTS))
    (define x1-stx (if (>= (length size-list) 4) (list-ref size-list 0) #'0))
    (define y1-stx (if (>= (length size-list) 4) (list-ref size-list 1) #'0))
    (define x2-stx (if (>= (length size-list) 4) (list-ref size-list 2) #'10))
    (define y2-stx (if (>= (length size-list) 4) (list-ref size-list 3) #'10))
     ; build one (make-connection ...) form per link child
    ; example: ((link "Armory" 10 5) (link "Garden" 5 0)) is LINK-PARTS, get 
    (define conn-exprs
      (map (lambda (ln)
             (define parts (syntax->list ln))
             (define dest (cadr  parts)) 
             (define dx   (caddr parts))
             (define dy   (cadddr parts))
             #`(make-connection #,dest #,dx #,dy))
           (syntax->list #'LINK-PARTS)))
 
    ; chars and items are flat string lists
    (define char-stxs (syntax->list #'CHARS-PARTS))
    (define item-stxs (syntax->list #'ITEMS-PARTS))
 
    ; assemble final syntax — everything runs at RUNTIME (phase 0)
    (with-syntax ([ROOM-NAME          name-stx]
                  [X1                 x1-stx]
                  [Y1                 y1-stx]
                  [X2                 x2-stx]
                  [Y2                 y2-stx]
                  [(CONN-EXPR ...) (datum->syntax #'(FEATURE ...) conn-exprs)]
                  [(CHAR-STR ...)  (datum->syntax #'(FEATURE ...) char-stxs)]
                  [(ITEM-STR ...)  (datum->syntax #'(FEATURE ...) item-stxs)])
      #'(room-register!
         (make-room
          ROOM-NAME
          (list CONN-EXPR ...)
          (list CHAR-STR ...)
          (list ITEM-STR ...)
          X1 Y1 X2 Y2)))))

;start-def
(define-macro (start-def FEATURE ...)
  (displayln "making main!")
  (with-pattern
      ([(ROOM)  (find-property 'start-room      #'(FEATURE ...))]
       [(TITLE)  (find-property 'start-title      #'(FEATURE ...))]
       [INTRO  (find-property 'start-intro      #'(FEATURE ...))])

        #'(make-main ROOM
                     TITLE
                    'INTRO)))


; ITEM MACRO
(define-macro (item-def FEATURE ...)
  (with-pattern
      ([(ITEM_NAME)   (find-property 'item-name    #'(FEATURE ...))]
       [(ITEM_DESC)   (find-property 'item-desc    #'(FEATURE ...))]
       [(ITEM_VALUE)  (find-property 'item-value   #'(FEATURE ...))]
       [(ACTIONS ...)  (find-property 'item-actions #'(FEATURE ...))])
    #'(begin
        (item-register!
         (make-item ITEM_NAME ITEM_DESC ITEM_VALUE (list (string->symbol ACTIONS) ...)))
        (displayln (format "registered item: ~a" ITEM_NAME)))))


;QUEST MACRO
(define-macro (quest-block FEATURE ...)
  (with-pattern
      ([(QUEST_DESC)  (find-property 'quest-name    #'(FEATURE ...))]
       [(TARGET ...)  (find-property 'quest-targets #'(FEATURE ...))]
       [(REWARD ...)  (find-property 'quest-rewards #'(FEATURE ...))]
       [(QUEST_GIVER) (find-property 'quest-giver   #'(FEATURE ...))])
    #'(begin
        (quest-register!
         (make-quest QUEST_DESC (list TARGET ...) (list REWARD ...) QUEST_GIVER))
        (quest-assign! QUEST_DESC))))


;CHARACTER MACRO (MOST COMPLEX SO CREATE SIMPLE MACRO)
(define-macro (character-def FEATURE ...)
  (with-pattern
      ([(CNAME)          (find-property    'rname          #'(FEATURE ...))]
       [(ITEM-STR ...)   (find-property    'char-items     #'(FEATURE ...))]
       [(DIAL-DEF ...)   (find-definitions 'dialogue-block #'(FEATURE ...))]
       [(QUEST-DEF ...)  (find-definitions 'quest-block    #'(FEATURE ...))])
    #'(begin
        (npc-register!
         (make-npc CNAME
                   (if (null? '(DIAL-DEF ...))
                       '(() ())
                       (car (list DIAL-DEF ...)))
                   '()
                   (filter-map item-find (list ITEM-STR ...))))
        QUEST-DEF ...)))

; DIALOGUE MACROS, NESTED WITHIN CHARACTER MACRO 3 MACROS BUILDING ON EACH OTHER, BOTTOM UP

;FIRST, CREATE OPTIONS IN DIALOGUE TREE - added find nexet node, to look up next node at runtime
;Explanation for change: instead of trying to pass the next node at compile time,
;we look it up at runtime by name from the registry, same pattern as room-find and item-find.
; so if dialogue ends from node, go back before to like "bye" node to end
(define-macro (option FEATURE ...)
  (with-pattern
      ([(OPLAYER)  (find-property 'opt-player #'(FEATURE ...))]
       [(LINE ...) (find-property 'npc-lines  #'(FEATURE ...))]
       [(NEXT)     (find-property 'next-node  #'(FEATURE ...))])
    #'(make-option OPLAYER (list LINE ...) 
                   (lambda () (find-dialogue-node NEXT)))))

;dialogue-node (in parse tree named dial-node so named it that) - now changed dial-node to register itself to make dialogue link
(define-macro (dial-node NODE-NAME FEATURE ...)
  (with-pattern
      ([(LINE ...)    (find-property    'npc-lines #'(FEATURE ...))]
       [(OPT-DEF ...) (find-definitions 'option    #'(FEATURE ...))])
    #'(let ((node (make-dialogue-node (list LINE ...) (list OPT-DEF ...))))
        (register-dialogue-node! NODE-NAME node)
        node)))

;dialogue-block (seraches for 'dial-node from parse tree)
(define-macro (dialogue-block FEATURE ...)
  (with-pattern
      ([(NODE-DEF ...) (find-definitions 'dial-node #'(FEATURE ...))])
    #'(car (list NODE-DEF ...))))

; top-level: expands the whole program
; (program room-defn ... char-defn ...)
; (#%module-begin (define cave ...) (define windy-hall ...) ...)
(define-macro (tada-macro-begin (program DEFN ...))
  ;(with-pattern
      ;([(ROOM-DEFN ...)  (find-definitions 'room-def      #'(DEFN ...))]
       ;[(CHAR-DEFN ...)  (find-definitions 'character #'(DEFN ...))])
    #'(#%module-begin
;       (displayln "=== expander running ===")
;       (displayln (format "defns found: ~a" '(DEFN ...)))
       DEFN ...))
       ; CHAR-DEFN ...
       
;       (displayln "=== done ===")))


(provide read-syntax)
(provide (rename-out [tada-macro-begin #%module-begin]))
(provide room-def character make-room start-def item-def quest-block character-def option dial-node dialogue-block  register-dialogue-node! find-dialogue-node)