module Pages.CharacterSheet exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api
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
    }


modelInit =
    { selectedCharacterId = ""
    , player = Player "" Dict.empty
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


getChar : Cmd Msg
getChar =
    Api.get (Endpoint.getCharacter "247935186137776658") GotText (Decode.at [ "data", "armorType" ] Decode.string)


type Msg
    = GotText (Result Http.Error String)
    | HandleClick
    | NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HandleClick ->
            ( model, getChar )

        GotText result ->
            ( model, Cmd.none )
