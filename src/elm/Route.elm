module Route exposing (Route(..), changeRoute, fromUrl, toHref)

import Json.Encode as Encode
import Ports exposing (log)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s, string)
import Url.Parser.Query as Query


type Route
    = CharacterSelect
    | CharacterSheet String (Maybe String)
    | CreateCharacter


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map CharacterSelect Parser.top
        , Parser.map CharacterSelect (s "characters")
        , Parser.map CharacterSheet (s "character" </> string <?> Query.string "tab")
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

        CharacterSheet slug tab ->
            case tab of
                Just tabName ->
                    "/character/" ++ slug ++ "?tab=" ++ tabName

                Nothing ->
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

                CharacterSheet slug tab ->
                    case tab of
                        Just tabName ->
                            [ "character", slug, tabName ]

                        Nothing ->
                            [ "character", slug ]

                CreateCharacter ->
                    [ "createCharacter" ]
    in
    "#/" ++ String.join "/" pieces


changeRoute : Maybe Route -> { a | route : Route, selectedCharacterId : String, selectedTab : String } -> ( { a | route : Route, selectedCharacterId : String, selectedTab : String }, Cmd msg )
changeRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( model, log (Encode.string "Not found") )

        Just CharacterSelect ->
            ( { model | route = CharacterSelect }, log (Encode.string "CharacterSelect") )

        Just (CharacterSheet slug tab) ->
            ( { model | route = CharacterSheet slug tab, selectedCharacterId = slug, selectedTab = Maybe.withDefault "" tab }, log (Encode.string ("CharacterSheet - " ++ slug)) )

        Just CreateCharacter ->
            ( { model | route = CreateCharacter }, log (Encode.string "CreateCharacter") )
