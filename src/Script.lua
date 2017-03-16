local script = {
    "“Bap bap dialogue sounds play upon each line of dialogue appearing:I ’ m standing by a lake",
    "Or maybe more of a wide river that ’ s moving really slowl",
    "Everything is a little out of focus",
    "* ALARM NOISE (air raid sound)",
    "@ Eye opening to white background vignette shadows from edges",
    "I wake up",
    "@ Bathroom(art scene) give player ability to hinge move arm so they can kinda “ wave hello ”",
    "Time to get ready for the day.I want to look nice.@ Gray and drab, blocky and drab, Attractive yet respectable",
    "@ Save type of outfi",
    "I slide on my (insert type of outfit here) outfit",
    "It feels rough against my skin.I proceed to my bathroom and look at my reflection .My reflection judges me from its",
    "@ (insert type of outfit here) outfit.My reflection can be very judgemental .I don 't think it sleeps enough.",
    "I proceed with my normal routine .Brush teeth .Gargle.Rinse.Skip flossing .Read yesterdays paper on toilet",
    "@ new black screen",
    "Groan .Comb hair .Apply foundation .And of course …",
    "@ cut to her in bathroom looking into mirror with eye close no scarf sprite",
    "* sfx gross noise *",
    "@ Eye flutters open",
    "I cover the eye protruding from my neck.@ Animation arm covers eye on neck with scarf, only rotates as player holds arrow key",
    "The eye undulates slightly under the my scarf.I groan again.And so completes my morning routine .@ new black screen",
    "As I walk to work I feel the eye throbbing under my scarf.It 's hot on my neck",
    "It blinks on every third step",
    "I don ’ t know whose eye it is",
    "I don ’ t have any control over it",
    "I feel every movement",
    "Uncomfortable as it is , I 'm used to it.",
    "I stopped trying to figure out who it belongs a while ago",
    "Cover it up and go about my business .That 's my motto.",
    "@ Walking on street scene , arrow keys to walk arrive at building, space to enter",
    "@ New black screen",
    "I groan before entering the elevator.Another day another dollar .@(elevator sequence arrow key controls to move elevator from point to point on the tower)",
    "I groan as I exit the elevator",
    "The eye on my neck pulsates",
    "… presumably in reciprocation",
    "@ ( in office allows player to press arrow keys to walk up to sit in chair.arrow key to bang head on keyboard after sitting down .* SFX banging noise * 5 seconds after sitting down fade to black)",
    "Again.Again there is a river",
    "Again flowing slowly",
    "I attempt to turn away",
    "* SFX air raid alarm *",
    "@ Eye opening to white background vignette shadows from edges",
    "Again I wake up.Again I proceed with my normal routine.Again I cover the eye protruding from my neck.@ Animation arm covers eye on neck with scarf, only rotates as player holds arrow key",
    "As I walk to work I feel the eye throbbing under my scarf .@ Walking on street scene, arrow keys to walk arrive at building, space to enter",
    "@ New black screen",
    "Again I groan before entering the elevator .Another, another day another, another dollar .@(elevator sequence arrow key controls to move elevator from point to point on the tower)",
    "I groan as I exit the elevator.The eye on my neck pulsates",
    "… presumably in reciprocation.@( in office allows player to press arrow keys to walk up to sit in chair.arrow key to bang head on keyboard after sitting down .* SFX banging noise * 5 seconds after sitting down fade to black)",
    "Again.Again there is a river.Again flowing slowly.I approach the water .I stare into my reflection in the distorting flow.It ’ s uncanny .Enchanting.But it its not -",
    "* SFX air raid alarm *",
    "@ Eye opening shaped transition to white screen",
    "Again I wake up",
    "Again I proceed with my normal routine",
    "But I stop",
    "Again My forearm itches",
    "I scratch it without thinking",
    "* SFX lick * It licks me.@(show bathroom reflection with sprite that has eye on neck and mouth on forearm for 2 seconds)",
    "I certainly cannot go to work like this .I find an old glove in my wardrobe .It smells like cigarettes and the elderly .@(show bathroom reflection with sprite that has eye on neck and mouth on forearm * SFX BAP BAP BAP mouth flops , cut to black screen and show text colors as indicated red :red black :white, additionally, the red text should appear on its own [without the player 's arrow key prompting] in near immediate response to white text )",
    "r / * SFX BAP BAP * Please do not cover me again.",
    "What ?",
    "r / It ’ s just that …",
    "r / I 'm not terribly fond of the dark.",
    {
        Refuse = {
            "@-1 to good",
            "ook I can’t go to work with someone else’s facial features on my arm.",
            "/ *SFX BAP BAP* Im afraid I cannot read lips, and I’ve no ear on your body but please just don’t cover me.",
            "ake me to work with you.",
            "/ It will be fine I promise.",
            "...",
            "/ …",
            "/ Please.",
            "*I shake my head*",
            "/ Please don’t, I may suffocate.",
            "/ If you cover me ill…",
            "/ I'll scream all day.",
            " shove cotton balls in their mouth.",
            " them slide my glove over their writhing lips.",
            "@Animation arm covers eye on neck with scarf, only rotates as player holds arrow key",
        },
        ["Ask what they are"] = {
            "ine, but what are you exactly?",
            "/ *SFX BAP BAP* Im afraid I cannot read lips, and I’ve no ear on your body but please just don’t cover me.",
            "/ Take me to work with you.",
            "/ It will be fine I promise.",
            "...",
            "/ …",
            "/ Please.",
        },
        ["“Accept”"] = {
            "@+1 to good",
            "*I nod*",
            "Okay.",
            "r/ Thank you",
        }
    },
    function(good) return good <= 1 and {
        "@Walking on street scene, arrow keys to walk arrive at building, space to enter",
        "@New black screen",
        "I feel a pressure on my arm",
        "My neck feels like it's on fire",
        "As I enter the elevator I tighten my scarf and press on my arm",
        "I wince slightly as I hear what sounds like a muffled groan escape the lips on my arm.",
        {
            ["Uncover them"] = {
                "+1 to good",
                " slide the glove off my arm and remove the cotton balls from the mouth",
                "/ Thank you.",
                "You're welcome now what are you on about? ",
            },
            ["Silence them"] = {
                "@-1 to good",
                "*SFX distressed bap bap*",
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
        "@(in office allows player to press arrow keys to walk up to sit in chair. arrow key to bang head on keyboard after sitting down. *SFX banging noise* 5 seconds after sitting down fade to black)",
    }
    end,
    function(good) return good >= 1 and {
        "r/ ..all im saying is that this elevator seems arbitrarily convoluted.",
        "*I laugh heartily*",
        "Yes, i suppose it is",
        "It is normal though",
        "Oh that’s right, you can’t hear me",
        "*I make an exaggerated laughing gesture at my reflection*",
        "r/ The lips curl into a smile",
    } or false
    end,
    "@(in office allows player to press arrow keys to walk up to sit in chair. arrow key to bang head on keyboard after sitting down. *SFX banging noise* 5 seconds after sitting down fade to black)",
    "Again the river",
    "Again I approach the water",
    "Again I gaze at my reflection in the distorting flow",
    "Again It’s uncanny.",
    "Again I am enchanted",
    "But it its not me",
    "It’s someone familiar,",
    "but I can’t seem to make out their face",
    "*SFX air raid alarm*",
    "@Eye opening to white background vignette shadows from edges",
    function(good) return good >= 1 and {
        "/r Good morning sleeping beauty",
        "Uhh…",
        "Good morning?",
    } or {
        "I wake up"
    }
    end,
    "@black frame",
    "I proceed with my “normal” routine",
    "As I’m brushing my teeth I see my reflection",
    "/r So about that,",
    "/r The good news is I can hear you now",
    "/r As for the bad news...",
    "@bathroom scene Show version of sprite with all features for 1 second (have eye blink a few times)",
    "@black screen",
    "/r All of my remaining facial features have manifested on your body",
    {
        ["Express Grievances"] = {
            "@-1 to good",
            "This is terrible",
            "r/ Is it?",
            "Yes. This simply isn’t normal.",
            "I can only imagine what my manager will think.",
            "He’ll likely be rather displeased",
            "/r I wish I knew what to say",
            "I can’t exactly go to work like this…",
            "Can I.",
            "I don’t see any reason you can't",
            "But do you want to?",
            {
                ["Explain that you have to"] = {
                    "I have to",
                    "/r No, I have to",
                    "/r But I only have to if you want to",
                },
                ["Explain that you know what you want"] = {
                    "I know what I want"
                }
            }
        },
        ["Express excitement"] = {
            "@+1 to good",
            "At this point, the more the merrier I suppose.",
            "But what should we do now?",
            "/r Im afraid I don't know.",
            "/r I think you’ll find I have little agency in our current predicament haha",
            "/r I suppose I’m but a passenger of your whims my captain",
            "/r Im sorry that sounds dumb",
            "/r I wish I knew what to say",
            "I can’t exactly go to work like this…",
            "Can I?",
            "I don’t see any reason you can't",
            "But do you want to?",
            {
                ["Explain that you have to"] = {
                    "I have to",
                    "/r No, I have to",
                    "/r But I only have to if you want to",
                },
                ["Explain that you know what you want"] = {
                    "I know what I want"
                }
            }
        },
        ["Inquire Further"] = {
            "What are you exactly?",
            "/r My name is Letty, and I’m not entirely sure “what” I am.",
            "/r I'm just me",
            "But you’re not you. This is my body. Are you some kind of parasite?",
            "/r I should hope not, I already feel terribly guilty about this whole ordeal.",
            "Sigh, well what do we know?",
            "/r Im afraid I don't know.",
            "/r I think you’ll find I have little agency in our current predicament haha",
            "/r I suppose I’m but a passenger of your whims my captain",
            "/r Im sorry that sounds dumb",
            "/r I wish I knew what to say",
            "I can’t exactly go to work like this…",
            "Can I?",
            "I don’t see any reason you can't",
            "But do you want to?",
            {
                ["Explain that you have to"] = {
                    "I have to",
                    "/r No, I have to",
                    "/r But I only have to if you want to",
                },
                ["Explain that you know what you want"] = {
                    "I know what I want"
                }
            }
        }
    },
    function(good) return good >= 2 and {
        ["Go to work"] = {
            "I'm going to work.",
            "r/ *sigh*",
            "r/ Aye aye captain",
            "@ animate Sprite automatically to walk to work and go up elevator and bang head on keyboard",
            "@Fade to black text screen",
            "Again.",
            "@end",
        },
        ["About that museum..."] = {
            "I want to go to that museum.",
            "r/ Hehe",
            "r/ I was rather hoping that you would resolve to take me to the r/ museum",
            "Then we'll spend the day at the museum",
            "r/ Shall we call it a date?",
            "Shall we?",
            "r/ If you want.",
            {
                Yes = {
                    "@+1 to good",
                    "We shall"
                },
                ["We shan't"] = {
                    "@-1 to good",
                    "Let's see where things go"
                }
            }
        }
    } or {
        ["Go to work"] = {
            "I'm going to work.",
            "r/ *sigh*",
            "r/ Aye aye captain",
            "@Sprite animates automatically to walk to work and go up elevator and bang head on keyboard",
            "@Fade to black text screen",
            "Again.",
            "@end",
        },
        ["Avoid going to work"] = {
            "I can’t go to work like this, it’s not normal.",
            "r/ I’m terribly sorry",
            "r/ At least now you can finally take a well-deserved work from break",
            {
                No = {
                    "@-1 to good",
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
                    "@new black screen",
                    "I decided to go for a walk.",
                    "@cut to walking scene. The office should be closed while the museum is open",
                },
                Yes = {
                    "@+1 to good",
                    "You may be right.",
                    "I want to go to that museum.",
                    "r/ Hehe",
                    "r/ I was rather hoping that you would resolve to take me to the r/ museum",
                    "Then we'll spend the day at the museum",
                    "r/ Shall we call it a date?",
                    {
                        ["We shall"] = {
                            "@+1 to good",
                            "I would like that"
                        },
                        ["We shan't"] = {
                            "@-1 to good",
                            "I’d really rather not",
                            "r/ That’s quite alright.",
                            "r/ Actually I’d prefer you forget I asked",
                        }
                    }
                }
            }
        }
    }
    end,
    "@cut to museum",
    function(good) return good >= 3 and {
        "@museum apple guy painting, show scene for like 3 or 4 seconds",
        "@black text frame",
        "I think I’ve seen that one before",
        "r/ Which one?",
        "At the end of the hall there.",
        "The one with apple.",
        "I think it used to be important to me",
        "r/ Why’s that?",
        "I can’t say that I really know.",
        "r/ Will you-",
        "What?",
        "r/ Will you grant me a kiss",
        "I don’t understand",
        "r/ You heard what I asked.",
        {
            Yes = {
                "@display sprite with all features, none covered, player uses arrow keys to pivot arm up to mouth, faded checkerboard background"
            },
            No = {
                "I don’t think that would be appropriate.",
                "r/ Okay I apologize.",
                "r/I got the wrong idea.",
                "That’s okay.",
            }
        },
        "r / I actually have something of a surprise for for you.",
        "What's that?",
        "r/ Turn around.",
        "@display faceless woman for 5 seconds",
        "@black text frame",
        "r/ It’s nice to meet you face to face after all this time.",
        "@fade to black, end",
    } or {
        "@museum sisyphus painting, show scene for like 3 or 4 seconds",
        "I look at the painting at the end of the hall.",
        "I can’t stop staring at it.",
        "It makes me uncomfortable.",
        "It makes me uncomfortable.",
        "But it’s transfixing.",
        "I shut my eyes.",
        "@new black text frame",
        "I turn around.",
        "@display faceless woman for 5 seconds",
        "@black text frame",
        "r/ Hello,",
        "r/ It's a pleasure  to finally meet you face to face.",
        "r/ Well, I suppose this isn’t quite face to face.",
        "*SFX GROSS noise*",
        "@display faceless woman with facial features for 2 seconds",
        "r/ Thats better.",
        "r/ I suppose this is goodbye.",
        "@new black frame",
        "…",
        "They left me.",
        "...",
        "…",
        "…",
        "I feel lonely.",
        "@fade to black, end",
    }
    end
}
return script