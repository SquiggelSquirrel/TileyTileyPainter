class_name ImageLayer
extends Layer

# TODO: Should layer modes by classes?
# Return to this question when we get to implementing their use.
enum Mode {NORMAL, MASK, ADD, SUBTRACT, MULTIPLY, SCREEN, ADDLIGHT, SCREENLIGHT}
var alpha_locked :bool
