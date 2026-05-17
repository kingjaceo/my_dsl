#lang br/quicklang
(require "parser.rkt"
         "tokenizer.rkt"
         brag/support)

(define (read-syntax src port)
  (define parse-tree (parse src (make-tokenizer port)))
  (strip-context parse-tree))

(provide read-syntax)