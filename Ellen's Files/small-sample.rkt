#lang reader "main.rkt"

; ITEMS
create_item {
  name "Torch"
  desc "A wooden torch, still burning."
  value 1
  actions ["take", "drop", "inspect"]
}

create_item {
  name "Gold Coin"
  desc "A shiny gold coin."
  value 10
  actions ["take", "drop", "inspect"]
}

create_item {
  name "Sword"
  desc "A well-balanced short sword."
  value 25
  actions ["take", "drop", "inspect"]
}

create_item {
  name "Herb"
  desc "A small bitter-smelling herb."
  value 2
  actions ["take", "drop", "inspect"]
}

; ROOMS
create_room {
  name "Entrance Hall"
  size 0 0 10 10
  characters ["Guard"]
  items ["Torch"]
  links {
    "Armory": 10 5
    "Garden": 5 0
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

create_room {
  name "Garden"
  size 0 11 10 20
  characters ["Old Woman"]
  items ["Herb"]
  links {
    "Entrance Hall": 5 11
  }
}

; CHARACTERS
create_character {
  name "Guard"
  items ["Gold Coin"]
  dialogue {
    node "greeting" {
      npc ["Halt! State your business.", "Or move along."]
      option {
        "I'm just passing through."
        npc ["Fine. Watch yourself."]
        next "farewell"
      }
      option {
        "I need to find a torch."
        npc ["One was left in the hall.", "Bring it back to me."]
        next "farewell"
      }
    }
    node "farewell" {
      npc ["Move along then."]
    }
  }
  quest {
    name "The Missing Torch"
    targets ["Torch"]
    rewards ["Gold Coin"]
    giver "Guard"
  }
}

create_character {
  name "Old Woman"
  items []
  dialogue {
    node "greeting" {
      npc ["Welcome to my garden, dear."]
      option {
        "What are you growing here?"
        npc ["Oh, herbs mostly.", "Good for wounds."]
        next "farewell"
      }
      option {
        "I need a sword."
        npc ["Try the armory to the north.", "Mind the Guard though."]
        next "farewell"
      }
    }
    node "farewell" {
      npc ["Come back anytime."]
    }
  }
  quest {
    name "Herbal Remedy"
    targets ["Herb"]
    rewards ["Sword"]
    giver "Old Woman"
  }
}

; START
create_start {
  start_room "Entrance Hall"
  title "A Simple Adventure"
  intro ["You stand in the entrance hall of an old keep.",
         "Torchlight flickers against the stone walls.",
         "A guard eyes you from across the room."]
}