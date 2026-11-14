import Toybox.Lang;

// Colours taken from the logo and snapped to the 64 the screen can show.
module Palette {
    const NAVY = 0x000055;      // background, and text on gold
    const GOLD = 0xFFAA55;      // the sun: accents, fills, highlights
    const DIM = 0xAAAA55;       // the shaded gold: fills while out of the light
    const SKY = 0x55AAFF;       // water
    const DONE = 0x55AA55;      // the well once the goal is met
    // The well's fill, bottom fifth first: a sunrise, orange warming to pale light.
    const WELL = [0xFF5500, 0xFFAA00, 0xFFAA55, 0xFFFF55, 0xFFFFAA];
}
