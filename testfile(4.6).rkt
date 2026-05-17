#lang racket
(require rackunit
         "parser.rkt"
         "tokenizer.rkt"
         brag/support)

(define (parse-input str)
  (define port (open-input-string str))
  (syntax->datum (parse #f (make-tokenizer port))))

; passes silently, fails loudly
(check-equal? (parse-input "take sword")
              '(command (verb-phrase "take") (noun-phrase "sword")))

(check-equal? (parse-input "take the sword")
              '(command (verb-phrase "take") (noun-phrase "the" "sword")))

(check-equal? (parse-input "put key into chest")
              '(command (verb-phrase "put")
                        (noun-phrase "key")
                        (prep "into")
                        (noun-phrase "chest")))
