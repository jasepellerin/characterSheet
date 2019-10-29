module Skills exposing (Skill, combatSkills)


type alias Skill =
    { name : String, attribute : String }


combatSkills : List Skill
combatSkills =
    [ { name = "energy_weapons", attribute = "perception" }
    , { name = "melee_weapons", attribute = "strength" }
    , { name = "explosives", attribute = "perception" }
    , { name = "unarmed", attribute = "endurance" }
    , { name = "guns", attribute = "agility" }
    ]
