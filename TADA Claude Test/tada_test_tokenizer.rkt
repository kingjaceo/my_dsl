#lang racket
(require brag/support)

(define adventure-lexer
  (lexer
   ; ── whitespace & line comments ──────────────────────────────────
   [whitespace                           (token lexeme #:skip? #t)]
   [(:: ";" (:* (:~ #\newline)) #\newline) (token lexeme #:skip? #t)]
   ; ── punctuation ─────────────────────────────────────────────────
   ["{"  (token 'LBRACE   lexeme)]
   ["}"  (token 'RBRACE   lexeme)]
   ["["  (token 'LBRACKET lexeme)]
   ["]"  (token 'RBRACKET lexeme)]
   [","  (token 'COMMA    lexeme)]
   [":"  (token 'COLON    lexeme)]
   ; ── quoted strings ───────────────────────────────────────────────
   [(:: #\" (:* (:~ #\")) #\")
    (token 'STRING (substring lexeme 1 (- (string-length lexeme) 1)))]
   ; ── numbers ──────────────────────────────────────────────────────
   [(:+ numeric) (token 'NUMBER (string->number lexeme))]
   ; ── top-level section keywords ───────────────────────────────────
   ["create_room"      (token 'ROOM       lexeme)]
   ["create_character" (token 'CHARACTER  lexeme)]
   ["create_item"      (token 'ITEM-DEF   lexeme)]
   ["start_game"       (token 'START-GAME lexeme)]
   ; ── shared property keywords ─────────────────────────────────────
   ["name"    (token 'NAME    lexeme)]
   ["items"   (token 'ITEMS   lexeme)]
   ; ── room-only property keywords ──────────────────────────────────
   ["size"       (token 'SIZE       lexeme)]
   ["characters" (token 'CHARACTERS lexeme)]
   ["links"      (token 'LINKS      lexeme)]
   ; ── character-only property keywords ────────────────────────────
   ["room"      (token 'ROOM-PROP lexeme)]
   ["dialogue"  (token 'DIALOGUE  lexeme)]
   ["quest"     (token 'QUEST     lexeme)]
   ; ── dialogue structural keywords ─────────────────────────────────
   ["node"   (token 'NODE   lexeme)]
   ["option" (token 'OPTION lexeme)]
   ["npc"    (token 'NPC    lexeme)]
   ["next"   (token 'NEXT   lexeme)]
   ; ── quest structural keywords ────────────────────────────────────
   ["targets" (token 'TARGETS lexeme)]
   ["rewards" (token 'REWARDS lexeme)]
   ["giver"   (token 'GIVER   lexeme)]
   ; ── item structural keywords ─────────────────────────────────────
   ["desc"    (token 'DESC    lexeme)]
   ["value"   (token 'VALUE   lexeme)]
   ["actions" (token 'ACTIONS lexeme)]
   ; ── start_game property keywords ─────────────────────────────────
   ["title"   (token 'TITLE   lexeme)]
   ["intro"   (token 'INTRO   lexeme)]))

(define (make-tokenizer ip [path #f])
  (port-count-lines! ip)
  (lexer-file-path path)
  (define (next-token) (adventure-lexer ip))
  next-token)

(provide make-tokenizer)