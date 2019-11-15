module Api.Main exposing (get, post, createCharacter)

import Api.Endpoint as Endpoint
import Api.UrlBuilder exposing (UrlBuilder)
import Http
import Json.Decode as Decode
import Modules.CharacterData exposing (characterDataDecoder, characterDataEncoder)
import Types.CharacterData exposing (CharacterData, defaultCharacterData)


get : Endpoint.Endpoint -> (Result Http.Error a -> msg) -> Decode.Decoder a -> Cmd msg
get url handler decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson handler decoder
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }

post : Endpoint.Endpoint -> (Result Http.Error a -> msg) -> Decode.Decoder a -> Http.Body -> Cmd msg
post url handler decoder body =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson handler decoder
        , headers = []
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }


createCharacter : ((Result Http.Error (String, CharacterData)) -> msg) ->{a | urlBuilder: UrlBuilder, player: {b| id: String}} -> Cmd msg
createCharacter msg {urlBuilder, player} =
    post (Endpoint.createCharacter urlBuilder) msg (Decode.map2 (\key -> \value -> (key, value)) (Decode.at ["ref", "@ref", "id"] Decode.string) (characterDataDecoder "data")) (Http.jsonBody (characterDataEncoder { defaultCharacterData | playerId = player.id }))