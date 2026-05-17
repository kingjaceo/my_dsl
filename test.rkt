#lang reader "main.rkt"
create_room: {
  {
    id: start_room
    name: "Dark Cell"
    description: "Cold and dark."
    items: [rusty_key, torch]
  }
  {
    id: courtyard
    name: "Castle Courtyard"
    description: "Blinding sunlight."
    exits: {
      south: start_room
      east: tower
    }
  }
}
create_items: {
  {
    id: rusty_key
    name: "Rusty Key"
    description: "An old key."
    takeable: true
  }
}
create_events: {
  {
    condition: "player_has_item(rusty_key)"
    action: "unlock_door()"
    message: "The key fits!"
  }
}
create_actions: {
}
