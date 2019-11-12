module Api.Endpoint exposing (Endpoint, createCharacter, getCharacter, updateCharacter)

import Http
import Url.Builder exposing (QueryParameter)



-- TYPES


type Endpoint
    = Endpoint String


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Url.Builder.absolute
        (List.append [ ".netlify", "functions" ] paths)
        queryParams
        |> Endpoint



-- ENDPOINTS


getCharacter : String -> Endpoint
getCharacter slug =
    url [ "getCharacter", slug ] []


updateCharacter : String -> Endpoint
updateCharacter slug =
    url [ "updateCharacter", slug ] []


createCharacter : Endpoint
createCharacter =
    url [ "createCharacter" ] []
