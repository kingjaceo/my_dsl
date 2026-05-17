#lang racket
;               ITEMS

; Item Constructor
(define (make-item name description value actions)
  
  (list name description value actions))

; Item Accessors
(define (item-name item) (list-ref item 0))
(define (item-desc item) (list-ref item 1))
(define (item-value item) (list-ref item 2))
(define (item-actions item) (list-ref item 3))

; Maybe give items coordinates

; check if an item can do the action
(define (item-can? item action)
  ; member returns a sublist instead when something is found, it returns false if nothing is found
  (member action (item-actions item)))


;               INVENTORY
; initialize inventory, list of lists
(define inventory '())

; add to inventory
(define (inventory-add! item)
  ; turn item into a list so we can append/add
  (set! inventory (append inventory (list item))))

(define (inventory-remove! name)
  
  (set! inventory
        ; goes through every item and filters/keeps the items if their name is NOT equal to name
        ; string-ci=?, ci means it is case insensative, =? means it is checking for equality

        (filter (lambda (i) (not (string-ci=? (item-name i) name)))
                inventory)))

(define (inventory-find name)
  ; claude assisted code
  ; findf takes a function/lambda as the arguemnt and tests each element
  ; string-ci=?, ci means it is case insensative, =? means it is checking for equality
  ; we search through inventory and check whether name is equal to name and returns true or false depending if anything was found
  (findf (lambda (i) (string-ci=? (item-name i) name))
         inventory))

; show player their inventory
(define (inventory-show)
  
  (cond
    ((null? inventory)
     (displayln "You have nothing in your inventory!")
     (displayln (format "Gold: ~a" player-gold)))
    
    (else
     (displayln "Your inventory:")
     
     (for ([item inventory])
       (displayln (format "  ~a" (item-name item))))
     (displayln (format "Gold: ~a" player-gold)))))

;     Gold/money

; set player gold
(define player-gold 0)

; add to player gold using mutability
(define (gold-add! amount)
  
  (set! player-gold (+ player-gold amount))
  (displayln (format "You now have ~a gold." player-gold)))

; spend gold
(define (gold-spend! amount)
  
  (set! player-gold (- player-gold amount)))



;               ACTIONS
; take
(define (take item)
  
  (cond
    ; check if the item can be taken, if so then add it to the inventory and let the user know
    ((item-can? item 'take)
     (inventory-add! item)
     (displayln (format "You took: ~a." (item-name item))))
    
    (else
     ; let the user know they cannot take the item
     (displayln (format "You cannot take: ~a." (item-name item))))))

; drop
(define (drop name)
  
  (let ((found (inventory-find name)))
    (cond
      ; check if the item was found
      ((not found)
       (displayln (format "You don't have: '~a'." name)))
      
      ; check if we can drop item (quest item or the item is cursed so it cannot be dropped)
      ((item-can? found 'drop)
       (inventory-remove! name)
       (displayln (format "You dropped: ~a." (item-name found))))
      
      (else
       (displayln (format "You can't drop: ~a." (item-name found)))))))

; inspect from inventory
(define (inspect-inventory name)
  
  (let ((found (inventory-find name)))
    (cond
      ; item not found
      ((not found)
       (displayln (format "You don't have: '~a'." name)))
      ; item found, check to see f you can inspect it
      ((item-can? found 'inspect)
       (displayln (format "=== ~a ===" (item-name found)))
       (displayln (format "Value: ~a" (item-value found)))
       (displayln (item-desc found)))   ; paren closes here instead

      (else
       (displayln (format "You can't inspect the: ~a." (item-name found)))))))

; inspect from room
; IMPLEMENT WHEN ROOMS ARE IMPLEMENETED



;inspect and detect NPC
; IMPLEMENT WHEN NPC ARE IMPLEMENETED


;               COORDINATE SYSTEM

; Construct coordinates imagine a 2d graph where the 3rd coordinate dictates the floor
(define (make-pos x y floor) (list x y floor))

(define (pos-x pos) (list-ref pos 0))
(define (pos-y pos) (list-ref pos 1))
(define (pos-floor pos) (list-ref pos 2))

; player position
(define player-pos (make-pos 0 0 0))

; display current position
(define (curr-pos)
  (displayln (format "Position -> x: ~a  y: ~a  floor: ~a"
                     (pos-x     player-pos)
                     (pos-y     player-pos)
                     (pos-floor player-pos))))

; set player position using mutability
(define (move! x y z)
  (set! player-pos
        (make-pos (+ (pos-x player-pos) x)
                  (+ (pos-y player-pos) y)
                  (+ (pos-floor player-pos) z))))

; movement actions
(define (move-right)
  (move! -1 0 0)
  (displayln "You move right"))

(define (move-left)
  (move! 1 0 0)
  (displayln "You move left"))

(define (move-forward)
  (move! 0 1 0)
  (displayln "You move forward"))

(define (move-backward)
  (move! 0 -1 0)
  (displayln "You move backward"))

; wander action IMPLEMENT CHECK FOR ROOM SIZE
(define (wander)
  ; generate random value to add 
  (let ((x (random 1 4))
        (y (random 1 4)))
    ; change player position based on the values
    (set! player-pos
          (make-pos (+ (pos-x player-pos) x)
                    (+ (pos-y player-pos) y)
                    (pos-floor player-pos)))
    (displayln "You wander around the room...")
    (curr-pos)))



;               ROOMS
; room constructor 
(define (make-room name connections characters items x1 y1 x2 y2) ; x and y are the room barriers. connections, characters, and items are lists

  (list name connections characters items x1 y1 x2 y2))

; accessors 
(define (room-name room) (list-ref room 0))

(define (room-connections room) (list-ref room 1))

(define (room-characters room) (list-ref room 2))

(define (room-items room) (list-ref room 3))

(define (room-x1 room) (list-ref room 4))

(define (room-y1 room) (list-ref room 5))

(define (room-x2 room) (list-ref room 6))

(define (room-y2 room) (list-ref room 7))



;               QUESTS

; quest constructor
; completed? is a flag that is initialized as false
(define (make-quest description target-room reward-items)
  
  (list description target-room reward-items #f))

(define (quest-desc quest) (list-ref quest 0))

(define (quest-target quest) (list-ref quest 1))

(define (quest-rewards quest) (list-ref quest 2))

(define (quest-completed? quest) (list-ref quest 3))

; mark a quest as complete, we rebuild the quest but this time we set the flag as true
(define (quest-complete! quest)
  
  (list (quest-desc quest) (quest-target quest) (quest-rewards quest) #t))


;               NPC
; npc constructor
; dialogue is a hash of (player-line npc-response) pairs, quests is a list of quests, items is a list of reward items
(define (make-npc name dialogue quests items)
  
  (list name dialogue quests items))

; accessors
(define (npc-name npc)     (list-ref npc 0))
(define (npc-dialogue npc) (list-ref npc 1))
(define (npc-quests npc)   (list-ref npc 2))
(define (npc-items npc)    (list-ref npc 3))

; all npcs
(define npcs '())

; add npc to npcs list using mutability
(define (npc-register! npc)
  
  (set! npcs (append npcs (list npc))))

; locate npc in list
(define (npc-find name)
  
  (findf (lambda (n) (string-ci=? (npc-name n) name)) npcs))

; dialogue helpers
; helpers were my idea but claude assisted in fleshing them out

; make-option makes potions in dialogue
; player-line npc-responses next-options -> option
; npc-responses is list of strings the npc says or it can be a lambda to react to game states
; next-options is list of further response options or '() which ends conversation
(define (make-option player-line npc-responses next-options)
  
  (list player-line npc-responses next-options))

; make-dialogue-node, nodes are used to divide parts of the conversation, so the greeting, quest talk and goodbye would have their own node
; npc-lines is a list of strings that the npc says
; options is a list of make-option aka responses
; use a hash to assign responses to options
(define (make-dialogue-node npc-lines options)
  
  (list npc-lines
        ; for loop with hash assigns the numbers to each option so the user does not have to
        (for/hash ((opt options)
                   (i (in-naturals 1)))
          (values i opt))))

; talk-to
(define (talk-to npc)
  (let loop ((node (npc-dialogue npc)))
    (let ((npc-lines (car node))
          (next-opts (cadr node)))
      
      ; loops through all npc lines and prints them before options appear
      (for ((line npc-lines))
        (displayln (format "~a: ~a" (npc-name npc) line)))

      ; checks if there are any options left, if '() is read then the conversation is over
      (cond
        ((or (null? next-opts)
             (and (hash? next-opts) (hash-empty? next-opts)))
         (void))
        (else
         ; loops over the options/hash, prints with corresponding number
         (for (((key val) (in-hash next-opts)))
           (displayln (format "  ~a. ~a" key (car val))))

         (let ((choice (read)))
           (cond
             ; hash-has-key checks if the inputted number exists in the hash
             ((hash-has-key? next-opts choice)
              (let ((chosen (hash-ref next-opts choice)))
                (displayln (format "You: ~a" (car chosen)))
                ; cadr chosen is npc-responses, remember it can be a list or a lambda
                (let ((responses (cadr chosen)))
                  (let ((actual-responses
                         (if (procedure? responses)
                             (responses)   ; call the lambda to get the real response
                             responses)))
                    ; loops through npc responses
                    (for ((line actual-responses))
                      (displayln (format "~a: ~a" (npc-name npc) line)))
                    ; caddr is next batch of options, make into hash before loop
                    (loop (list '()
                                (for/hash ((opt (caddr chosen))
                                           (i (in-naturals 1)))
                                  (values i opt))))))))
             (else
              (displayln "That is not a valid choice.")
              ; re-prompt instead of ending conversation on bad input
              (loop node)))))))))

; handle-talk
; looks to see if the npc exists then it calls talk to
(define (handle-talk args)
  
  (let ((found (npc-find args)))
    
    (cond
      ((not found)
       (displayln (format "You don't see '~a' here." args)))
      (else
       (talk-to found)))))


; example by claude
;(define old-man
;  (make-npc "Old Man"
;            (make-dialogue-node
;              '("Hello traveler, how are you?")
;              (list
;                (make-option "Good!"
;                             '("Glad to hear it! Can I help you?")
;                             (list
;                               (make-option "Any quests?"
;                                            '("Go to the cellar for me.")
;                                            '())
;                               (make-option "Goodbye."
;                                            '("Safe travels!")
;                                            '())))
;                (make-option "Not great..."
;                             '("Sorry to hear that.")
;                             '())
;                (make-option "Goodbye."
;                             '("Farewell!")
;                             '())))
;            '()
;            '()))
;
;(npc-register! old-man)

;         USER INPUT

; move handler
(define (handle-move args)
  (cond
    ((equal? args "forward")  (move-forward))
    ((equal? args "backward") (move-backward))
    ((equal? args "left")     (move-left))
    ((equal? args "right")    (move-right))
    (else (displayln (format "Unknown direction: '~a'" args)))))

(define (handle-take args)
  (displayln "Taking from room not yet implemented."))

(define (help)
  (displayln "Commands: move [forward/backward/left/right]")
  (displayln "          talk [name]")
  (displayln "          take [item]")
  (displayln "          drop [item]")
  (displayln "          inspect [item]")
  (displayln "          inventory")
  (displayln "          wander")
  (displayln "          quit"))

; checks what the user inputted then does the action accordingly
(define (parse-input input)
  ; claude helped me here
  (let ((parts (string-split input)))
    
    (cond
      ((null? parts) (displayln "Please enter a command."))
      (else
       (let ((command (car parts))
             (args    (string-join (cdr parts) " ")))
         (cond
           ((equal? command "move")      (handle-move args))
           ((equal? command "take")      (handle-take args))
           ((equal? command "drop")      (drop args))
           ((equal? command "inspect")   (inspect-inventory args))
           ((equal? command "inventory") (inventory-show))
           ((equal? command "wander")    (wander))
           ((equal? command "talk")      (handle-talk args))
           ((equal? command "help")     (help))
           (else (displayln (format "Unknown command: '~a'" command)))))))))

; input loop
(define (game-loop)
  
  (display "> ")
  ; input becomes read-line
  (let ((input (read-line)))
    (cond
      ((equal? input "quit") (displayln "Goodbye!"))
      
      (else
       (parse-input input)
       (game-loop)))))


; MAIN/TEST
; courtesy of claude
; TEST / MAIN

; items
(define beer
  (make-item "Beer"
             "A frothy mug of ale. Smells strong."
             5
             '(take drop inspect drink)))

(define bread
  (make-item "Bread"
             "A stale loaf of bread sitting on the counter."
             1
             '(take drop inspect eat)))

(define knife
  (make-item "Kitchen Knife"
             "A sharp knife used for cooking. Probably shouldn't take this."
             10
             '(inspect)))

(define mop
  (make-item "Mop"
             "A dirty mop leaning against the bathroom wall."
             0
             '(inspect)))

(define trinket
  (make-item "Peculiar Trinket"
             "A strange little object. You're not sure where it came from, but it catches the light oddly."
             0
             '(take drop inspect)))

; rooms
(define bar
  (make-room "The Bar"
             '("bathroom" "kitchen")  ; connections
             '()                      ; characters added after
             (list beer bread)        ; items
             0 0 10 10))              ; x1 y1 x2 y2

(define bathroom
  (make-room "Bathroom"
             '("bar")
             '()
             (list mop)
             11 0 15 10))

(define kitchen
  (make-room "Kitchen"
             '("bar")
             '()
             (list knife)
             0 11 10 15))

(define bartender
  (make-npc "Bartender"
            (make-dialogue-node
             '("Hey there. What can I get ya?")
             (list
              (make-option "I'll have a beer."
                           '("Coming right up. That'll be 5 gold.")
                           (list
                            (make-option "Here you go."
                                         (lambda ()
                                           (if (>= player-gold 5)
                                               (begin
                                                 (gold-spend! 5)
                                                 (inventory-add! beer)
                                                 (displayln "You now have a beer.")
                                                 '("Cheers! Enjoy your drink."))
                                               '("Hey, you're a bit short. Come back when you've got the gold.")))
                                         '())
                            (make-option "Actually nevermind."
                                         '("Suit yourself.")
                                         '())))
              (make-option "What's good here?"
                           '("The ale is fresh. Kitchen's got bread too if you're hungry.")
                           (list
                            (make-option "I'll keep that in mind, thanks."
                                         '("No worries. Holler if you need anything.")
                                         '())))
              (make-option "Where does that door go?"
                           '("Bathroom's to the east. Kitchen's to the north. Don't go snooping around back there.")
                           (list
                            (make-option "Wasn't planning to."
                                         '("Good. Drink up.")
                                         '())
                            (make-option "What if I do?"
                                         '("Then we're gonna have a problem, friend.")
                                         '())))
              (make-option "I've got something you might want..."
                           (lambda ()
                             (if (inventory-find "Peculiar Trinket")
                                 (begin
                                   (inventory-remove! "Peculiar Trinket")
                                   (inventory-add! beer)
                                   '("Well I'll be... I've been looking for one of these for years. Here, take a beer on me."))
                                 '("Hm? You've got nothing worth my time, friend.")))
                           '())
              (make-option "Goodbye."
                           '("Take care now.")
                           '())))
            '()
            '()))
(npc-register! bartender)


; friend npc
(define friend
  (make-npc "Friend"
            (make-dialogue-node
             '("Hey! Good to see you. Quite the place, huh?")
             (list
              (make-option "Yeah! Hey, can I borrow some gold?"
                           (lambda ()
                             (if (>= player-gold 5)
                                 '("You already look like you're doing fine!")
                                 (begin
                                   (gold-add! 5)
                                   '("Sure, I've got you covered. Here's 5 gold. Pay me back later!"))))
                           '())
              (make-option "What are you drinking?"
                           '("Just some water, I'm trying to save money.")
                           (list
                            (make-option "Smart."
                                         '("Unlike some people I know...")
                                         '())
                            (make-option "Boring!"
                                         '("Hey, not all of us are here to party.")
                                         '())))
              (make-option "Goodbye."
                           '("See you around!")
                           '())))
            '()
            '()))

(npc-register! friend)


; main
(define (main)
  (displayln "===========================================")
  (displayln "   Welcome to The Rusty Flagon            ")
  (displayln "===========================================")
  (displayln "You step into a dimly lit bar.")
  (displayln "The smell of ale and sawdust fills the air.")
  (displayln "A bartender wipes down the counter.")
  (displayln "Your friend waves at you from a nearby stool.")
  (displayln "Something glimmers by your foot.")
  (displayln "")
  (displayln "Commands: move [forward/backward/left/right]")
  (displayln "          talk [name]")
  (displayln "          take [item]")
  (displayln "          drop [item]")
  (displayln "          inspect [item]")
  (displayln "          inventory")
  (displayln "          wander")
  (displayln "          quit")
  (displayln "===========================================")
  (displayln "")
  (game-loop))

(main)
