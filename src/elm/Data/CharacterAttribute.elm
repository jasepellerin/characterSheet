module Data.CharacterAttribute exposing (CharacterAttribute, characterAttributes)

import Types.UpdateAttributeMsg exposing (..)


type alias CharacterAttribute a b =
    { accessor : a -> b
    , updateMsg : String -> UpdateAttributeMsg
    }


characterAttributes =
    [ { attributeName = "strength", attribute = CharacterAttribute .strength UpdateStrength, specificTitle = "💪" }
    , { attributeName = "perception", attribute = CharacterAttribute .perception UpdatePerception, specificTitle = "🕵" }
    , { attributeName = "endurance", attribute = CharacterAttribute .endurance UpdateEndurance, specificTitle = "\u{1F98D}" }
    , { attributeName = "charisma", attribute = CharacterAttribute .charisma UpdateCharisma, specificTitle = "🗣" }
    , { attributeName = "intelligence", attribute = CharacterAttribute .intelligence UpdateIntelligence, specificTitle = "\u{1F9E0}" }
    , { attributeName = "agility", attribute = CharacterAttribute .agility UpdateAgility, specificTitle = "🏃" }
    , { attributeName = "luck", attribute = CharacterAttribute .luck UpdateLuck, specificTitle = "🍀" }
    ]
