#lang racket
 
(require brag/support
         (prefix-in grammar: "grammar.rkt"))
 
(provide parse interpret-tree)
 
(define (parse token-thunk)
  (grammar:parse #f token-thunk))
 
(define (stx->list stx) (syntax->list stx))
(define (stx->val  stx) (syntax->datum stx))
 
(define (interpret-tree tree)
  (define top (stx->list tree))
  (define sections
    (cond
      [(and top (eq? (stx->val (car top)) 'program)) (cdr top)]
      [else top]))
  (map interp-section sections))
 
(define (interp-section sec)
  (define parts (stx->list sec))
  (define name    (stx->val (cadr parts)))
  (define entries (filter (λ (s) (and (stx->list s)
                                      (eq? (stx->val (car (stx->list s))) 'entry)))
                          parts))
  (hash "type"    name
        "entries" (map interp-entry entries)))
 
(define (interp-entry e)
  (define parts (stx->list e))
  (define fields (filter (λ (s) (and (stx->list s)
                                     (eq? (stx->val (car (stx->list s))) 'field)))
                         parts))
  ;; use immutable hash so hash-remove in printer works
  (for/fold ([h (hash)])
            ([f fields])
    (define kv (interp-field f))
    (hash-set h (car kv) (cadr kv))))
 
(define (interp-field f)
  (define parts (stx->list f))
  (define key (stx->val (cadr parts)))
  (define rest (cddr parts))
  (cond
    [(null? rest)
     (list key "")]
    [else
     (define val-node  (car rest))
     (define val-parts (stx->list val-node))
     (define val-type  (stx->val (car val-parts)))
     (cond
       ;; scalar-val
       [(eq? val-type 'scalar-val)
        (list key (stx->val (cadr val-parts)))]
 
       ;; list-val — filter out COMMA tokens, keep only VALUE strings
       [(eq? val-type 'list-val)
        (define items-node  (caddr val-parts))   ; list-items node
        (define item-parts  (stx->list items-node))
        (define values-only
          (filter (λ (s)
                    (let ([v (stx->val s)])
                      (and (string? v)
                           (not (string=? v ",")))))
                  (cdr item-parts)))             ; cdr skips 'list-items symbol
        (list key (map stx->val values-only))]
 
       ;; nested-block
       [(eq? val-type 'nested-block)
        (define sub-fields (filter (λ (s) (and (stx->list s)
                                               (eq? (stx->val (car (stx->list s))) 'field)))
                                   val-parts))
        (define sub
          (for/fold ([h (hash)])
                    ([sf sub-fields])
            (define kv (interp-field sf))
            (hash-set h (car kv) (cadr kv))))
        (list key sub)]
 
       [else (list key "?")])]))
 