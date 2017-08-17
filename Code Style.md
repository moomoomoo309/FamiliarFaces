# Code Style

The code style for this editor will be consistent with LoveGame and spriteEditor.

TL;DR Use the Lua plugin for IntelliJ and auto-format the code. (Ctrl+Alt+L by default)

### Indentation

Indentation will use 4 spaces per level.
When function calls get too long, indent the arguments, but keep the first argument on the same line as the function call, like so:

    fct(someLongVariableName[someIndex % someNumber + 1],
        someOtherLongVariable,
        "A string",
        1)

### Comments

As a rule of thumb, comments should often be explaining _why_ something is being done, rather than _what_ it's doing, but if it's not clear what the code is doing, a comment explaining that is welcome.

Comments can either be in-line or prefixing the block they refer to, like so:

    someWeirdFunctionCall "esoteric string" --Why we're doing this, or what it's doing if that's not clear

or

    --Why we're doing this, or what it's doing if that's not clear
    doSomething()
    doSomethingElse()
    doMoreStuff()

    doAnUnrelatedThing()

If it is prefixing a block of code, the comment refers to everything up to the next empty line. In the above example, the comment applies up to `doMoreStuff()`, the comment is not applicable to `doAnUnrelatedThing()`.

If it is in-line, it is only referring to the line of code it is on.

### Operators

Put spaces between operators, unless taking the space out would make the code clearer.

    --A space would not make this code as clear, though parentheses may be clearer than this.
    someTable[n*2 % #someOtherTable]

### Functions

- Use colon syntax where applicable. If a function takes a self argument, use a colon rather than a dot with the self argument, if possible.
- If a function is "stable", meaning its arguments and return values are unlikely to change, put a doc comment before it saying what it does.
    - If the function returns nothing, use `@return nil` for the return tag.
- If a function takes no arguments, don't use the colon syntax, because the self parameter is unnecessary, and that may not be clear.
- If a function takes only a singular string parameter or a singular table parameter, omit the parentheses and put a space between the argument and the function.
    - If you think the function may need parentheses later or are not sure, do not omit the parentheses.
    - Ex: `error "You borked it up!"`

### Variable Naming

- Call any unused variable `_`.
- Name variables using camelCase.
- Prefer descriptive variable names over abbreviations. (It can be shortened if you think the name's getting long)
- If you use a single-letter variable name, it'd better be clear what it does. (x,y,w,h for drawing something or i as an iterator, for example, is fine)

### Other
- If you want to emulate OOP principles, do so using metatables and the `__index` metamethod, with a type field saying the name of the class as the string, and a class field with a reference to the class itself.
    - If you want to add setters, use `object.lua`.
    - For an example of an implemented class using `object.lua`, see `sprite.lua`.
- If you're using the Lua plugin for IntelliJ, the auto-formatter should format the file correctly.
- Don't write stupid Lua. Use locals generously, and avoid globals if possible.
    - Don't ever use `table.remove()` with one argument. Just do `tbl[#tbl] = nil`.
    - Don't use the string library directly. Use the colon operator on the string itself.
        - Ex: If you want to do `string.find(someVar, " ", nil, true)`, do `someVar:find(" ", nil, true)`.
        - If it's a string literal instead of a variable, just encapsulate it in parentheses first.
            - Ex: `("Hi %s!"):format(yourName)`
- Don't use string.len, not even with the variable and the colon operator (`myStringVar:len()`). Use the length operator `#` instead. (`#myStringVar`)
- If you need to load a file, like sprite loading abstractSprite, use require, even if the file's been loaded already.
    - This makes it clear what dependencies the file has.
