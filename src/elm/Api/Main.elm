module Api.Main exposing (get)

import Api.Endpoint as Endpoint
import Http
import Json.Decode as Decode


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
