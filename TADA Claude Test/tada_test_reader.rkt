#lang br/quicklang
(require "tada_test_parser.rkt"
         "tada_test_tokenizer.rkt"
         brag/support)

(define (read-syntax src port)
  (define parse-tree (parse src (make-tokenizer port src)))
  (strip-context
   #`(module game-module "tada_test_expander.rkt"
       #,@(cdr (syntax->list parse-tree)))))

(provide read-syntax)