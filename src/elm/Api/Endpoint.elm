module Api.Endpoint exposing (Endpoint, createCharacter, getCharacter, request, updateCharacter)

import Http
import Url.Builder exposing (QueryParameter)


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Http.Body
    , expect : Http.Expect msg
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , tracker : Maybe String
    }
    -> Cmd msg
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , tracker = config.tracker
        }



-- TYPES


type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint urlString) =
    urlString


url : List String -> Endpoint
url paths =
    Url.Builder.crossOrigin
        "http://localhost:8888"
        (List.append [ ".netlify", "functions" ] paths)
        []
        |> Endpoint



-- ENDPOINTS


getCharacter : String -> Endpoint
getCharacter slug =
    url [ "getCharacter", slug ]


updateCharacter : String -> Endpoint
updateCharacter slug =
    url [ "updateCharacter", slug ]


createCharacter : Endpoint
createCharacter =
    url [ "createCharacter" ]
