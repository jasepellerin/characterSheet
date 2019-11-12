module Pages.CharacterSelect exposing (Model, Msg, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Http
import Modules.Player exposing (Player)



-- MODEL


type alias Model =
    { player : Player
    , test : String
    }


modelInit =
    { player = Player "" Dict.empty
    , test = ""
    }



-- VIEW


view : Model -> { content : Html Msg, title : String }
view model =
    { content = div [] [ div [] [ text model.test ], div [ onClick HandleClick ] [ text "Click" ] ]
    , title = "Hello"
    }



-- UPDATE


getChar : Cmd Msg
getChar =
    Http.get
        { url = "http://localhost:8888/.netlify/functions/getCharacter/247935186137776658"
        , expect = Http.expectString GotText
        }


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
            case result of
                Ok response ->
                    ( { model | test = response }, Cmd.none )

                Err error ->
                    ( { model | test = "Error" }, Cmd.none )
