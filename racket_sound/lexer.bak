#lang br 
(require brag/support)

;(define-lex-abbrev keyfamily (:+ (char-set "ABCDEFG")))
;(define-lex-abbrev octave (:+ (char-set "12345678")))
;we're doing octaves 0-8 here.
(define-lex-abbrev note
  (:: (:or (char-set "ABCDEFG")) (:or (char-set "12345678"))))
(define-lex-abbrev strum (:or "PIANO" "DRUM" "SINE"))

(define basic-lexer
  (lexer-srcloc
    ["\n" (token 'NEWLINE lexeme)]
    [whitespace (token lexeme #:skip? #t)]
    [(from/stop-before ";" "\n") (token 'COMMENT lexeme)]
    ;[(:or "INSTRUMENT" "PLAY" "STOP" "SPEED" "REPEAT" "END" "PLAY*") (token lexeme lexeme)]
    [strum     (token 'STRUMTYPE lexeme)]
    [note      (token 'NOTE lexeme)]
    [(:+ (char-set "0123456789")) (token 'INTEGER (string->number lexeme))]
    [#\[          (token 'LBRACKET)]
    [#\]          (token 'RBRACKET)]
    [#\,          (token 'COMMA)]
    ["INSTRUMENT" (token 'INSTRUMENT lexeme)]
    ["PLAY" (token 'PLAY lexeme)]
    ["STOP" (token 'STOP lexeme)]
    ["SPEED" (token 'SPEED lexeme)]
    ["REPEAT" (token 'REPEAT lexeme)]
    ["REPEND" (token 'REPEND lexeme)]
    ;["*PLAY" (token 'PLAYTOGETHER lexeme)]
    ["," (token 'COMMA lexeme)]

    
    [(:or (from/to "\"" "\"") (from/to "'" "'"))
     (token 'STRING
            (substring lexeme
                        1 (sub1 (string-length lexeme)
    )))]
))

(provide basic-lexer)