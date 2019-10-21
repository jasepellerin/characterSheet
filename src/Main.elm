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
    { characterName : String
    , level : Int
    , strength : Int
    , perception : Int
    , endurance : Int
    , charisma : Int
    , intelligence : Int
    , agility : Int
    , luck : Int
    }


modelInit =
    { characterName = "New Character"
    , level = 1
    , strength = 1
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
    | UpdateEndurance String
    | UpdateCharisma String
    | UpdateIntelligence String
    | UpdateAgility String
    | UpdateLuck String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAbilityScore abilityMsg ->
            updateAbilityScore abilityMsg model


updateAbilityScore : UpdateAbilityScoreMsg -> Model -> ( Model, Cmd Msg )
updateAbilityScore abilityMsg model =
    case abilityMsg of
        UpdateStrength value ->
            ( { model | strength = getIntFromInput value }, Cmd.none )

        UpdatePerception value ->
            ( { model | perception = getIntFromInput value }, Cmd.none )

        UpdateEndurance value ->
            ( { model | endurance = getIntFromInput value }, Cmd.none )

        UpdateCharisma value ->
            ( { model | charisma = getIntFromInput value }, Cmd.none )

        UpdateIntelligence value ->
            ( { model | intelligence = getIntFromInput value }, Cmd.none )

        UpdateAgility value ->
            ( { model | agility = getIntFromInput value }, Cmd.none )

        UpdateLuck value ->
            ( { model | luck = getIntFromInput value }, Cmd.none )


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
        [ header [] [ h1 [] [ text model.characterName ], p [] [ text ("Level " ++ String.fromInt model.level) ] ]
        , section []
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
            , label []
                [ text "Endurance"
                , input
                    [ value (String.fromInt model.endurance), onInput (UpdateAbilityScore << UpdateEndurance), type_ "number", maxlength 2 ]
                    []
                ]
            , label []
                [ text "Charisma"
                , input
                    [ value (String.fromInt model.charisma), onInput (UpdateAbilityScore << UpdateCharisma), type_ "number", maxlength 2 ]
                    []
                ]
            , label []
                [ text "Intelligence"
                , input
                    [ value (String.fromInt model.intelligence), onInput (UpdateAbilityScore << UpdateIntelligence), type_ "number", maxlength 2 ]
                    []
                ]
            , label []
                [ text "Agility"
                , input
                    [ value (String.fromInt model.agility), onInput (UpdateAbilityScore << UpdateAgility), type_ "number", maxlength 2 ]
                    []
                ]
            , label []
                [ text "Luck"
                , input
                    [ value (String.fromInt model.luck), onInput (UpdateAbilityScore << UpdateLuck), type_ "number", maxlength 2 ]
                    []
                ]
            ]
        , section [] [ text "Col 2" ]
        , section [] [ text "Col 3" ]
        ]
    , title = "Character Sheet - " ++ model.characterName
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
