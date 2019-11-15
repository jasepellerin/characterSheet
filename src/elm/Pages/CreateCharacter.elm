port module Pages.CreateCharacter exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api exposing (createCharacter)
import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Modules.CharacterData exposing (characterDataEncoder)
import Modules.Player exposing (Player)
import Ports exposing (log)
import Route exposing (Route(..), changeRoute)
import Types.CharacterData exposing (CharacterData)


port setLocalData : Encode.Value -> Cmd msg



-- MODEL


type alias Model a =
    { a
        | player : Player
        , route : Route
        , selectedCharacterId : String
        , urlBuilder : UrlBuilder
    }



-- VIEW


view : Model a -> { content : List (Html Msg), title : String }
view { player } =
    { content =
        [ text "Creating Character" ]
    , title = "New Character"
    }



-- UPDATE


type Msg
    = CreateCharacter
    | GotCharacter (Result Http.Error ( String, CharacterData ))
    | NoOp


update : Msg -> Model a -> ( Model a, Cmd Msg )
update msg model =
    case msg of
        CreateCharacter ->
            ( model, createCharacter GotCharacter model )

        GotCharacter result ->
            let
                player =
                    model.player
            in
            case result of
                Ok ( selectedCharacterId, characterData ) ->
                    let
                        updatedCharacters =
                            Dict.insert model.selectedCharacterId characterData player.characters
                    in
                    ( { model | player = { player | characters = updatedCharacters } }, log (Encode.dict identity characterDataEncoder updatedCharacters) )

                Err error ->
                    case error of
                        Http.BadBody errorMsg ->
                            ( model, log (Encode.string errorMsg) )

                        _ ->
                            ( model, log (Encode.string "Unknown Error") )

        NoOp ->
            ( model, Cmd.none )
