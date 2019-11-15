module Modules.Armor exposing (Armor, armors, getArmorEnduranceRequirement, getMaybeArmor)

import Dict exposing (Dict)


type alias Armor =
    { armorClass : Int
    , enduranceRequirement : Int
    , moveCostPenalty : Int
    , dodgeMultiplier : Float
    }


armors =
    Dict.fromList
        [ ( "no armor", Armor 0 0 0 1 )
        , ( "light", Armor 2 3 -1 0.75 )
        , ( "medium", Armor 4 5 -2 0.5 )
        , ( "heavy", Armor 7 7 -4 0 )
        ]


getMaybeArmor : String -> Maybe Armor
getMaybeArmor armorType =
    Dict.get armorType armors


getArmorEnduranceRequirement : String -> Int
getArmorEnduranceRequirement armorType =
    case getMaybeArmor armorType of
        Just armor ->
            armor.enduranceRequirement

        Nothing ->
            0
