--- The script containing all of the dialogue and implementing most of the game flow.
--- @module Script


--TODO: Eye animation
--TODO: Bathroom wave scene
--TODO: Scene transitions?
--TODO: Arm covering eye scene
--TODO: Walking on street scene
--TODO: Office scene walking to desk
--TODO: Desk scene + animation

--TODO: Needed assets: Walking to office, faceless woman, office walking to desk, at desk

local parser = require "parser"
local scene = require "scene"
local scheduler = require "scheduler"


local script
script = {
    vars = { good = 0, outfit = "nice" }, --Easier to declare the variables beforehand so you don't have to check if they exist later.
    "@SFX bap_2",
    "I’m standing by a lake",
    "Or maybe more of a wide river that’s moving really slowly",
    "Everything is a little out of focus",
    "@SFX air_raid_siren",
    --"@scene eyeAnimation",
    "I wake up",
    "@scene armWaving",
    "Time to get ready for the day.",
    {
        ["I want to look nice"] = {
            "@store outfit nice"
        },
        ["Gray and drab"] = {
            "@store outfit gray"
        },
        ["Blocky and drab"] = {
            "@store outfit blocky"
        },
        ["Attractive yet respectable"] = {
            "@store outfit attractive"
        }
    },
    function()
        parser.processLine(("I slide on my %s outfit."):format(script.vars.outfit))
    end,
    "It feels rough against my skin.",
    "@scene bathroom",
    "I proceed to my bathroom and look at my reflection.",
    "My reflection judges me from the mirror.",
    --(insert type of outfit here) outfit.
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
    function()
        --cut to her in bathroom looking into mirror with eye close no scarf sprite
        --        scene.set("bathroom", "Character", "???")
        scene.switch "bathroom"
    end,
    "@SFX gross_blink",
    --"@scene eyeAnimation",
    "I cover the eye protruding from my neck.",
    --"@scene scarfAnimation",
    "The eye undulates slightly under the my scarf.",
    "I groan again.",
    "And so completes my morning routine.",
    "@new",
    "As I walk to work I feel the eye throbbing under my scarf.",
    "It's hot on my neck",
    "It blinks on every third step",
    "I don’t know whose eye it is",
    "I don’t have any control over it",
    "I feel every movement",
    "Uncomfortable as it is, I'm used to it.",
    "I stopped trying to figure out who it belongs a while ago",
    "Cover it up and go about my business.",
    "That's my motto.",
    --"@scene walking",
    "@new",
    "I groan before entering the elevator.",
    "Another day another dollar.",
    --"@scene elevator",
    "I groan as I exit the elevator",
    "The eye on my neck pulsates",
    "…presumably in reciprocation",
    --"@scene office",
    "@SFX head_bang",
    function()
        parser.lock()
        scene.fadeOut(5, parser.unlock)
    end,
    "Again. Again there is a river",
    "Again flowing slowly",
    "I attempt to turn away",
    "@SFX air_raid_siren",
    --"@scene eyeAnimation",
    "Again I wake up.",
    "Again I proceed with my normal routine.",
    "Again I cover the eye protruding from my neck.",
    --"@scene scarfAnimation"
    "As I walk to work I feel the eye throbbing under my scarf.",
    --"@scene walking"
    "@new",
    "Again I groan before entering the elevator.",
    "Another, another day another, another dollar.",
    "@scene elevator",
    "I groan as I exit the elevator.",
    "The eye on my neck pulsates",
    --"@scene office",
    "…presumably in reciprocation.",
    --"@scene desk",
    "@SFX head_bang",
    function()
        parser.lock()
        scheduler.after(5, function()
            scene.circularFadeOut(1.5, parser.unlock)
        end)
    end,
    "Again.",
    "Again there is a river.",
    "Again flowing slowly.",
    "I approach the water.",
    "I stare into my reflection in the distorting flow.",
    "It’s uncanny.",
    "Enchanting.",
    "But it its not -",
    "@SFX air_raid_siren",
    --"@scene eyeAnimation",
    "Again I wake up",
    "Again I proceed with my normal routine",
    "But I stop",
    "Again My forearm itches",
    "I scratch it without thinking",
    "@SFX Lick",
    "It licks me.",
    function()
        --(show bathroom reflection with sprite that has eye on neck and mouth on forearm for 2 seconds)
        parser.lock()
        --scene.set("bathroom", "Character", "???")
        scene.switch "bathroom"
        scene.clearAll()
        scheduler.after(2, parser.unlock)
    end,
    "I certainly cannot go to work like this.",
    "I find an old glove in my wardrobe.",
    "It smells like cigarettes and the elderly.",
    function()
        --(show bathroom reflection with sprite that has eye on neck and mouth on forearm
        --scene.set("bathroom", "Character", "???")
        scene.switch "bathroom"
    end,
    "@SFX bap_3",
    --mouth flops, cut to black screen and show text colors as indicated red :red black :white, additionally, the red text should appear on its own [without the player's arrow key prompting] in near immediate response to white text )
    "@SFX bap_2",
    "/rPlease do not cover me again.",
    "What?",
    "/rIt’s just that…",
    "/rI'm not terribly fond of the dark.",
    {
        Refuse = {
            "@add good 1",
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
            --"@scene scarfAnimation",
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
            "@add good 1",
            "*I nod",
            "Okay.",
            "/rThank you",
        }
    },
    function(val, tbl)
        return script.vars.good <= 1 and {
            --"@scene walking",
            "@new",
            "I feel a pressure on my arm",
            "My neck feels like it's on fire",
            "As I enter the elevator I tighten my scarf and press on my arm",
            "I wince slightly as I hear what sounds like a muffled groan escape the lips on my arm.",
            {
                ["Uncover them"] = {
                    "@add good 1",
                    "I slide the glove off my arm and remove the cotton balls from the mouth",
                    "/rThank you.",
                    "You're welcome now what are you on about? ",
                },
                ["Silence them"] = {
                    "@subtract good 1",
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
            "@scene elevator",
            --"@scene desk"
            "@SFX banging noise",
            function()
                parser.lock()
                scene.fadeOut(5, parser.unlock())
            end,
        }
    end,
    function(val, tbl)
        return script.vars.good >= 1 and {
            "/r..all im saying is that this elevator seems arbitrarily convoluted.",
            "*I laugh heartily",
            "Yes, i suppose it is",
            "It is normal though",
            "Oh that’s right, you can’t hear me",
            "*I make an exaggerated laughing gesture at my reflection",
            "/rThe lips curl into a smile",
        } or false
    end,
    --"@scene office",
    --"@scene desk",
    function()
        parser.lock()
        scene.fadeOut(5, parser.unlock)
    end,
    "Again the river",
    "Again I approach the water",
    "Again I gaze at my reflection in the distorting flow",
    "Again It’s uncanny.",
    "Again I am enchanted",
    "But it its not me",
    "It’s someone familiar,",
    "but I can’t seem to make out their face",
    "@SFX air_raid_siren",
    --"@scene eyeAnimation"
    function()
        return script.vars.good >= 1 and {
            "/rGood morning sleeping beauty",
            "Uhh…",
            "Good morning?",
        } or {
            "I wake up"
        }
    end,
    "@new",
    "I proceed with my “normal” routine",
    "As I’m brushing my teeth I see my reflection",
    "/rSo about that,",
    "/rThe good news is I can hear you now",
    "/rAs for the bad news…",
    function()
        --bathroom scene Show version of sprite with all features for 1 second (have eye blink a few times)",
        scene.set("bathroom", "Character", "???")
        scene.switch "bathroom"
    end,
    "@new",
    "/rAll of my remaining facial features have manifested on your body",
    {
        ["Express Grievances"] = {
            "@subtract good 1",
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
            "@add good 1",
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
    function()
        return script.vars.good >= 2 and {
            ["Go to work"] = {
                "I'm going to work.",
                "/r*sigh",
                "/rAye aye captain",
                --animate Sprite automatically to walk to work and go up elevator and bang head on keyboard",
                function()
                    parser.lock()
                    scene.fadeOut(5, parser.unlock)
                end,
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
                        "@add good 1",
                        "We shall"
                    },
                    ["We shan't"] = {
                        "@subtract good 1",
                        "Let's see where things go"
                    }
                }
            }
        } or {
            ["Go to work"] = {
                "I'm going to work.",
                "/r*sigh",
                "/rAye aye captain",
                --sprite animates automatically to walk to work and go up elevator and bang head on keyboard
                function()
                    parser.lock()
                    scene.fadeOut(5, parser.unlock)
                end,
                "Again.",
                "@end",
            },
            ["Avoid going to work"] = {
                "I can’t go to work like this, it’s not normal.",
                "/rI’m terribly sorry",
                "/rAt least now you can finally take a well-deserved work from break",
                {
                    No = {
                        "@subtract good 1",
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
                        --cut to walking scene. The office should be closed while the museum is open",
                    },
                    Yes = {
                        "@add good 1",
                        "You may be right.",
                        "I want to go to that museum.",
                        "/rHehe",
                        "/rI was rather hoping that you would resolve to take me to the /rmuseum",
                        "Then we'll spend the day at the museum",
                        "/rShall we call it a date?",
                        {
                            ["We shall"] = {
                                function()
                                    script.vars.good = script.vars.good + 1
                                end,
                                "I would like that"
                            },
                            ["We shan't"] = {
                                function()
                                    script.vars.good = script.vars.good - 1
                                end,
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
    --cut to museum
    function()
        return script.vars.good >= 3 and {
            --museum apple guy painting, show scene for like 3 or 4 seconds
            --black text frame
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
                    --display sprite with all features, none covered, player uses arrow keys to pivot arm up to mouth, faded checkerboard background
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
            --display faceless woman for 5 seconds",
            "@new",
            "/rIt’s nice to meet you face to face after all this time.",
            function()
                scene.circularFadeOut(5, parser.processLine("@end", script))
            end
        } or {
            --museum sisyphus painting, show scene for like 3 or 4 seconds
            "I look at the painting at the end of the hall.",
            "I can’t stop staring at it.",
            "It makes me uncomfortable.",
            "But it’s transfixing.",
            "I shut my eyes.",
            "@new",
            "I turn around.",
            --display faceless woman for 5 seconds
            "@new",
            "/rHello,",
            "/rIt's a pleasure  to finally meet you face to face.",
            "/rWell, I suppose this isn’t quite face to face.",
            "@SFX gross_blink",
            --display faceless woman with facial features for 2 seconds
            "/rThats better.",
            "/rI suppose this is goodbye.",
            "@new",
            "…",
            "They left me.",
            "…",
            "…",
            "…",
            "I feel lonely.",
            function()
                scene.fadeOut(5, parser.processLine("@end", script))
            end
        }
    end
}
return script