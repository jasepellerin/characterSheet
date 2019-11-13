module Modules.Player exposing (Player)

import Types.CharacterData exposing (CharacterData)
import Dict exposing (Dict)


type alias Player =
    { id : String
    , characters : Dict String CharacterData
    }
