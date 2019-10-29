module Modules.Skills exposing (CharacterSkills, Skill, combatSkills)
import Dict exposing (Dict)


type alias Skill =
    { name : String, attribute : String }


type alias CharacterSkills =
    Dict String Bool


combatSkills : List Skill
combatSkills =
    [ { name = "energy_weapons", attribute = "perception" }
    , { name = "melee_weapons", attribute = "strength" }
    , { name = "explosives", attribute = "perception" }
    , { name = "unarmed", attribute = "endurance" }
    , { name = "guns", attribute = "agility" }
    ]
