#lang brag
 
program      : section*
 
section      : SECTION LBRACE entry* RBRACE
 
entry        : LBRACE field+ RBRACE
 
field        : KEY scalar-val
             | KEY list-val
             | KEY nested-block
             | KEY
 
scalar-val   : VALUE
 
list-val     : LBRACKET list-items RBRACKET
list-items   : VALUE (COMMA VALUE)*
 
nested-block : LBRACE field+ RBRACE
 