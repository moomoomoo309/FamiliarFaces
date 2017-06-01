# Prelude
### The script is valid lua code. You can run any code through the script you want.

# Script format

#### Comments are denoted with --

#### The script is a Lua table, denoted by curly braces, like so:

    {
    
    }

#### Inside, put your dialogue options, with commas between.
 
## Dialogue

##### Dialogue is denoted with strings, using '', "", [[]] or [=[]=] (with however many equals signs as necessary)

 Any of the following are acceptable:
  "I'm dialogue"
  'I\'m dialogue"
  [[I'm dialogue]]

  [[]] (with/without equals signs) does not need to use escape characters such as \", \', \n, \t, etc.

##### In order to do dialogue options, make a sub-table:

    {
        ["Run into the bushes"] = {
            "You die."
        },
        Hide = {
            "You hide.",
            "No one notices you."
        },
        [ [[Cry]]] = {
            "You cry.",
            "You die."
        },
        [ [[Die]] ] = {
            "You die."
        }
    }

Dialogue options are inside a subtable denoted by curly braces, inside having the dialogue.
The dialogue option should be the key of the table, denoted as square braces with a string inside,
like the dialogue (using quotes as denoted there), with one exception: If using [[]], before the pair of
square braces, there must be a space. A space after the closing braces is optional.

If the dialogue option can be used as a valid lua identifier, (is not a keyword, uses only alphanumeric characters, no spaces)
then the string can be used without square braces and without any form of quotes (No "", '', or [[]]).

##### The above script could be simplified to the following:

    {
        ["Run into the bushes"] = {
            "You die."
        },
        Hide = {
            "You hide.",
            "No one notices you."
        },
        Cry = {
            "You cry.",
            "You die."
        },
        Die = {
            "You die."
        }
    }

In order to have a conditional dialogue option, use a function returning a ternary.
A function in Lua is denoted by a function header, "function(parameter1,parameter2)", the code being executed,
and the Lua keyword "end". A ternary is denoted by "boolean and whatToReturnIfTrue or whatToReturnIfFalse".
If there is no alternate option, return false.

##### When put together, a conditional dialogue option looks like so:

    {
        Run = function(val, tbl)
            return tbl.vars.agility > 20 and {
                "You narrowly escape the creature.",
                "...now what?"
            } or false
        end,
        Die = {
            "You die."
        }
    }

##### The conditional returns can also be used to run code at any point during the script like so:

    function(val, tbl)
        switchScene()
        print"Oh man"
        if tbl.vars.alive then
            doOtherStuff()
        end
        return false --Make sure this function doesn't create a dialogue option.
    end

##### There are a few types of custom syntax the parser handles.
 Any message starting with @ will be parsed as a command. Commands are in parser.lua.

 A few commands:
  - @new resets the text, clearing the text on the screen and starting back at the top of the screen. ("@new")
  - @SFX plays the sound with the given name. ("@SFX explosion")

 Any message starting with /r will have red text.
