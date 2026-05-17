#lang brag

racksound : [instrument] [visu-defn] vizualize
instrument : [wavetype] [frequency] [FILTER]
; system
inst-defn: /INST ID /LBRACE (features)* /RBRACE
@features: wavetype | frequency | filter
filter: /FILTER /COLON STRING
frequency : /FREQUENCY /COLON INTEGER
wavetype : /WAVETYPE /COLON STRING


visu-defn: /VISUALIZER /LBRACE (visu-configs)* /RBRACE
@visu-configs: width | height | title | type
width: /WIDTH /COLON INTEGER
height: /HEIGHT /COLON INTEGER
title : /TITLE /COLON STRING
type : /TYPE /COLON STRING

vizualize : /VISUALIZE

#|rsnd-program : [rsnd-line] (/NEWLINE [rsnd-line])*
;@rsnd-line : [rsnd-statement]  ;([rsnd-statement] [rsnd-inst | rsnd-strum | rsnd-tone])*
;@rsnd-statement : play | stop | speed |rsnd-loop
;@rsnd-dec : inst
;@rsnd-loop: "REPEAT" INTEGER /NEWLINE (rsnd-line [/NEWLINE])* "REPEND" 

;@rsnd-line-num : INTEGER
;play   : /"PLAY" [rsnd-tone] (/COMMA [rsnd-tone])*
;stop   : /"STOP"
;speed  : /"SPEED" ;SPEED vs BPM?
;playTogether : /"*PLAY" [rsnd-tone] /COMMA ([rsnd-tone])*
;repeat : /"REPEAT" INTEGER
;epend : /"REPEND" 
;inst   : /"INSTRUMENT" [rsnd-inst]
;bpm    : /"SET BPM" INTEGER

;@rsnd-inst : STRUMTYPE
; alt inst definition -
;@rsnd-inst     : [rsnd-inst-ref] [rsnd-strum]
;@rsnd-inst-ref : STRING
;@rsnd-strum    : STRING
 

 ; ignore in expander
;@rsnd-tone : STRUMTYPE NOTE
;@rsnd-tone : STRING
; @rsnd-note : STRING
;@rsnd-rem : [rsnd-tone] | INTEGER | VOID ; unsure what this bit even is
;@rsnd-tone : inst [rsnd-note] ;@rsnd-tone : (/"[" [inst] [rsnd-note] /"]")


; defining statements
#|rsnd-line : line-num [statement] [rsnd-arg]*
;rsnd-program : [rsnd-line] (/NEWLINE [rsnd-line])*
;rsnd-arg : INTEGER | strum | key 
;@line-num : INTEGER
;@statement : inst | play | stop | speed | playTogether | repeat

;inst   : "INSTRUMENT" strum
;play   : "PLAY" strum key 
;stop   : "STOP"  INTEGER
;speed  : "SPEED" INTEGER
;playTogether  : "PLAY-TOGETHER" strum key strum key 
;repeat : "REPEAT" INTEGER
;repend : "END" ;

;key    :  STRING
;strum  : "TRUMPET" | "PIANO" | "DRUM" | "FLUTE" | "PURE"  ;and so on.

; @ = unwraps a redundant statement line, basically stops from each line being in layered parentheses
; / = "Ignorer", parser throws away after.
; to my knowledge '@' is moreso for readability, since it just "hides" the stuff.
