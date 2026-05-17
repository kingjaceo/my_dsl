#lang br/quicklang
(require brag/support)

(define (make-tokenizer port)
  (define (next-token)
    (define verbs    '("move" "take" "talk" "examine" "enter" "exit" "pickup" "put"))
    (define articles '("a" "an" "the"))
    (define preps    '("backward" "forward" "right" "left" "into" "onto" "with" "at" "on"))

    (define (verb? w)    (member w verbs))
    (define (article? w) (member w articles))
    (define (prep? w)    (member w preps))
    (define (noun? w)    (not (or (verb? w) (article? w) (prep? w))))

    (define tok (read port))  ; read one whitespace-delimited token

    (cond
      [(eof-object? tok) eof]
      [else
       (define w (string-downcase (format "~a" tok)))
       (cond
         [(verb? w)    (token 'VERB w)]
         [(article? w) (token 'ARTICLE w)]
         [(prep? w)    (token 'PREP w)]
         [(noun? w)    (token 'NOUN w)]
         [else (token 'UNKNOWN w)])]))

  next-token)   ; <-- make-tokenizer returns the thunk

(provide make-tokenizer)