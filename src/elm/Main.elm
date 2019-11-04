module Main exposing (main)

import Browser
import Browser.Navigation
import CharacterSheet
import Dict exposing (Dict)
import Html exposing (div, text)
import Modules.Player exposing (Player)
import Url



-- MAIN


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , onUrlRequest = handleUrlRequest
        , onUrlChange = changeUrl
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { page : String
    , player : Player
    }


modelInit =
    { page = "home"
    , player = Player "" Dict.empty
    }


init : String -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( modelInit, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


handleUrlRequest : Browser.UrlRequest -> Msg
handleUrlRequest request =
    NoOp


changeUrl : Url.Url -> Msg
changeUrl url =
    NoOp



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { body = [ div [] [ text "hi" ] ]
    , title = "Hello"
    }
