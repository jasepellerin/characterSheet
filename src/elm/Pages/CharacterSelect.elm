module Pages.CharacterSelect exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api
import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Modules.Player exposing (Player)
import Url exposing (Url)



-- MODEL


type alias Model =
    { player : Player
    , selectedCharacterId : String
    }



-- VIEW


view : Model -> { content : Html Msg, title : String }
view model =
    { content = div [] [ div [] [ text model.selectedCharacterId ], div [ onClick HandleClick ] [ text "Click" ] ]
    , title = "Hello"
    }



-- UPDATE


getChar : Cmd Msg
getChar =
    Api.get (Endpoint.getCharacter "247935186137776658") GotText (Decode.at [ "data", "armorType" ] Decode.string)


type Msg
    = NoOp
    | HandleClick
    | GotText (Result Http.Error String)


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HandleClick ->
            ( model, getChar )

        GotText result ->
            ( model, Cmd.none )
