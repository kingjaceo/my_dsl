#lang reader "main.rkt"

create_item {
  name "Gold Coin"
  desc "A shiny gold coin stamped with a king's face."
  value 10
  actions ["take", "drop", "inspect"]
}

create_item {
  name "Herb"
  desc "A small bitter-smelling herb."
  value 2
  actions ["take", "drop", "inspect", "use"]
}

create_item {
  name "Torch"
  desc "A wooden torch, still burning."
  value 1
  actions ["take", "drop", "inspect"]
}

create_item {
  name "Old Rag"
  desc "A tattered piece of cloth."
  value 0
  actions ["take", "drop", "inspect"]
}

create_item {
  name "Sword"
  desc "A well-balanced short sword."
  value 25
  actions ["take", "drop", "inspect"]
}

create_item {
  name "Shield"
  desc "A battered wooden shield."
  value 15
  actions ["take", "drop", "inspect"]
}

create_item {
  name "Flower"
  desc "A small white flower from the garden."
  value 1
  actions ["take", "drop", "inspect"]
}

create_room {
  name "Entrance Hall"
  size 0 0 10 10
  characters ["Guard"]
  items ["Torch", "Old Rag"]
  links {
    "Armory": 10 5
    "Garden": 5 0
  }
}

create_room {
  name "Armory"
  size 11 0 20 10
  characters []
  items ["Sword", "Shield"]
  links {
    "Entrance Hall": 11 5
  }
}

create_room {
  name "Garden"
  size 0 11 10 20
  characters ["Old Woman"]
  items ["Flower"]
  links {
    "Entrance Hall": 5 11
  }
}

create_character {
  name "Guard"
  room "Entrance Hall"
  items []
  dialogue {
    node "greeting" {
      npc ["Halt! State your business.", "Or move along."]
      option {
        "I'm just passing through."
        npc ["Fine. Watch yourself."]
        next "farewell"
      }
      option {
        "I need to get to the Armory."
        npc ["It's to the east.", "Mind the equipment."]
        next "farewell"
      }
    }
    node "farewell" {
      npc ["Move along then."]
    }
  }
  quest {
    name "The Missing Sword"
    targets ["Sword"]
    rewards ["Gold Coin"]
    giver "Guard"
  }
}

create_character {
  name "Old Woman"
  room "Garden"
  items ["Herb"]
  dialogue {
    node "greeting" {
      npc ["Welcome to my garden, dear."]
      option {
        "What are you growing here?"
        npc ["Oh, herbs mostly.", "Good for wounds."]
        next "farewell"
      }
    }
    node "farewell" {
      npc ["Come back anytime."]
    }
  }
}

create_start {
  start_room "Entrance Hall"
  title "A Simple Adventure"
  intro ["You stand in the entrance hall of an old keep.",
         "Torchlight flickers against the stone walls.",
         "A guard eyes you from across the room."]
}