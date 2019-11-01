module Modules.Skills exposing (CharacterSkills, Skill, combatSkills, nonCombatSkills)

import Dict exposing (Dict)


type alias Skill =
    { name : String, attribute : String }


type alias CharacterSkills =
    Dict String Bool


combatSkills : List Skill
combatSkills =
    [ { name = "energy_weapons", attribute = "perception" }
    , { name = "explosives", attribute = "perception" }
    , { name = "guns", attribute = "agility" }
    , { name = "melee_weapons", attribute = "strength" }
    , { name = "unarmed", attribute = "endurance" }
    ]


nonCombatSkills : List Skill
nonCombatSkills =
    [ { name = "barter", attribute = "charisma" }
    , { name = "lockpick", attribute = "perception" }
    , { name = "medicine", attribute = "intelligence" }
    , { name = "repair", attribute = "intelligence" }
    , { name = "science", attribute = "intelligence" }
    , { name = "sneak", attribute = "agility" }
    , { name = "speech", attribute = "charisma" }
    , { name = "survival", attribute = "endurance" }
    ]
