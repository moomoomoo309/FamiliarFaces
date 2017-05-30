--[===[
Prelude:
    The script is valid lua code. You can run any code through the script you want.

Script format:

    Comments start with --
    
    
    Start with
    {
    
    }
    
    Inside, put your dialogue options, with commas between.
    
    Dialogue is denoted with strings, using '', "", [[]] or [=[]=] (with however many equals signs as necessary)
        Any of the following are acceptable:
            "I'm dialogue"
            'I\'m dialogue"
            [[I'm dialogue]]
    
            [[]] (with/without equals signs) does not need to use escape characters such as \", \', \n, \t, etc.
    
    In order to do dialogue options, make a sub-table as so:
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
    
    The above could be simplified to the following:
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
    When put together, a conditional dialogue option looks like so:
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
    
    The conditional returns can also be used to run code at any point during the script like so:
        function(val, tbl)
            switchScene()
            print"Oh man"
            if tbl.vars.alive then
                doOtherStuff()
            end
            return false --Make sure this function doesn't create a dialogue option.
        end

    There are a few types of custom syntax the parser handles:
        Any message starting with @ will be parsed as a command. Commands are in parser.lua.
        A few commands:
            @new resets the text, clearing the text on the screen and starting back at the top of the screen. ("@new")
            @SFX plays the sound with the given name. ("@SFX explosion")
            @+ adds to a variable ("@+ 1 variableName")

        Any message starting with /r will have red text.

]===]
local script
script = {
    vars = {good=0},
    "@SFX bap_2",
    "I’m standing by a lake",
    "Or maybe more of a wide river that’s moving really slowly",
    "Everything is a little out of focus",
    "@SFX air_raid_siren",
    "@eye opening to white background vignette shadows from edges",
    "I wake up",
    "@bathroom (art scene) give player ability to hinge move arm so they can kinda “ wave hello ”",
    "Time to get ready for the day.I want to look nice.",
    "@gray and drab, blocky and drab, Attractive yet respectable",
    "@save type of outfit",
    "I slide on my (insert type of outfit here) outfit",
    "It feels rough against my skin.I proceed to my bathroom and look at my reflection.",
    "My reflection judges me from the mirror.",
    "@(insert type of outfit here) outfit.",
    "My reflection can be very judgemental.",
    "I don't think it sleeps enough.",
    "I proceed with my normal routine.",
    "Brush teeth.",
    "Gargle.",
    "Rinse.",
    "Skip flossing.",
    "Read yesterdays paper on toilet",
    "@new",
    "Groan. Comb hair. Apply foundation. And of course…",
    "@cut to her in bathroom looking into mirror with eye close no scarf sprite",
    "@SFX gross_blink",
    "@eye flutters open",
    "I cover the eye protruding from my neck.",
    "@animation arm covers eye on neck with scarf, only rotates as player holds arrow key",
    "The eye undulates slightly under the my scarf.I groan again.And so completes my morning routine.",
    "@new",
    "As I walk to work I feel the eye throbbing under my scarf.It's hot on my neck",
    "It blinks on every third step",
    "I don’t know whose eye it is",
    "I don’t have any control over it",
    "I feel every movement",
    "Uncomfortable as it is , I'm used to it.",
    "I stopped trying to figure out who it belongs a while ago",
    "Cover it up and go about my business.",
    "That's my motto.",
    "@walking on street scene , arrow keys to walk arrive at building, space to enter",
    "@new",
    "I groan before entering the elevator.Another day another dollar.",
    "@(elevator sequence arrow key controls to move elevator from point to point on the tower)",
    "I groan as I exit the elevator",
    "The eye on my neck pulsates",
    "…presumably in reciprocation",
    "@(in office allows player to press arrow keys to walk up to sit in chair.arrow key to bang head on keyboard after sitting down.",
    "@SFX head_band",
    "5 seconds after sitting down fade to black)",
    "Again. Again there is a river",
    "Again flowing slowly",
    "I attempt to turn away",
    "@SFX air_raid_siren",
    "@eye opening to white background vignette shadows from edges",
    "Again I wake up.Again I proceed with my normal routine.Again I cover the eye protruding from my neck.@animation arm covers eye on neck with scarf, only rotates as player holds arrow key",
    "As I walk to work I feel the eye throbbing under my scarf.",
    "@walking on street scene, arrow keys to walk arrive at building, space to enter",
    "@new",
    "Again I groan before entering the elevator.",
    "Another, another day another, another dollar.",
    "@(elevator sequence arrow key controls to move elevator from point to point on the tower)",
    "I groan as I exit the elevator.The eye on my neck pulsates",
    "…presumably in reciprocation.",
    "@(in office allows player to press arrow keys to walk up to sit in chair.arrow key to bang head on keyboard after sitting down.",
    "@SFX head_bang",
    "@(5 seconds after sitting down fade to black)",
    "Again.",
    "Again there is a river.",
    "Again flowing slowly.",
    "I approach the water.",
    "I stare into my reflection in the distorting flow.",
    "It’s uncanny.",
    "Enchanting.",
    "But it its not -",
    "@SFX air_raid_siren",
    "@eye opening shaped transition to white screen",
    "Again I wake up",
    "Again I proceed with my normal routine",
    "But I stop",
    "Again My forearm itches",
    "I scratch it without thinking",
    "@SFX Lick",
    "It licks me.",
    "@(show bathroom reflection with sprite that has eye on neck and mouth on forearm for 2 seconds)",
    "I certainly cannot go to work like this.",
    "I find an old glove in my wardrobe.",
    "It smells like cigarettes and the elderly.",
    "@(show bathroom reflection with sprite that has eye on neck and mouth on forearm",
    "@SFX bap_3",
    "@mouth flops, cut to black screen and show text colors as indicated red :red black :white, additionally, the red text should appear on its own [without the player's arrow key prompting] in near immediate response to white text )",
    "@SFX bap_2",
    "/rPlease do not cover me again.",
    "What?",
    "/rIt’s just that…",
    "/rI'm not terribly fond of the dark.",
    {
        Refuse = {
            "@- 1 good",
            "Look I can’t go to work with someone else’s facial features on my arm.",
            "@SFX bap_2",
            "/rIm afraid I cannot read lips, and I’ve no ear on your body but please just don’t cover me.",
            "/rTake me to work with you.",
            "/rIt will be fine I promise.",
            "…",
            "/r…",
            "/rPlease.",
            "*I shake my head",
            "/rPlease don’t, I may suffocate.",
            "/rIf you cover me I'll…",
            "/rI'll scream all day.",
            "I shove cotton balls in their mouth.",
            "I then slide my glove over their writhing lips.",
            "@animation arm covers eye on neck with scarf, only rotates as player holds arrow key",
        },
        ["Ask what they are"] = {
            "Fine, but what are you exactly?",
            "@SFX bap_2",
            "/rIm afraid I cannot read lips, and I’ve no ear on your body but please just don’t cover me.",
            "/rTake me to work with you.",
            "/rIt will be fine I promise.",
            "…",
            "/r…",
            "/rPlease.",
        },
        ["“Accept”"] = {
            "@+ 1 good",
            "*I nod",
            "Okay.",
            "/rThank you",
        }
    },
    function(val, tbl)
        return tbl.vars.good <= 1 and {
            "@walking on street scene, arrow keys to walk arrive at building, space to enter",
            "@new",
            "I feel a pressure on my arm",
            "My neck feels like it's on fire",
            "As I enter the elevator I tighten my scarf and press on my arm",
            "I wince slightly as I hear what sounds like a muffled groan escape the lips on my arm.",
            {
                ["Uncover them"] = {
                    "@+ 1 good",
                    "I slide the glove off my arm and remove the cotton balls from the mouth",
                    "/rThank you.",
                    "You're welcome now what are you on about? ",
                },
                ["Silence them"] = {
                    "@- 1 good",
                    "@SFX bap_distressed",
                    "I silence them",
                    "forcibly",
                },
                ["Do Nothing"] = {
                    "I groan in dismission"
                }
            }
        } or {
            "Another, another, another day another, another, another dollar",
            "@(elevator sequence arrow key controls to move elevator from point to point on the tower)",
            "@(in office allows player to press arrow keys to walk up to sit in chair. arrow key to bang head on keyboard after sitting down.@SFX banging noise* 5 seconds after sitting down fade to black)",
        }
    end,
    function(val, tbl)
        return tbl.vars.good >= 1 and {
            "/r..all im saying is that this elevator seems arbitrarily convoluted.",
            "*I laugh heartily",
            "Yes, i suppose it is",
            "It is normal though",
            "Oh that’s right, you can’t hear me",
            "*I make an exaggerated laughing gesture at my reflection",
            "/rThe lips curl into a smile",
        } or false
    end,
    "@(in office allows player to press arrow keys to walk up to sit in chair. arrow key to bang head on keyboard after sitting down.@SFX banging noise* 5 seconds after sitting down fade to black)",
    "Again the river",
    "Again I approach the water",
    "Again I gaze at my reflection in the distorting flow",
    "Again It’s uncanny.",
    "Again I am enchanted",
    "But it its not me",
    "It’s someone familiar,",
    "but I can’t seem to make out their face",
    "@SFX air_raid_siren",
    "@eye opening to white background vignette shadows from edges",
    function(val, tbl)
        return tbl.vars.good >= 1 and {
            "/rGood morning sleeping beauty",
            "Uhh…",
            "Good morning?",
        } or {
            "I wake up"
        }
    end,
    "@black frame",
    "I proceed with my “normal” routine",
    "As I’m brushing my teeth I see my reflection",
    "/rSo about that,",
    "/rThe good news is I can hear you now",
    "/rAs for the bad news…",
    "@bathroom scene Show version of sprite with all features for 1 second (have eye blink a few times)",
    "@black screen",
    "/rAll of my remaining facial features have manifested on your body",
    {
        ["Express Grievances"] = {
            "@- 1 good",
            "This is terrible",
            "/rIs it?",
            "Yes. This simply isn’t normal.",
            "I can only imagine what my manager will think.",
            "He’ll likely be rather displeased",
            "/rI wish I knew what to say",
            "I can’t exactly go to work like this…",
            "Can I.",
            "I don’t see any reason you can't",
            "But do you want to?",
            {
                ["Explain that you have to"] = {
                    "I have to",
                    "/rNo, I have to",
                    "/rBut I only have to if you want to",
                },
                ["Explain that you know what you want"] = {
                    "I know what I want"
                }
            }
        },
        ["Express excitement"] = {
            "@+ 1 good",
            "At this point, the more the merrier I suppose.",
            "But what should we do now?",
            "/rIm afraid I don't know.",
            "/rI think you’ll find I have little agency in our current predicament haha",
            "/rI suppose I’m but a passenger of your whims my captain",
            "/rIm sorry that sounds dumb",
            "/rI wish I knew what to say",
            "I can’t exactly go to work like this…",
            "Can I?",
            "I don’t see any reason you can't",
            "But do you want to?",
            {
                ["Explain that you have to"] = {
                    "I have to",
                    "/rNo, I have to",
                    "/rBut I only have to if you want to",
                },
                ["Explain that you know what you want"] = {
                    "I know what I want"
                }
            }
        },
        ["Inquire Further"] = {
            "What are you exactly?",
            "/rMy name is Letty, and I’m not entirely sure “what” I am.",
            "/rI'm just me",
            "But you’re not you. This is my body. Are you some kind of parasite?",
            "/rI should hope not, I already feel terribly guilty about this whole ordeal.",
            "Sigh, well what do we know?",
            "/rIm afraid I don't know.",
            "/rI think you’ll find I have little agency in our current predicament haha",
            "/rI suppose I’m but a passenger of your whims my captain",
            "/rIm sorry that sounds dumb",
            "/rI wish I knew what to say",
            "I can’t exactly go to work like this…",
            "Can I?",
            "I don’t see any reason you can't",
            "But do you want to?",
            {
                ["Explain that you have to"] = {
                    "I have to",
                    "/rNo, I have to",
                    "/rBut I only have to if you want to",
                },
                ["Explain that you know what you want"] = {
                    "I know what I want"
                }
            }
        }
    },
    function(val, tbl)
        return tbl.vars.good >= 2 and {
            ["Go to work"] = {
                "I'm going to work.",
                "/r*sigh",
                "/rAye aye captain",
                "@animate Sprite automatically to walk to work and go up elevator and bang head on keyboard",
                "@fade to black text screen",
                "Again.",
                "@end",
            },
            ["About that museum…"] = {
                "I want to go to that museum.",
                "/rHehe",
                "/rI was rather hoping that you would resolve to take me to the /rmuseum",
                "Then we'll spend the day at the museum",
                "/rShall we call it a date?",
                "Shall we?",
                "/rIf you want.",
                {
                    Yes = {
                        "@+ 1 good",
                        "We shall"
                    },
                    ["We shan't"] = {
                        "@- 1 good",
                        "Let's see where things go"
                    }
                }
            }
        } or {
            ["Go to work"] = {
                "I'm going to work.",
                "/r*sigh",
                "/rAye aye captain",
                "@sprite animates automatically to walk to work and go up elevator and bang head on keyboard",
                "@fade to black text screen",
                "Again.",
                "@end",
            },
            ["Avoid going to work"] = {
                "I can’t go to work like this, it’s not normal.",
                "/rI’m terribly sorry",
                "/rAt least now you can finally take a well-deserved work from break",
                {
                    No = {
                        "@- 1 good",
                        "I can’t take a break. I’ve worked every day",
                        "And will work everyday",
                        "But now I can’t",
                        "And it’s your fault.",
                        "…",
                        "I am sorry.",
                        "I’ll…",
                        "I’ll give you some space to think",
                        "…",
                        "Thank you.",
                        "…",
                        "@new",
                        "I decided to go for a walk.",
                        "@cut to walking scene. The office should be closed while the museum is open",
                    },
                    Yes = {
                        "@+ 1 good",
                        "You may be right.",
                        "I want to go to that museum.",
                        "/rHehe",
                        "/rI was rather hoping that you would resolve to take me to the /rmuseum",
                        "Then we'll spend the day at the museum",
                        "/rShall we call it a date?",
                        {
                            ["We shall"] = {
                                "@+ 1 good",
                                "I would like that"
                            },
                            ["We shan't"] = {
                                "@- 1 good",
                                "I’d really rather not",
                                "/rThat’s quite alright.",
                                "/rActually I’d prefer you forget I asked",
                            }
                        }
                    }
                }
            }
        }
    end,
    "@cut to museum",
    function(val, tbl)
        return tbl.vars.good >= 3 and {
            "@museum apple guy painting, show scene for like 3 or 4 seconds",
            "@black text frame",
            "I think I’ve seen that one before",
            "/rWhich one?",
            "At the end of the hall there.",
            "The one with apple.",
            "I think it used to be important to me",
            "/rWhy’s that?",
            "I can’t say that I really know.",
            "/rWill you-",
            "What?",
            "/rWill you grant me a kiss",
            "I don’t understand",
            "/rYou heard what I asked.",
            {
                Yes = {
                    "@display sprite with all features, none covered, player uses arrow keys to pivot arm up to mouth, faded checkerboard background"
                },
                No = {
                    "I don’t think that would be appropriate.",
                    "/rOkay I apologize.",
                    "/rI got the wrong idea.",
                    "That’s okay.",
                }
            },
            "/rI actually have something of a surprise for for you.",
            "What's that?",
            "/rTurn around.",
            "@display faceless woman for 5 seconds",
            "@black text frame",
            "/rIt’s nice to meet you face to face after all this time.",
            "@fade to black, end",
        } or {
            "@museum sisyphus painting, show scene for like 3 or 4 seconds",
            "I look at the painting at the end of the hall.",
            "I can’t stop staring at it.",
            "It makes me uncomfortable.",
            "But it’s transfixing.",
            "I shut my eyes.",
            "@new black text frame",
            "I turn around.",
            "@display faceless woman for 5 seconds",
            "@black text frame",
            "/rHello,",
            "/rIt's a pleasure  to finally meet you face to face.",
            "/rWell, I suppose this isn’t quite face to face.",
            "@SFX gross_blink",
            "@display faceless woman with facial features for 2 seconds",
            "/rThats better.",
            "/rI suppose this is goodbye.",
            "@new black frame",
            "…",
            "They left me.",
            "…",
            "…",
            "…",
            "I feel lonely.",
            "@fade to black, end",
        }
    end
}
return script