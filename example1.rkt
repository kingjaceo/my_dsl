#lang TADA
create_room {
    name:       "cave"
    links:      ["windy hall" 6 7, "forest entrance" 7 6]
    size:       ["6 6 8 8"]
    characters: ["old hermit", "bat swarm"]
    items:      ["torch", "rope"]
    quest:      ["find the lost sword"]
}

create_room {
    name:       "windy hall"
    links:      ["cave", "dungeon"]
    size:       ["4 4 5 5"]
    characters: ["ghost"]
    items:      ["lantern"]
    quest:      ["escape the dungeon"]
}

create_character {
    name:       "old hermit"
    room:       "cave"
    dialogue:   ["Who goes there?", "Leave me be.", "...I may know where the sword lies."]
    items:      ["walking stick", "worn map"]
    quest:      ["find the lost sword"]
}

create_character {
    name:       "ghost"
    room:       "windy hall"
    dialogue:   ["Ooooooo.", "I died here long ago."]
    items:      ["spectral lantern"]
    quest:      ["lay the ghost to rest"]
}
