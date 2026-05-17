#lang racket

; ============================================================
;                          ITEMS
; ============================================================

; Item Constructor
(define (make-item name description value actions)
  
  (list name description value actions))

; Item Accessors
(define (item-name item) (list-ref item 0))
(define (item-desc item) (list-ref item 1))
(define (item-value item) (list-ref item 2))
(define (item-actions item) (list-ref item 3))

; Maybe give items coordinatesq

; check if an item can do the action
(define (item-can? item action)
  ; member returns a sublist instead when something is found, it returns false if nothing is found
  (member action (item-actions item)))


; ============================================================
;                        INVENTORY
; ============================================================

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


; ============================================================
;                          GOLD
; ============================================================

; set player gold
(define player-gold 0)

; add to player gold using mutability
(define (gold-add! amount)
  
  (set! player-gold (+ player-gold amount))
  (displayln (format "You now have ~a gold." player-gold)))

; spend gold
(define (gold-spend! amount)
  
  (set! player-gold (- player-gold amount)))


; ============================================================
;                         ACTIONS
; ============================================================

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
       (set! floor-items (append floor-items (list found)))  ; add to current room floor
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


; ============================================================
;                     COORDINATE SYSTEM
; ============================================================

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

; attempt to move by (dx dy), checks bounds and doors before moving
(define (try-move! dx dy direction-name)
  
  (let* (
         (new-x (+ (pos-x player-pos) dx))
         (new-y (+ (pos-y player-pos) dy)))
    (cond
      ; new position is within room bounds move free
      ((in-room? current-room new-x new-y)
       
       (set! player-pos (make-pos new-x new-y (pos-floor player-pos)))
       (displayln (format "You move ~a." direction-name))
       (when (player-in-doorway?)
         (displayln "You are standing in a doorway.")))
      ; Claude asissted code:
      ; new position is outside bounds, check if current position is a door
      (else
       (let ((conn (room-door-at? current-room (pos-x player-pos) (pos-y player-pos))))
         (cond
           (conn  (enter-room! (connection-name conn)))
           (else  (displayln "You walk into a wall."))))))))

; movement functions
(define (move-right) (try-move! 1  0 "right"))
(define (move-left) (try-move!  -1  0 "left"))
(define (move-forward) (try-move!  0  1 "forward"))
(define (move-backward) (try-move!  0 -1 "backward"))

; move in a certain direciton a certain number of times
(define (move-n direction n)
  (for ((i n))
    (cond
      ((equal? direction "forward")  (move-forward))
      ((equal? direction "backward") (move-backward))
      ((equal? direction "left")     (move-left))
      ((equal? direction "right")    (move-right)))))

; wander function
(define (wander)
  (let ((new-x (+ (room-x1 current-room)
                  (random (+ (- (room-x2 current-room) (room-x1 current-room)) 1))))
        
        (new-y (+ (room-y1 current-room)
                  (random (+ (- (room-y2 current-room) (room-y1 current-room)) 1)))))
    
    (set! player-pos (make-pos new-x new-y (pos-floor player-pos)))
    (displayln "You wander around the room...")
    (curr-pos)))


; ============================================================
;                          ROOMS
; ============================================================

; connections for rooms
(define (make-connection room-name door-x door-y)
  
  (list room-name door-x door-y))

; connection accessors
(define (connection-name conn) (list-ref conn 0))

(define (connection-x conn) (list-ref conn 1))

(define (connection-y conn) (list-ref conn 2))

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

