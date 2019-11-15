module Modules.Player exposing (Player, getCharactersForPlayer)

import Api.Endpoint as Endpoint
import Api.Main as Api
import Api.UrlBuilder exposing (UrlBuilder)
import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Modules.CharacterData exposing (characterDataDecoder)
import Types.CharacterData exposing (CharacterData)



-- TYPES


type alias Player =
    { id : String
    , characters : Dict String CharacterData
    }



-- API


characterListDecoder : Decode.Decoder (Dict String CharacterData)
characterListDecoder =
    Decode.map Dict.fromList (Decode.list (Decode.map2 (\key -> \value -> ( key, value )) (Decode.at [ "ref", "@ref", "id" ] Decode.string) (characterDataDecoder "data")))


getCharactersForPlayer : (Result Http.Error (Dict String CharacterData) -> msg) -> { a | player : Player, selectedCharacterId : String, urlBuilder : UrlBuilder } -> Cmd msg
getCharactersForPlayer msg { player, selectedCharacterId, urlBuilder } =
    Api.get (Endpoint.getCharactersForPlayer urlBuilder player.id) msg (Decode.field "data" characterListDecoder)
