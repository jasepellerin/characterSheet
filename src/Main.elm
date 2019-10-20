module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Decode exposing (decodeString, int, list)
import List.Extra
import Ports


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Roll =
    List Int


type alias Model =
    { strength : Int
    , perception : Int
    , endurance : Int
    , charisma : Int
    , intelligence : Int
    , agility : Int
    , luck : Int
    }


modelInit =
    { strength = 1
    , perception = 1
    , endurance = 1
    , charisma = 1
    , intelligence = 1
    , agility = 1
    , luck = 1
    }


init : () -> ( Model, Cmd Msg )
init =
    always ( modelInit, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = UpdateAbilityScore UpdateAbilityScoreMsg


type UpdateAbilityScoreMsg
    = UpdateStrength String
    | UpdatePerception String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAbilityScore abilityMsg ->
            updateAbilityScore abilityMsg model


updateAbilityScore : UpdateAbilityScoreMsg -> Model -> ( Model, Cmd Msg )
updateAbilityScore abilityMsg model =
    case abilityMsg of
        UpdateStrength strength ->
            ( { model | strength = getIntFromInput strength }, Cmd.none )

        UpdatePerception perception ->
            ( { model | perception = getIntFromInput perception }, Cmd.none )


getIntFromInput : String -> Int
getIntFromInput value =
    case String.toInt value of
        Just int ->
            int

        Nothing ->
            0



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { body =
        [ div []
            [ label []
                [ text "Strength"
                , input
                    [ value (String.fromInt model.strength), onInput (UpdateAbilityScore << UpdateStrength), type_ "number", maxlength 2 ]
                    []
                ]
            , label []
                [ text "Perception"
                , input
                    [ value (String.fromInt model.perception), onInput (UpdateAbilityScore << UpdatePerception), type_ "number", maxlength 2 ]
                    []
                ]
            ]
        ]
    , title = "Dice Test"
    }


stringifyResult : List Roll -> String
stringifyResult result =
    String.join ", "
        (List.map stringifyRoll result)


stringifyRoll : Roll -> String
stringifyRoll roll_ =
    let
        stringRoll =
            List.map (\value -> String.fromInt value) roll_
    in
    "[" ++ String.join ", " stringRoll ++ "]"
