#lang br/quicklang
(require "tada_test_racket.rkt")

; ============================================================
;                         PROGRAM
; ============================================================

(define-macro (program SECTION ...)
  #'(#%module-begin SECTION ...))


; ============================================================
;                   COMPILE-TIME HELPERS
; ============================================================

(begin-for-syntax
  (require racket/list)

  (define (find-val tag prop-stxs)
    (for/first ([stx (in-list (syntax->list prop-stxs))]
                #:when (and (syntax->list stx)
                            (eq? tag (syntax->datum (car (syntax->list stx))))))
      (cadr (syntax->list stx))))

  (define (find-kids tag prop-stxs)
    (or (for/first ([stx (in-list (syntax->list prop-stxs))]
                    #:when (and (syntax->list stx)
                                (eq? tag (syntax->datum (car (syntax->list stx))))))
          (cdr (syntax->list stx)))
        '()))

  (define (find-node tag prop-stxs)
    (for/first ([stx (in-list (syntax->list prop-stxs))]
                #:when (and (syntax->list stx)
                            (eq? tag (syntax->datum (car (syntax->list stx))))))
      stx)))


; ============================================================
;                        ROOM-DEF
; ============================================================

(define-macro (room-def PROP ...)
  (with-pattern
    ([NAME       (find-val  'rname      #'(PROP ...))]
     [(SZ ...)   (find-kids 'size       #'(PROP ...))]
     [(CHAR ...) (find-kids 'characters #'(PROP ...))]
     [(ITEM ...) (find-kids 'room-items #'(PROP ...))]
     [LNKS       (or (find-node 'links #'(PROP ...)) #'(links))])
    #'(room-register!
       (make-room NAME
                  LNKS
                  (list CHAR ...)
                  (map string->floor-item (list ITEM ...))
                  (list-ref (list SZ ...) 0)
                  (list-ref (list SZ ...) 1)
                  (list-ref (list SZ ...) 2)
                  (list-ref (list SZ ...) 3)))))

(define-macro (links LINK-FORM ...)
  #'(list LINK-FORM ...))

(define-macro (link NAME X Y)
  #'(make-connection NAME X Y))


; ============================================================
;                      CHARACTER-DEF
; ============================================================

(define-macro (character-def PROP ...)
  (with-pattern
    ([NAME        (find-val  'rname          #'(PROP ...))]
     [(ITEM ...)  (find-kids 'char-items     #'(PROP ...))]
     [DLG         (or (find-node 'dialogue-block #'(PROP ...)) #'(dialogue-block))]
     [QST         (or (find-node 'quest-block    #'(PROP ...)) #'(quest-block))])
    #'(begin
        QST
        (npc-register!
         (make-npc NAME
                   DLG
                   '()
                   (map string->floor-item (list ITEM ...)))))))


; ── Dialogue macros ──────────────────────────────────────────

(define-macro (dialogue-block NODE ...)
  #'(build-dialogue-nodes (list NODE ...)))

(define-macro (dial-node NAME NPC-FORM OPT ...)
  #'(list NAME NPC-FORM (list OPT ...)))

(define-macro (npc-lines LINE ...)
  #'(list LINE ...))

(define-macro (option OPT-PLAYER NPC-FORM NEXT)
  #'(list OPT-PLAYER NPC-FORM NEXT))

(define-macro (opt-player TEXT)
  #'TEXT)

(define-macro (next-node NAME)
  #'NAME)


; ── Quest macro ──────────────────────────────────────────────

(define-macro (quest-block PROP ...)
  (let ([qname-stx (find-val 'quest-name #'(PROP ...))])
    (if qname-stx
        (with-pattern
          ([QNAME       qname-stx]
           [(TGTS ...)  (find-kids 'quest-targets #'(PROP ...))]
           [(RWDS ...)  (find-kids 'quest-rewards  #'(PROP ...))]
           [GIVER       (find-val  'quest-giver    #'(PROP ...))])
          #'(quest-register!
             (make-quest QNAME
                         (list TGTS ...)
                         (map string->floor-item (list RWDS ...))
                         GIVER)))
        #'(void))))


; ============================================================
;                        ITEM-DEF
; ============================================================

(define-macro (item-def PROP ...)
  (with-pattern
    ([INAME      (find-val  'item-name    #'(PROP ...))]
     [IDESC      (find-val  'item-desc    #'(PROP ...))]
     [IVAL       (find-val  'item-value   #'(PROP ...))]
     [(ACT ...)  (find-kids 'item-actions #'(PROP ...))])
    #'(item-register!
       (make-item INAME IDESC IVAL (map string->symbol (list ACT ...))))))


; ============================================================
;                       START-DEF
; ============================================================

; Expands to (make-main (room-find "...") "title" (list "line" ...))
; which is exactly what the manual example calls at the bottom.
; define-macro auto-provides this — do not add it to the provide above.

(define-macro (start-def PROP ...)
  (with-pattern
    ([SROOM        (find-val  'start-room  #'(PROP ...))]
     [STITLE       (find-val  'start-title #'(PROP ...))]
     [(SLINES ...) (find-kids 'start-intro #'(PROP ...))])
    #'(make-main (room-find SROOM)
                 STITLE
                 (list SLINES ...))))


; ============================================================
;                     RUNTIME HELPERS
; ============================================================

(define pre-items (make-hash))

(define (item-register! item)
  (hash-set! pre-items (item-name item) item))

(define (string->floor-item name)
  (hash-ref pre-items name
            (lambda ()
              (make-item name (string-append "A " name ".") 0 '(take drop inspect)))))

(define (build-dialogue-nodes node-specs)
  (if (null? node-specs)
      (make-dialogue-node '() '())
      (let ([spec-hash (make-hash)])
        (for ([spec node-specs])
          (hash-set! spec-hash (car spec) spec))

        (define (build-options opt-specs)
          (map (lambda (opt)
                 (define player-text (car opt))
                 (define opt-npc     (cadr opt))
                 (define next-name   (caddr opt))
                 (define next-spec   (hash-ref spec-hash next-name #f))
                 (define combined-npc
                   (if next-spec (append opt-npc (cadr next-spec)) opt-npc))
                 (define next-opts
                   (if next-spec (build-options (caddr next-spec)) '()))
                 (make-option player-text combined-npc next-opts))
               opt-specs))

        (let ([entry (car node-specs)])
          (make-dialogue-node (cadr entry)
                              (build-options (caddr entry)))))))


(provide (rename-out [program #%module-begin]))
(provide room-def character-def item-def start-def
         links link
         dialogue-block dial-node npc-lines option opt-player next-node
         quest-block)