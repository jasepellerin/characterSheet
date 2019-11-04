module Pages.CharacterSheet exposing (Msg, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Modules.Player exposing (Player)



-- MODEL


type alias Model =
    { characterId : String
    , player : Player
    }


modelInit =
    { characterId = ""
    , player = Player "" Dict.empty
    }



-- VIEW


view : Model -> { content : Html Msg, title : String }
view { characterId, player } =
    { content =
        case Dict.member characterId player.characters of
            True ->
                div [] [ text characterId ]

            False ->
                div [] [ text "No character with this ID was found" ]
    , title = "Sheet"
    }



-- UPDATE


type Msg
    = NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
