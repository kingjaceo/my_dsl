#lang br/quicklang
(require "parser.rkt"
         "game_tokenizer.rkt"
         brag/support)

(provide (rename-out [my-read-syntax read-syntax]
                     [my-read read]))

(define (my-read in)
  (syntax->datum (my-read-syntax #f in)))

(define (my-read-syntax path port)
  (define tree  (parse path (make-tokenizer port path)))
  (datum->syntax #f
    `(module game-world "expander.rkt"
       ,(syntax->datum tree))))