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
    ((null? inventory) (displayln "You have nothing in your inventory!"))

    (else
     (displayln "Your inventory:")
     ; for loop over inventory
     (for ([item inventory])
       ; format allows us ti input data in the middle of a string using ~a
       (displayln (format "  ~a" (item-name item)))))))


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
       (displayln (format "Value: ~a" (item-value found))))
       (displayln (item-desc found))
      
      (else
       (displayln (format "You can't inspect the: ~a." (item-name found)))))))

; inspect from room
; IMPLEMENT WHEN ROOMS ARE IMPLEMENETED




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






; TESTS courtesy of Claude
;;; ----------------------------------------------------------
;;;  Tests / Demo
;;; ----------------------------------------------------------

(define sword   (make-item "Iron Sword"    "A worn iron sword. Still sharp." 50  '(take drop inspect)))
(define potion  (make-item "Health Potion" "A small red vial. Smells sweet."  20  '(take drop inspect)))
(define boulder (make-item "Giant Boulder" "Way too heavy to carry."           0   '(inspect)))
(define relic   (make-item "Ancient Relic" "A strange glowing artifact."       500 '(inspect)))

(displayln "=== INVENTORY TESTS ===")
(inventory-show)                   ; empty inventory
(take sword)                       ; take sword
(take potion)                      ; take potion
(take boulder)                     ; should fail, boulder has no 'take
(inventory-show)                   ; should show sword and potion
(newline)

(displayln "=== INSPECT TESTS ===")
(inspect-inventory "Iron Sword")   ; should show sword details
(inspect-inventory "Giant Boulder"); should fail, not in inventory
(inspect-inventory "Health Potion"); should show potion details
(newline)

(displayln "=== DROP TESTS ===")
(drop "Iron Sword")                ; should drop sword
(drop "Iron Sword")                ; should fail, no longer in inventory
(drop "Ancient Relic")             ; should fail, never picked up
(inventory-show)                   ; should only show potion
(newline)

(displayln "=== MOVEMENT TESTS ===")
(curr-pos)                         ; starting position
(move-forward)
(move-forward)
(move-right)
(curr-pos)
(move-backward)
(move-left)
(curr-pos)                         ; should be back to start
(newline)

(displayln "=== WANDER TESTS ===")
(curr-pos)                         ; position before wandering
(wander)
(wander)
(wander)