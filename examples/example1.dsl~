When I run this in Dr. Racket, it should just work!
create_room:
rooms:
  - id: start_room
    name: "Dark Cell"
    description: "You are in a cold, dark cell. A wooden door is to the north."
    exits:
      north: courtyard
    items: [rusty_key]

  - id: courtyard
    name: "Castle Courtyard"
    description: "The sun is blinding. A tower looms to the east."
    exits:
      south: start_room
      east: tower

create_items:
  - id: rusty_key
    name: "Rusty Key"
    description: "An old key covered in rust."
    location: start_room
    takeable: true

create_events:
  - condition: "player_has_item(rusty_key) and room(courtyard)"
    action: "unlock_door()"
    message: "The key fits!"

create_actions:
 -condition: "(characer1) has hit the (character2) with (an axe)!"
  action: "hit()"
  villain_hp: "-#"
  message: "creature lost (hp)"

create_char:
- name: "user_insert()"
  char_type: "villain", "npc", "main_char"
  description: "old fella from the north"
  start_coordinate: "0.04, 1"
  weapon: "none"
  inventory: "enchanted bracelet"
  



