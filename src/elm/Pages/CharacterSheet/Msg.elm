module Pages.CharacterSheet.Msg exposing (Msg(..))

import Http
import Types.CharacterData exposing (CharacterData)


type Msg
    = GetCharacter
    | GotCharacter (Result Http.Error CharacterData)
    | HandleChange CharacterData
    | NoOp
