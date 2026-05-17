#lang br 
(require brag/support)
(define-lex-abbrev digits (:+ (char-set "0123456789")))
(define basic-lexer
  (lexer-srcloc
   [whitespace (token lexeme #:skip? #t)] ; skip whitespace
   [(from/stop-before ";" "\n") (token lexeme #:skip? #t)] ; skip comments

   ; punctuation tokens
   ["{" (token 'LBRACE lexeme)]
   ["}" (token 'RBRACE lexeme)]
   ["(" (token 'LPAREN lexeme)]
   [")" (token 'RPAREN lexeme)]
   [":" (token 'COLON lexeme)]
   ["," (token 'COMMA lexeme)]

   ; waveform system tokens
   ["waveform" (token 'WAVEFORM lexeme)] ; defines a waveform
   ["wavetype" (token 'WAVETYPE lexeme)]
   ["filter" (token 'FILTER lexeme)]
   ["frequency" (token 'FREQUENCY lexeme)]
   ;["total-mass" (token 'MASS lexeme)]
   
   ; simulation tokens
   ["display" (token 'DISPLAY lexeme)]
   ["width" (token 'WIDTH lexeme)]
   ["height" (token 'HEIGHT lexeme)]
   ["title" (token 'TITLE lexeme)]

   ["visualize" (token 'VISUALIZE lexeme)]

   ; data structures
   [(:seq alphabetic (:* (:or alphabetic numeric "$")))
    (token 'ID (string->symbol lexeme))] ; identifier
   [(:seq (:? "-") digits) (token 'INTEGER (string->number lexeme))]
   [(:or (from/to "\"" "\"") (from/to "'" "'"))
     (token 'STRING
            (substring lexeme
                        1 (sub1 (string-length lexeme)
    )))])) ; integer
   

   

(provide basic-lexer)
