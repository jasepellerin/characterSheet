module Api.Endpoint exposing (Endpoint, createCharacter, getCharactersForPlayer, getCharacter, request, updateCharacter)

import Api.UrlBuilder exposing (UrlBuilder)
import Http


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


url : UrlBuilder -> List String -> Endpoint
url urlBuilder paths =
    urlBuilder
        (List.append [ ".netlify", "functions" ] paths)
        []
        |> Endpoint



-- ENDPOINTS


getCharacter : UrlBuilder -> String -> Endpoint
getCharacter urlBuilder slug =
    url urlBuilder [ "getCharacter", slug ]


getCharactersForPlayer : UrlBuilder -> String -> Endpoint
getCharactersForPlayer urlBuilder slug =
    url urlBuilder [ "getCharactersForPlayer", slug ]

updateCharacter : UrlBuilder -> String -> Endpoint
updateCharacter urlBuilder slug =
    url urlBuilder [ "updateCharacter", slug ]


createCharacter : UrlBuilder -> Endpoint
createCharacter urlBuilder =
    url urlBuilder [ "createCharacter" ]
