module Types.CharacterData exposing (CharacterData, defaultCharacterData)

import Modules.Skills exposing (CharacterSkills)
import Dict exposing (Dict)


type alias CharacterData =
    { name : String
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
    , playerId : String
    }

defaultCharacterData = {
    name = "Unnamed Wanderer"
    , level = 1
    , armorType = "no armor"
    , strength = 1
    , perception = 1
    , endurance = 1
    , charisma = 1
    , intelligence = 1
    , agility = 1
    , luck = 1
    , skills = Dict.empty
    , playerId = "" }