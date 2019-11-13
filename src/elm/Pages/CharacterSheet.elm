module Pages.CharacterSheet exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api
import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Http
import Json.Decode as Decode
import Modules.Player exposing (Player)



-- MODEL


type alias Model a =
    { a
        | selectedCharacterId : String
        , player : Player
        , urlBuilder : UrlBuilder
    }



-- VIEW


view : Model a -> { content : Html Msg, title : String }
view { selectedCharacterId, player } =
    { content =
        case Dict.member selectedCharacterId player.characters of
            True ->
                div [] [ text selectedCharacterId ]

            False ->
                div [] [ text "No character with this ID was found" ]
    , title = "Sheet"
    }



-- UPDATE


getChar : UrlBuilder -> Cmd Msg
getChar urlBuilder =
    Api.get (Endpoint.getCharacter urlBuilder "247935186137776658") GotText (Decode.at [ "data", "armorType" ] Decode.string)


type Msg
    = GotText (Result Http.Error String)
    | HandleClick UrlBuilder
    | NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HandleClick urlBuilder ->
            ( model, getChar urlBuilder )

        GotText result ->
            ( model, Cmd.none )
