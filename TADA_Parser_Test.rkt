#lang reader "parse-only.rkt"

; ── items ──────────────────────────────────────────────────────────

create_item {
    name    "Rusty Sword"
    desc    "A corroded blade, still dangerous."
    value   15
    actions ["take", "drop", "inspect"]
}

create_item {
    name    "Torch"
    desc    "Burns low but keeps the dark at bay."
    value   5
    actions ["take", "drop", "inspect"]
}

create_item {
    name    "Rope"
    desc    "Frayed at the ends. Better than nothing."
    value   3
    actions ["take", "drop", "inspect"]
}

create_item {
    name    "Walking Stick"
    desc    "Worn smooth from years of use."
    value   2
    actions ["take", "drop", "inspect"]
}

create_item {
    name    "Worn Map"
    desc    "Hard to read, but the cave system is sketched out."
    value   10
    actions ["take", "drop", "inspect"]
}

create_item {
    name    "Spectral Lantern"
    desc    "Glows with a cold blue light. You cannot quite grasp it."
    value   0
    actions ["inspect"]
}

create_item {
    name    "Reward Gem"
    desc    "Glimmers faintly. Payment for a job done."
    value   200
    actions ["inspect"]
}

; ── rooms ──────────────────────────────────────────────────────────

create_room {
    name        "Cave"
    size        0 0 10 10
    characters  ["Old Hermit"]
    items       ["Torch", "Rope"]
    links {
        "Windy Hall": 10 5
    }
}

create_room {
    name        "Windy Hall"
    size        11 0 25 10
    characters  ["Ghost"]
    items       ["Rusty Sword"]
    links {
        "Cave":    11 5
        "Dungeon": 25 5
    }
}

create_room {
    name        "Dungeon"
    size        26 0 40 10
    characters  []
    items       []
    links {
        "Windy Hall": 26 5
    }
}

; ── characters ─────────────────────────────────────────────────────

create_character {
    name    "Old Hermit"
    room    "Cave"
    items   ["Walking Stick", "Worn Map"]

    quest {
        name     "Find the Lost Sword"
        targets  ["Rusty Sword"]
        rewards  ["Reward Gem"]
        giver    "Old Hermit"
    }

    dialogue {
        node "greeting" {
            npc  ["Who goes there?", "State your business or leave me be."]
            option {
                "I am looking for a sword."
                npc  ["Ah. I may know where it lies."]
                next "quest-offer"
            }
            option {
                "Nothing. Just passing through."
                npc  ["Then pass quietly."]
                next "goodbye"
            }
        }

        node "quest-offer" {
            npc  ["It was taken to the Windy Hall.", "Bring it back and I will reward you."]
            option {
                "I will find it."
                npc  ["Good. Watch yourself in that hall."]
                next "goodbye"
            }
            option {
                "Sounds dangerous. No thanks."
                npc  ["Your loss, traveller."]
                next "goodbye"
            }
        }

        node "goodbye" {
            npc  ["..."]
        }
    }
}

create_character {
    name    "Ghost"
    room    "Windy Hall"
    items   ["Spectral Lantern"]

    quest {
        name     "Lay the Ghost to Rest"
        targets  ["Worn Map"]
        rewards  ["Spectral Lantern"]
        giver    "Ghost"
    }

    dialogue {
        node "greeting" {
            npc  ["Ooooooo.", "You... you can see me?"]
            option {
                "Yes. Who are you?"
                npc  ["I died here long ago.", "I cannot leave without my map."]
                next "quest-offer"
            }
            option {
                "I can't hear you. Goodbye."
                npc  ["Wait...!"]
                next "goodbye"
            }
        }

        node "quest-offer" {
            npc  ["Find my map and I will let you pass in peace."]
            option {
                "I will look for it."
                npc  ["Thank you, traveller."]
                next "goodbye"
            }
            option {
                "Not my problem."
                npc  ["Then the wind takes you too."]
                next "goodbye"
            }
        }

        node "goodbye" {
            npc  ["Oooooooo..."]
        }
    }
}