module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Dom as Dom
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onDoubleClick, onInput, stopPropagationOn)
import Json.Decode as Decode exposing (at, decodeString, string)
import Ports
import Task


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
    , armorType : String
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
        , armorType = "light"
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


type UpdateAttributeMsg
    = UpdateStrength String
    | UpdatePerception String
    | UpdateEndurance String
    | UpdateCharisma String
    | UpdateIntelligence String
    | UpdateAgility String
    | UpdateLuck String


type Msg
    = EditAttribute String
    | NoOp
    | StopEditing
    | UpdateArmor String
    | UpdateAttribute UpdateAttributeMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditAttribute attributeName ->
            ( { model | editingAttribute = attributeName }, Task.attempt (always NoOp) (Dom.focus attributeName) )

        NoOp ->
            ( model, Cmd.none )

        StopEditing ->
            ( { model | editingAttribute = "" }, Cmd.none )

        UpdateArmor newArmor ->
            let
                characterData =
                    model.characterData
            in
            ( { model | characterData = { characterData | armorType = newArmor } }, Cmd.none )

        UpdateAttribute abilityMsg ->
            ( { model | characterData = updateAttributeScore abilityMsg model.characterData, editingAttribute = "" }, Cmd.none )


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
        [ main_ []
            [ header [] [ h1 [] [ text data.characterName ], h1 [] [ text ("Level " ++ String.fromInt data.level) ] ]
            , section [ class "attributes" ]
                (List.map
                    (attributeView model)
                    attributes
                )
            , section [ class "derivedStatistics" ]
                [ div [ class "standout", title (String.fromInt modifiers.hpBase ++ " + (Level * 5) + (Endurance * 20)") ]
                    [ h2 [] [ text "Hit Points" ]
                    , h3 [] [ text (String.fromInt (getHitpoints data.level data.endurance)) ]
                    ]
                , div [ class "standout", title (String.fromInt modifiers.acBase ++ " + Armor Bonus of " ++ String.fromInt (getArmorBonus data.armorType)) ]
                    [ h2 [] [ text "Armor Class" ]
                    , h3 [] [ text (String.fromInt (getArmorClass data.armorType)) ]
                    ]
                ]
            , section [ class "additionalInfo" ]
                [ div [ class "standout" ]
                    [ h2 [] [ text "Armor Type" ]
                    , select [ onInput UpdateArmor ]
                        (List.map (armorToOption data.armorType) getArmorListOrderedByArmorClass)
                    ]
                ]
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
        div [ stopPropagationOn "click" (Decode.succeed ( NoOp, True )), class "standout attribute" ]
            [ h2 [] [ text (capitalizeFirstLetter attributeName) ]
            , input
                [ on "blur" (Decode.succeed StopEditing), on "change" (changeDecoder (UpdateAttribute << attribute.updateMsg)), type_ "number", maxlength 2, id attributeName ]
                []
            ]

    else
        div [ onDoubleClick (EditAttribute attributeName), class "standout attribute" ]
            [ h2 [] [ text (capitalizeFirstLetter attributeName) ]
            , h3 [] [ text (String.fromInt (attribute.accessor model.characterData)) ]
            ]


capitalizeFirstLetter : String -> String
capitalizeFirstLetter string =
    String.toUpper (String.left 1 string) ++ String.dropLeft 1 string


getArmorListOrderedByArmorClass : List String
getArmorListOrderedByArmorClass =
    List.map Tuple.first (List.sortBy (\armorTuple -> .armorClass (Tuple.second armorTuple)) (Dict.toList armors))


getArmorClass : String -> Int
getArmorClass armorType =
    modifiers.acBase + getArmorBonus armorType


getArmorBonus : String -> Int
getArmorBonus armorType =
    let
        maybeArmor =
            Dict.get armorType armors
    in
    case maybeArmor of
        Just armor ->
            armor.armorClass

        Nothing ->
            0


getHitpoints : Int -> Int -> Int
getHitpoints level endurance =
    modifiers.hpBase + modifiers.hpLevelMod * level + modifiers.hpEnduranceMod * endurance


modifiers =
    { hpBase = 95
    , hpEnduranceMod = 20
    , hpLevelMod = 5
    , acBase = 12
    }


type alias Armor =
    { armorClass : Int
    , enduranceRequirement : Int
    , maxMovePenalty : Int
    , moveCostPenalty : Int
    }


armors =
    Dict.fromList
        [ ( "light", Armor 1 2 0 0 )
        , ( "medium", Armor 3 5 0 1 )
        , ( "heavy", Armor 5 7 1 2 )
        ]


armorToOption : String -> String -> Html Msg
armorToOption selectedArmor armorName =
    option [ value armorName, selected (armorName == selectedArmor) ] [ text (capitalizeFirstLetter armorName) ]


changeDecoder : (String -> Msg) -> Decode.Decoder Msg
changeDecoder msg =
    Decode.map (valueToMsg msg) (at [ "target", "value" ] string)


valueToMsg : (String -> Msg) -> String -> Msg
valueToMsg msg value =
    msg value
