#lang racket
 
;;; ============================================================
;;;  Tokenizer — brace-delimited, indentation-independent
;;;
;;;  SECTION vs KEY rule:
;;;    known section names → SECTION
;;;    everything else     → KEY
;;; ============================================================
 
(require br-parser-tools/lex
         (prefix-in : br-parser-tools/lex-sre)
         brag/support)
 
(provide make-tokenizer)
 
;; ── Known section names ──────────────────────────────────────
;; Add any new top-level sections here
(define section-names
  '("create_room" "create_items" "create_events"
    "create_actions" "create_char"))
 
(define (section-name? s)
  (member s section-names))
 
;; ── Lexer abbreviations ──────────────────────────────────────
(define-lex-abbrevs
  [id-start  (:or alphabetic (char-set "_"))]
  [id-char   (:or id-start numeric (char-set "_-.()"))]
  [id        (:seq id-start (:* id-char))]
  [quoted    (:seq #\" (:* (:~ #\" #\newline)) #\")]
  [bare-val  (:seq (:~ #\: #\[ #\] #\, #\{ #\} #\newline #\" #\space #\tab)
                   (:* (:~ #\: #\[ #\] #\, #\{ #\} #\newline #\")))]
  [hspace    (:+ (:or #\space #\tab))])
 
;; ── Lexer ────────────────────────────────────────────────────
(define adventure-lexer
  (lexer-src-pos
 
   ;; Skip all whitespace and newlines
   [(:or hspace "\n" "\r\n" "\r")
    (return-without-pos (adventure-lexer input-port))]
 
   ;; Braces
   ["{"  (token 'LBRACE "{")]
   ["}"  (token 'RBRACE "}")]
 
   ;; word followed by colon — check against known section names
   [(:seq id #\:)
    (let ([name (substring lexeme 0 (- (string-length lexeme) 1))])
      (if (section-name? name)
          (token 'SECTION name)
          (token 'KEY     name)))]
 
   ;; Quoted string
   [quoted
    (token 'VALUE (substring lexeme 1 (- (string-length lexeme) 1)))]
 
   ;; Bare word
   [bare-val
    (token 'VALUE (string-trim lexeme))]
 
   ;; List punctuation
   ["["  (token 'LBRACKET "[")]
   ["]"  (token 'RBRACKET "]")]
   [","  (token 'COMMA    ",")]
 
   [(eof) (token 'EOF "eof")]))
 
;; ── Public constructor ───────────────────────────────────────
(define (make-tokenizer str)
  (define port (open-input-string str))
  (port-count-lines! port)
  (λ ()
    (define tok (adventure-lexer port))
    (if (eq? (position-token-token tok) 'EOF)
        #f
        tok)))