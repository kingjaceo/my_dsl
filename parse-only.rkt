#lang br/quicklang
(require "parser.rkt"
         "game_tokenizer.rkt"
         brag/support)

;               READER

(provide (rename-out [my-read read]
                     [my-read-syntax read-syntax]))

(define (my-read in)
  (syntax->datum (my-read-syntax #f in)))

(define (my-read-syntax path port)
  (define tree (parse path (make-tokenizer port path)))
  (define datum (syntax->datum tree))

  ; print each section on its own line
  (for ([section (cdr datum)])
    (writeln section)
    (newline))

  ; wrap in a valid module so Racket accepts it
  (datum->syntax #f
    `(module example racket
       (quote ,datum))))