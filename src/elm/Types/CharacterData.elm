module Types.CharacterData exposing (CharacterData)


type alias CharacterData =
    { characterName : String
    , level : Int
    , armorType : String
    , strength : Int
    , perception : Int
    , endurance : Int
    , charisma : Int
    , intelligence : Int
    , agility : Int
    , luck : Int
    }
