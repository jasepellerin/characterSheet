module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onDoubleClick, onInput, stopPropagationOn)
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
    , editingAttribute : String
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
    , editingAttribute = ""
    }


init : () -> ( Model, Cmd Msg )
init =
    always ( modelInit, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = EditAttribute String
    | NoOp
    | UpdateAbilityScore UpdateAbilityScoreMsg


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
        EditAttribute attributeName ->
            ( { model | editingAttribute = attributeName }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        UpdateAbilityScore abilityMsg ->
            updateAbilityScore abilityMsg model


updateAbilityScore : UpdateAbilityScoreMsg -> Model -> ( Model, Cmd Msg )
updateAbilityScore abilityMsg model =
    case abilityMsg of
        UpdateStrength value ->
            ( { model | strength = getValidAttributeScoreFromInput model.strength value }, Cmd.none )

        UpdatePerception value ->
            ( { model | perception = getValidAttributeScoreFromInput model.perception value }, Cmd.none )

        UpdateEndurance value ->
            ( { model | endurance = getValidAttributeScoreFromInput model.endurance value }, Cmd.none )

        UpdateCharisma value ->
            ( { model | charisma = getValidAttributeScoreFromInput model.charisma value }, Cmd.none )

        UpdateIntelligence value ->
            ( { model | intelligence = getValidAttributeScoreFromInput model.intelligence value }, Cmd.none )

        UpdateAgility value ->
            ( { model | agility = getValidAttributeScoreFromInput model.agility value }, Cmd.none )

        UpdateLuck value ->
            ( { model | luck = getValidAttributeScoreFromInput model.luck value }, Cmd.none )


getIntFromInput : String -> Int
getIntFromInput value =
    case String.toInt value of
        Just int ->
            int

        Nothing ->
            -1


getValidAttributeScoreFromInput : Int -> String -> Int
getValidAttributeScoreFromInput modelValue value =
    let
        newValue =
            getIntFromInput value
    in
    case newValue >= 1 && newValue <= 10 of
        True ->
            newValue

        False ->
            modelValue



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { body =
        [ main_ [ onClick (EditAttribute "") ]
            [ header [] [ h1 [] [ text model.characterName ], h1 [] [ text ("Level " ++ String.fromInt model.level) ] ]
            , section []
                (List.map
                    (attributeView model)
                    attributes
                )
            , section [] [ text "Col 2" ]
            , section [] [ text "Col 3" ]
            ]
        ]
    , title = "Character Sheet - " ++ model.characterName
    }


type alias Attribute a b =
    { accessor : a -> b
    , updateMsg : String -> UpdateAbilityScoreMsg
    }


attributes =
    [ ( "strength", Attribute .strength UpdateStrength )
    , ( "perception", Attribute .perception UpdatePerception )
    , ( "endurance", Attribute .endurance UpdateEndurance )
    , ( "charisma", Attribute .charisma UpdateCharisma )
    , ( "intelligence", Attribute .intelligence UpdateIntelligence )
    , ( "agility", Attribute .agility UpdateAgility )
    , ( "luck", Attribute .luck UpdateLuck )
    ]


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


attributeView : Model -> ( String, Attribute Model Int ) -> Html Msg
attributeView model ( attributeName, attribute ) =
    if attributeName == model.editingAttribute then
        div [ stopPropagationOn "click" (Json.Decode.succeed ( NoOp, True )), class "attribute" ]
            [ h2 [] [ text (capitalizeFirstLetter attributeName) ]
            , input
                [ value (String.fromInt (attribute.accessor model)), onInput (UpdateAbilityScore << attribute.updateMsg), type_ "number", maxlength 2 ]
                []
            ]

    else
        div [ onDoubleClick (EditAttribute attributeName), class "attribute" ]
            [ h2 [] [ text (capitalizeFirstLetter attributeName) ]
            , h2 [] [ text (String.fromInt (attribute.accessor model)) ]
            ]


capitalizeFirstLetter : String -> String
capitalizeFirstLetter string =
    String.toUpper (String.left 1 string) ++ String.dropLeft 1 string
