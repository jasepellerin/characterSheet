module Modules.Player exposing (Player)

import Modules.CharacterData exposing (CharacterData)
import Dict exposing (Dict)


type alias Player =
    { id : String
    , characters : Dict String CharacterData
    }
