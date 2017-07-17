# Familiar Faces

A visual novel written in Love2D with a few interactable scenes, written to get my feet wet in Love2D and to get library code written.

TODO: Interactable parts, a few assets, see Script.lua


Best Code (In no particular order):
- scheduler.lua - Schedules functions to run at certain times or under certain conditions.
- parser.lua - Parses dialogue trees which can run arbitrary Lua code inside of them.
- sprite.lua - Draws sprites to the screen which can be animated.
- animation.lua - The animated part of sprite.
- camera.lua - Performs matrix transformations automatically to the entire game at once, acting like a camera.
- object.lua - Could also be called callbackTables, returns an "object", a table which can have callbacks attached to its values.

Most of the above code will be recycled for later games, like [LoveGame](https://github.com/moomoomoo309/LoveGame).
