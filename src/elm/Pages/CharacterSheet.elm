port module Pages.CharacterSheet exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api
import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Modules.CharacterData exposing (characterDataDecoder, characterDataEncoder)
import Modules.Player exposing (Player)
import Ports exposing (log)
import Types.CharacterData exposing (CharacterData)


port setLocalData : Encode.Value -> Cmd msg



-- MODEL


type alias Model a =
    { a
        | player : Player
        , selectedCharacterId : String
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
                div [] [ text "No character with this ID was found", button [ onClick GetCharacter ] [ text "Check again" ] ]
    , title = "Sheet"
    }



-- UPDATE


getCharacter : Model a -> Cmd Msg
getCharacter { selectedCharacterId, urlBuilder } =
    Api.get (Endpoint.getCharacter urlBuilder selectedCharacterId) GotCharacter (Decode.field "data" (characterDataDecoder ""))


type Msg
    = GetCharacter
    | GotCharacter (Result Http.Error CharacterData)
    | HandleChange CharacterData
    | NoOp


update : Msg -> Model a -> ( Model a, Cmd Msg )
update msg model =
    let
        player =
            model.player
    in
    case msg of
        GetCharacter ->
            ( model, getCharacter model )

        GotCharacter result ->
            case result of
                Ok result_ ->
                    let
                        updatedCharacters =
                            Dict.insert model.selectedCharacterId result_ player.characters
                    in
                    ( { model | player = { player | characters = updatedCharacters } }, log (Encode.dict identity characterDataEncoder updatedCharacters) )

                Err error ->
                    case error of
                        Http.BadBody errorMsg ->
                            ( model, log (Encode.string errorMsg) )

                        _ ->
                            ( model, log (Encode.string "Unknown Error") )

        HandleChange newData ->
            let
                updatedCharacters =
                    Dict.insert model.selectedCharacterId newData model.player.characters
            in
            ( { model | player = { player | characters = updatedCharacters } }, setLocalData (Encode.dict identity characterDataEncoder updatedCharacters) )

        NoOp ->
            ( model, Cmd.none )
