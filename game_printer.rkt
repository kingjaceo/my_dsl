#lang racket
(provide print-world)

;;lol this whole printing was from AI
 
;; Indent helper
(define (indent n) (make-string (* n 2) #\space))
 
;; Print a scalar, list, or nested-block value at a given depth
(define (print-val key val depth)
  (cond
    ;; inline list → one {key:item} per element
    [(list? val)
     (for ([item val])
       (printf "~a{~a:~a}~n" (indent depth) key item))]
 
    ;; nested block (hash) → recurse
    [(hash? val)
     (printf "~a{~a:~n" (indent depth) key)
     (for ([(k v) (in-hash val)])
       (print-val k v (+ depth 1)))
     (printf "~a}~n" (indent depth))]
 
    ;; plain scalar — skip empty values
    [(not (string=? val ""))
     (printf "~a{~a:~a}~n" (indent depth) key val)]))
 
;; Print all entries — each with an id gets wrapped as {id:<n>: ... }
(define (print-entries entries depth)
  (for ([entry entries])
    (define id   (hash-ref entry "id" #f))
    (define rest (if id (hash-remove entry "id") entry))
    (cond
      ;; entry has an id → open {id:name: , print inner fields, close }
      [id
       (printf "~a{id:~a:~n" (indent depth) id)
       (for ([(k v) (in-hash rest)])
         (print-val k v (+ depth 1)))
       (printf "~a}~n~n" (indent depth))]
      ;; no id → print fields flat at current depth
      [else
       (for ([(k v) (in-hash entry)])
         (print-val k v depth))])))
 
;; Print the full world
(define (print-world sections)
  (for ([section sections])
    (define type    (hash-ref section "type"))
    (define entries (hash-ref section "entries" '()))
    (printf "{~a:~n" type)
    (print-entries entries 1)
    (printf "}~n~n")))
 