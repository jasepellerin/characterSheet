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
view model =
    { content = div [] [ text model.characterId ]
    , title = "Sheet"
    }



-- UPDATE


type Msg
    = NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
