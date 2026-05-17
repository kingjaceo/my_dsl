#lang racket
(require "parser.rkt"
         "game_tokenizer.rkt"
         brag/support)

(define test-input
#<<END
create_item {
  name "Gold Coin"
  desc "A shiny gold coin."
  value 10
  actions ["take", "drop", "inspect"]
}

create_room {
  name "Entrance Hall"
  size 0 0 10 10
  characters ["Guard"]
  items ["Torch"]
  links {
    "Armory": 10 5
  }
}

create_start {
  start_room "Entrance Hall"
  title "A Simple Adventure"
  intro ["You wake up.", "Look around."]
}
END
)

(define port (open-input-string test-input))
(define tree (parse #f (make-tokenizer port #f)))
(pretty-print (syntax->datum tree))