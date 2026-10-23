extends Node
## Story facts shared by scenes and dialogues (autoload "GameState"). Nodes change them through
## their own methods (Hero.toggle_flashlight(), Radio.turn_on()) so visuals stay in sync; dialogues
## read them directly, e.g. `if GameState.radio_on`.

var flashlight_on: bool = false
var radio_on: bool = false
