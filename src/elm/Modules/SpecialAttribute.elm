module Modules.SpecialAttribute exposing (SpecialAttribute, SpecialAttributeMsg(..), getSpecialAttribute, specialAttributeNames)

import Dict exposing (Dict)
import Modules.CharacterData exposing (CharacterData)


type SpecialAttributeMsg
    = Strength
    | Perception
    | Endurance
    | Charisma
    | Intelligence
    | Agility
    | Luck
    | AttributeNoOp


type alias SpecialAttribute =
    { accessor : CharacterData -> Int
    , msg : SpecialAttributeMsg
    , tooltip : String
    }


specialAttributeNames : List String
specialAttributeNames =
    [ "strength"
    , "perception"
    , "endurance"
    , "charisma"
    , "intelligence"
    , "agility"
    , "luck"
    ]


specialAttributes : Dict String SpecialAttribute
specialAttributes =
    Dict.fromList
        [ ( "strength", { msg = Strength, accessor = .strength, tooltip = "💪" } )
        , ( "perception", { msg = Perception, accessor = .perception, tooltip = "🕵" } )
        , ( "endurance", { msg = Endurance, accessor = .endurance, tooltip = "\u{1F98D}" } )
        , ( "charisma", { msg = Charisma, accessor = .charisma, tooltip = "🗣" } )
        , ( "intelligence", { msg = Intelligence, accessor = .intelligence, tooltip = "\u{1F9E0}" } )
        , ( "agility", { msg = Agility, accessor = .agility, tooltip = "🏃" } )
        , ( "luck", { msg = Luck, accessor = .luck, tooltip = "🍀" } )
        ]


getSpecialAttribute : String -> Maybe SpecialAttribute
getSpecialAttribute string =
    Dict.get string specialAttributes
