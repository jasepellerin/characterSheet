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


type alias CharacterData =
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


type alias Model =
    { characterData : CharacterData
    , editingAttribute : String
    }


modelInit =
    { characterData =
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
    | StopEditing
    | UpdateAttribute UpdateAttributeMsg


type UpdateAttributeMsg
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

        StopEditing ->
            ( { model | editingAttribute = "" }, Cmd.none )

        UpdateAttribute abilityMsg ->
            ( { model | characterData = updateAttributeScore abilityMsg model.characterData }, Cmd.none )


updateAttributeScore : UpdateAttributeMsg -> CharacterData -> CharacterData
updateAttributeScore abilityMsg characterData =
    case abilityMsg of
        UpdateStrength value ->
            { characterData | strength = getValidAttributeScoreFromInput characterData.strength value }

        UpdatePerception value ->
            { characterData | perception = getValidAttributeScoreFromInput characterData.perception value }

        UpdateEndurance value ->
            { characterData | endurance = getValidAttributeScoreFromInput characterData.endurance value }

        UpdateCharisma value ->
            { characterData | charisma = getValidAttributeScoreFromInput characterData.charisma value }

        UpdateIntelligence value ->
            { characterData | intelligence = getValidAttributeScoreFromInput characterData.intelligence value }

        UpdateAgility value ->
            { characterData | agility = getValidAttributeScoreFromInput characterData.agility value }

        UpdateLuck value ->
            { characterData | luck = getValidAttributeScoreFromInput characterData.luck value }


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
    let
        data =
            model.characterData
    in
    { body =
        [ main_ [ onClick StopEditing ]
            [ header [] [ h1 [] [ text data.characterName ], h1 [] [ text ("Level " ++ String.fromInt data.level) ] ]
            , section [ class "attributes" ]
                (List.map
                    (attributeView model)
                    attributes
                )
            , section [ class "derivedStatistics" ] [ div [ class "section" ] [ h2 [] [ text "Hit Points" ], h3 [] [ text (String.fromInt (getHitpoints data.level data.endurance)) ] ] ]
            , section [] [ text "Col 3" ]
            ]
        ]
    , title = "Character Sheet - " ++ model.characterData.characterName
    }


type alias Attribute a b =
    { accessor : a -> b
    , updateMsg : String -> UpdateAttributeMsg
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


attributeView : Model -> ( String, Attribute CharacterData Int ) -> Html Msg
attributeView model ( attributeName, attribute ) =
    if attributeName == model.editingAttribute then
        div [ stopPropagationOn "click" (Json.Decode.succeed ( NoOp, True )), class "section attribute" ]
            [ h2 [] [ text (capitalizeFirstLetter attributeName) ]
            , input
                [ value (String.fromInt (attribute.accessor model.characterData)), onInput (UpdateAttribute << attribute.updateMsg), type_ "number", maxlength 2 ]
                []
            ]

    else
        div [ onDoubleClick (EditAttribute attributeName), class "section attribute" ]
            [ h2 [] [ text (capitalizeFirstLetter attributeName) ]
            , h2 [] [ text (String.fromInt (attribute.accessor model.characterData)) ]
            ]


capitalizeFirstLetter : String -> String
capitalizeFirstLetter string =
    String.toUpper (String.left 1 string) ++ String.dropLeft 1 string
