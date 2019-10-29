module Modules.CharacterData exposing (CharacterData)
import Modules.Skills exposing (CharacterSkills)


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
    , skills : CharacterSkills
    }
