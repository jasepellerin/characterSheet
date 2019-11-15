module Route exposing (Route(..), fromUrl, toHref, changeRoute)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)
import Ports exposing (log)
import Json.Encode as Encode


type Route
    = CharacterSelect
    | CharacterSheet String
    | CreateCharacter


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map CharacterSelect Parser.top
        , Parser.map CharacterSelect (s "characters")
        , Parser.map CharacterSheet (s "character" </> string)
        , Parser.map CreateCharacter (s "createCharacter")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


toHref : Route -> String
toHref route =
    case route of
        CharacterSelect ->
            "/characters"

        CharacterSheet slug ->
            "/character/" ++ slug

        CreateCharacter ->
            "/createCharacter"


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                CharacterSelect ->
                    [ "characters" ]

                CharacterSheet slug ->
                    [ "character", slug ]

                CreateCharacter ->
                    [ "createCharacter" ]
    in
    "#/" ++ String.join "/" pieces


changeRoute : Maybe Route -> {a | route: Route, selectedCharacterId : String} -> ( {a | route: Route, selectedCharacterId : String}, Cmd msg )
changeRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( model, log (Encode.string "Not found") )

        Just CharacterSelect ->
            ( { model | route = CharacterSelect }, log (Encode.string "CharacterSelect") )

        Just (CharacterSheet slug) ->
            ( { model | route = CharacterSheet slug, selectedCharacterId = slug }, log (Encode.string ("CharacterSheet - " ++ slug)) )

        Just CreateCharacter ->
            ( { model | route = CreateCharacter }, log (Encode.string "CreateCharacter") )
