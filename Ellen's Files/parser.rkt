#lang brag
; ── top level ────────────────────────────────────────────────────────
program  : section*
@section : room-def | character-def | item-def | start-def
; ── room ─────────────────────────────────────────────────────────────
room-def   : /ROOM      /LBRACE room-prop*  /RBRACE
@room-prop : rname | size | characters | room-items | links
rname      : /NAME       STRING
size       : /SIZE       NUMBER NUMBER NUMBER NUMBER
characters : /CHARACTERS /LBRACKET str-list /RBRACKET
room-items : /ITEMS      /LBRACKET str-list /RBRACKET
links      : /LINKS      /LBRACE   link*   /RBRACE
link       : STRING /COLON NUMBER NUMBER
; ── character ────────────────────────────────────────────────────────
character-def : /CHARACTER /LBRACE char-prop*  /RBRACE
@char-prop    : rname | char-room | char-items | dialogue-block | quest-block
char-room  : /ROOM-PROP STRING
char-items : /ITEMS /LBRACKET str-list /RBRACKET
; ── dialogue tree ────────────────────────────────────────────────────
dialogue-block : /DIALOGUE /LBRACE  dial-node*  /RBRACE
dial-node      : /NODE STRING /LBRACE npc-lines option* /RBRACE
npc-lines      : /NPC    /LBRACKET str-list /RBRACKET
option         : /OPTION /LBRACE opt-player npc-lines next-node /RBRACE
opt-player     : STRING
next-node      : /NEXT STRING
; ── quest ────────────────────────────────────────────────────────────
quest-block   : /QUEST /LBRACE quest-prop* /RBRACE
@quest-prop   : quest-name | quest-targets | quest-rewards | quest-giver
quest-name    : /NAME    STRING
quest-targets : /TARGETS /LBRACKET str-list /RBRACKET
quest-rewards : /REWARDS /LBRACKET str-list /RBRACKET
quest-giver   : /GIVER   STRING
; ── standalone item ──────────────────────────────────────────────────
item-def     : /ITEM-DEF /LBRACE item-prop* /RBRACE
@item-prop   : item-name | item-desc | item-value | item-actions
item-name    : /NAME    STRING
item-desc    : /DESC    STRING
item-value   : /VALUE   NUMBER
item-actions : /ACTIONS /LBRACKET str-list /RBRACKET
; ── start ────────────────────────────────────────────────────────────
start-def    : /START /LBRACE start-prop* /RBRACE
@start-prop  : start-room | start-title | start-intro
start-room   : /START-ROOM  STRING
start-title  : /START-TITLE STRING
start-intro  : /START-INTRO /LBRACKET str-list /RBRACKET
; ── shared ───────────────────────────────────────────────────────────
@str-list : [STRING (/COMMA STRING)*]
