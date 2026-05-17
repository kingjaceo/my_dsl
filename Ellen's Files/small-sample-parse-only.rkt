#lang reader "parse-only.rkt"

create_item {
  name "Sword"
  desc "A well-balanced short sword."
  value 25
  actions ["take", "drop", "inspect"]
}


create_room {
  name "Entrance Hall"
  size 0 0 10 10
  characters ["Guard"]
  links {
    "Armory": 10 5
  }
}

create_room {
  name "Armory"
  size 11 0 20 10
  characters []
  items ["Sword"]
  links {
    "Entrance Hall": 11 5
  }
}

create_start {
  start_room "Entrance Hall"
  title "A Simple Adventure"
  intro ["You stand in the entrance hall of an old keep.",
         "Torchlight flickers against the stone walls.",
         "A guard eyes you from across the room."]
}