; room registry
(define rooms '())

; register room
(define (room-register! room)
  
  (set! rooms (append rooms (list room))))

; find room
; Claude assisted code:
(define (room-find name)
  (findf (lambda (r) (string-ci=? (room-name r) name)) rooms))

; check if coordinates are within room bounds
(define (in-room? room x y)
  
  (and (>= x (room-x1 room)) (<= x (room-x2 room))
       (>= y (room-y1 room)) (<= y (room-y2 room))))

; find door
; Claude semi assisted code
(define (room-door-at? room x y)
  
  (findf (lambda (c) (and (= (connection-x c) x)
                          (= (connection-y c) y)))
         (room-connections room)))

; current room the player is in
(define current-room #f)

; items on the floor in the current room
(define floor-items '())

; remove items from rooms
(define (floor-remove! name)
  
  (set! floor-items
        (filter (lambda (i) (not (string-ci=? (item-name i) name))) floor-items)))

; nudge player one step inside the room so they are not sitting on door
(define (nudge-inward room pos)
  (let* ((x (pos-x pos))
         (y (pos-y pos))
         (f (pos-floor pos)))
    (cond
      ((= x (room-x1 room)) (make-pos (+ x 1) y f))  ; left edge push right
      ((= x (room-x2 room)) (make-pos (- x 1) y f))  ; right edge push left
      ((= y (room-y1 room)) (make-pos x (+ y 1) f))  ; bottom push up
      ((= y (room-y2 room)) (make-pos x (- y 1) f))  ; top push down
      (else pos))))

; persistent item state per room, survives transitions
(define room-states (make-hash))

; returns the current items for a room, falling back to original if unvisited
(define (room-current-items room-name)
  (if (hash-has-key? room-states room-name)
      (hash-ref room-states room-name)
      (room-items (room-find room-name))))

; snapshot current floor-items into the room-states hash
(define (room-save-items! room-name)
  (hash-set! room-states room-name floor-items))

; enter a new room
; Claude assisted code
(define (enter-room! dest-name)
  (let* ((dest (room-find dest-name))
         ; find the connection in dest that leads back to where we came from
         (return-conn (findf (lambda (c) (string-ci=? (connection-name c) (room-name current-room)))
                             (room-connections dest))))
    ; save current room's item state before leaving
    (when current-room
      (room-save-items! (room-name current-room)))
    (set! current-room dest)
    ; nudge player one step inside so they are not sitting on the door edge
    (set! player-pos
          (nudge-inward dest
                        (make-pos (connection-x return-conn)
                                  (connection-y return-conn)
                                  (pos-floor player-pos))))
    ; restore this room's persisted item state
    (set! floor-items (room-current-items dest-name))
    (displayln (format "You enter ~a." (room-name dest)))))


; ============================================================
;                          QUESTS
; ============================================================

; quest constructor
; completed? is a flag that is initialized as false
(define (make-quest description target-items reward-items giver)
  
  (list description target-items reward-items giver #f #f))

(define (quest-desc quest) (list-ref quest 0))

(define (quest-targets quest) (list-ref quest 1))

(define (quest-rewards quest) (list-ref quest 2))

(define (quest-giver quest) (list-ref quest 3))

(define (quest-assigned? quest) (list-ref quest 4))

(define (quest-completed? quest) (list-ref quest 5))

; assigns the quest by setting element 4 to true, rebuilds quest
(define (quest-assign quest)
  
  (list (quest-desc quest) (quest-targets quest) (quest-rewards quest) (quest-giver quest) #t #f))

(define (quest-complete quest)
  
  (list (quest-desc quest) (quest-targets quest) (quest-rewards quest) (quest-giver quest) #t #t))

; list of all quests
(define quests '())

; registers quests
(define (quest-register! quest)
  
  (set! quests (append quests (list quest))))

; Claude assisted code:
; assigns quest by looping through the quests searching by desc
(define (quest-assign! desc)
  (set! quests
        (map (lambda (q)
               (if (string-ci=? (quest-desc q) desc)
                   (quest-assign q)
                   q))
             quests)))

; Claude assisted code:
; check if quest is ready to be finished
(define (npc-quest-ready? npc-name)
  (findf (lambda (q)
           (and (string-ci=? (quest-giver q) npc-name)
                (quest-assigned? q)
                (not (quest-completed? q))
                (andmap inventory-find (quest-targets q))))
         quests))

; turns in the quest
(define (quest-turn-in! quest npc-name)
  ; maybe later do not hard code the response
  (displayln (format "~%~a: A deal's a deal" npc-name))
  
  (for ((target (quest-targets quest)))
    (inventory-remove! target)
    (displayln (format "  You hand over: ~a." target)))
  
  (for ((reward (quest-rewards quest)))
    (inventory-add! reward)
    (displayln (format "  You receive: ~a." (item-name reward))))
  
  ; Claude assisted code
  (set! quests
        (map (lambda (q)
               (if (string-ci=? (quest-desc q) (quest-desc quest))
                   (quest-complete q)
                   q))
             quests)))


; ============================================================
;                           NPCs
; ============================================================

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

; --- Dialogue Helpers ---
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
  ; check if the player is ready to turn in a quest to this npc
  (let ((ready (npc-quest-ready? (npc-name npc))))
    (when ready
      (quest-turn-in! ready (npc-name npc))))
  
  (let loop ((node (npc-dialogue npc)))
    (let ((npc-lines (car node))
          (next-opts (cadr node)))
      
      ; loops through all npc lines and prints them before options appear
      ; npc-lines can be a lambda to react to game state, or a plain list
      (let ((actual-lines (if (procedure? npc-lines) (npc-lines) npc-lines)))
        (for ((line actual-lines))
          (displayln (format "~a: ~a" (npc-name npc) line))))
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
      ((not (member (npc-name found) (room-characters current-room) string-ci=?))
       (displayln (format "~a isn't here." (npc-name found))))
      (else
       (talk-to found)))))


; ============================================================
;                        USER INPUT
; ============================================================

; move handler
(define (handle-move args)
  (cond
    ((equal? args "forward")  (move-forward))
    ((equal? args "backward") (move-backward))
    ((equal? args "left")     (move-left))
    ((equal? args "right")    (move-right))
    (else (displayln (format "Unknown direction: '~a'" args)))))

; outputs te direction and distance of a door from the player
; outputs the direction and distance of a door from the player
(define (door-hint conn)
  (let* ((dx (- (connection-x conn) (pos-x player-pos)))
         (dy (- (connection-y conn) (pos-y player-pos)))
         ; Claude helped with the math here
         (dist (+ (abs dx) (abs dy)))
         ; pick which cardinal direction is closest
         (dir (cond
                ; player is standing on the door, check which edge to find exit direction
                ((= dist 0)
                 (cond
                   ((= (connection-x conn) (room-x2 current-room)) "enter east")
                   ((= (connection-x conn) (room-x1 current-room)) "enter west")
                   ((= (connection-y conn) (room-y2 current-room)) "enter north")
                   (else                                            "enter south")))
                ((and (> (abs dy) (abs dx)) (> dy 0)) "north")
                ((and (> (abs dy) (abs dx)) (< dy 0)) "south")
                ((> dx 0) "east")
                (else     "west"))))
    (format "A door to ~a (~a) is ~a step~a away."
            (connection-name conn) dir dist (if (= dist 1) "" "s"))))

; check if player is currently standing in a doorway
(define (player-in-doorway?)
  (room-door-at? current-room (pos-x player-pos) (pos-y player-pos)))

; look around, shows items on the floor and nearby doors
; look around, shows items on the floor and nearby doors
(define (look)
  ; doorway check
  (when (player-in-doorway?)
    (displayln "You are standing in a doorway."))
  ; items
  (cond
    ((null? floor-items)
     (displayln "You don't see anything of interest in the room."))
    (else
     (displayln "In the room ")
     (for ((item floor-items))
       (displayln (format "  ~a" (item-name item))))))
  ; people
  (cond
    ((null? (room-characters current-room))
     (displayln "There is nobody else here."))
    (else
     (displayln "People: ")
     (for ((person (room-characters current-room)))
       (displayln (format "  ~a" person)))))
  ; doors
  (displayln "Doors: ")
  (for ([conn (room-connections current-room)])
    (displayln (format "  ~a" (door-hint conn)))))

; take from floor
(define (handle-take args)
  
  (let ((found (findf (lambda (i) (string-ci=? (item-name i) args))
                      floor-items)))
    (cond
      ((not found)
       (displayln (format "You don't see '~a' here." args)))
      (else
       (take found)
       (floor-remove! args)))))

(define (help)
  (displayln "Commands: move [forward/backward/left/right]")
  (displayln "          look")
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
           ((equal? command "move")
            (let ((parts (string-split args)))
              (if (= (length parts) 2)
                  (move-n (car parts) (string->number (cadr parts)))
                  (handle-move args))))
           ((equal? command "look")      (look))
           ((equal? command "take")      (handle-take args))
           ((equal? command "drop")      (drop args))
           ((equal? command "inspect")   (inspect-inventory args))
           ((equal? command "inventory") (inventory-show))
           ((equal? command "wander")    (wander))
           ((equal? command "talk")      (handle-talk args))
           ((equal? command "help")      (help))
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


; ============================================================
;                         SETTERS
; ============================================================

(define (set-current-room! room) (set! current-room room))
(define (set-floor-items! items) (set! floor-items items))
(define (set-player-pos! pos) (set! player-pos pos))


; ============================================================
;                         MAIN
; ============================================================
; Should be the last thing the player uses because game loop is called inside of make-main
(define (make-main start-room title description)
  (set-current-room! start-room)
  (set-floor-items!  (room-items start-room))
  (displayln "===========================================")
  (displayln title)
  (displayln "===========================================")
  (for ((line description))
    (displayln line))
  (displayln "")
  (displayln "Commands: move [forward/backward/left/right]")
  (displayln "          look")
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


; ============================================================
;                         PROVIDE
; ============================================================

(provide
 ; Items
 make-item
 item-name
 item-can?

 ; Inventory & gold
 inventory-add!
 inventory-find
 inventory
 player-gold
 gold-add!
 gold-spend!

 ; Actions
 take
 drop
 inspect-inventory

 ; Rooms
 make-room
 make-connection
 room-register!
 room-items
 current-room
 floor-items
 enter-room!
 room-find

 ; Player position
 player-pos
 wander

 ; NPCs
 make-npc
 make-dialogue-node
 make-option
 npc-register!

 ; Quests
 make-quest
 quest-register!
 quest-assign!
 quest-assigned?
 quest-desc
 quest-giver
 quests

 ; Input & game loop
 parse-input
 game-loop
 look
 handle-talk
 handle-move
 handle-take

 ; Setters
 set-current-room!
 set-floor-items!
 set-player-pos!

 ; Main
 make-main)