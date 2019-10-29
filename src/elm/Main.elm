module Main exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Events exposing (onKeyDown, onKeyUp)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onDoubleClick, onFocus, onInput, stopPropagationOn)
import Json.Decode as Decode exposing (at, decodeString, field, string)
import Json.Encode as Encode
import List.Extra exposing (find)
import Modules.CharacterData exposing (CharacterData)
import Modules.Skills exposing (Skill, combatSkills)
import Modules.SpecialAttribute exposing (SpecialAttribute, SpecialAttributeMsg(..), getSpecialAttribute, specialAttributeNames)
import Task



-- MAIN


main : Program () HistoryModel HistoryMsg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = updateWithHistory
        , view = view
        }



-- MODEL


type alias Model =
    { characterData : CharacterData
    , editingAttribute : String
    }


type alias HistoryModel =
    { model : Model
    , undoHistory : List Model
    , history : List Model
    , controlDown : Bool
    , shiftDown : Bool
    }


modelInit =
    { characterData =
        { characterName = "New Character"
        , level = 1
        , armorType = "none"
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


historyModelInit =
    { model = modelInit
    , history = []
    , undoHistory = []
    , controlDown = False
    , shiftDown = False
    }


init : () -> ( HistoryModel, Cmd HistoryMsg )
init =
    always ( historyModelInit, Cmd.none )


subscriptions : HistoryModel -> Sub HistoryMsg
subscriptions model =
    Sub.batch [ onKeyDown (updateKey True), onKeyUp (updateKey False) ]



-- UPDATE


type Msg
    = EditAttribute String
    | NoOp
    | StopEditing
    | UpdateArmor String
    | UpdateAttribute SpecialAttributeMsg String


type HistoryMsg
    = HistoryNoOp
    | Redo
    | Undo
    | UpdateKey String Bool
    | UpdateModel Bool Msg


updateWithHistory : HistoryMsg -> HistoryModel -> ( HistoryModel, Cmd HistoryMsg )
updateWithHistory msg historyModel =
    case msg of
        HistoryNoOp ->
            ( historyModel, Cmd.none )

        Redo ->
            case historyModel.undoHistory of
                newModel :: newUndoHistory ->
                    ( { historyModel
                        | model = { modelInit | characterData = newModel.characterData }
                        , history = historyModel.model :: historyModel.history
                        , undoHistory = newUndoHistory
                      }
                    , Cmd.none
                    )

                [] ->
                    ( historyModel, Cmd.none )

        Undo ->
            case historyModel.history of
                newModel :: newHistory ->
                    ( { historyModel
                        | model =
                            { modelInit
                                | characterData = newModel.characterData
                            }
                        , history = newHistory
                        , undoHistory = historyModel.model :: historyModel.undoHistory
                      }
                    , Cmd.none
                    )

                [] ->
                    ( historyModel, Cmd.none )

        UpdateKey key value ->
            case String.toLower key of
                "control" ->
                    ( { historyModel | controlDown = value }, Cmd.none )

                "meta" ->
                    ( { historyModel | controlDown = value }, Cmd.none )

                "shift" ->
                    ( { historyModel | shiftDown = value }, Cmd.none )

                "z" ->
                    if value == False then
                        ( historyModel, Cmd.none )

                    else if historyModel.controlDown && historyModel.shiftDown then
                        updateWithHistory Redo historyModel

                    else if historyModel.controlDown then
                        updateWithHistory Undo historyModel

                    else
                        ( historyModel, Cmd.none )

                _ ->
                    ( historyModel, Cmd.none )

        UpdateModel updateHistory modelMsg ->
            let
                ( model, cmd ) =
                    update modelMsg historyModel.model

                history =
                    if updateHistory then
                        historyModel.model :: historyModel.history

                    else
                        historyModel.history
            in
            ( { historyModel | model = model, history = history, undoHistory = [] }, cmd )


update : Msg -> Model -> ( Model, Cmd HistoryMsg )
update msg model =
    case msg of
        EditAttribute attributeName ->
            ( { model | editingAttribute = attributeName }, Task.attempt (always HistoryNoOp) (Dom.focus attributeName) )

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

        UpdateAttribute abilityMsg value ->
            ( { model | characterData = updateAttributeScore abilityMsg value model.characterData, editingAttribute = "" }, Cmd.none )


updateAttributeScore : SpecialAttributeMsg -> String -> CharacterData -> CharacterData
updateAttributeScore abilityMsg value characterData =
    case abilityMsg of
        Strength ->
            { characterData | strength = getValidAttributeScoreFromInput characterData.strength value }

        Perception ->
            { characterData | perception = getValidAttributeScoreFromInput characterData.perception value }

        Endurance ->
            { characterData | endurance = getValidAttributeScoreFromInput characterData.endurance value }

        Charisma ->
            { characterData | charisma = getValidAttributeScoreFromInput characterData.charisma value }

        Intelligence ->
            { characterData | intelligence = getValidAttributeScoreFromInput characterData.intelligence value }

        Agility ->
            { characterData | agility = getValidAttributeScoreFromInput characterData.agility value }

        Luck ->
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
    clamp 1 10 newValue


type alias Statistic msg =
    { title : Html msg
    , content : Html msg
    , tooltip : String
    }


derivedStatistics : CharacterData -> Bool -> List (Statistic HistoryMsg)
derivedStatistics data encumbered =
    [ { title = text "Hit Points"
      , content = text (String.fromInt (getHitpoints data.level data.endurance) ++ " HP")
      , tooltip = "How tanky you are (" ++ String.fromInt modifiers.hpBase ++ " + (Level * 5) + (Endurance * 20)"
      }
    , { title = text "Armor Class"
      , content = text (String.fromInt (getTotalArmorClass data) ++ " AC")
      , tooltip = "How hard you are to hit (" ++ String.fromInt modifiers.acBase ++ " + Armor Bonus of " ++ String.fromInt (getArmorBonus data)
      }
    , { title = text "Move Cost"
      , content = text (String.fromInt (getMoveCost data) ++ " AP")
      , tooltip = "AP cost to move on tile (" ++ String.fromInt modifiers.moveCostBase ++ " +  Agility modifier - Armor penalties)"
      }
    , { title = text "AP Modifier"
      , content = text (getApModifierText data encumbered ++ " AP")
      , tooltip = "Modifier to AP roll (" ++ String.fromInt modifiers.apBase ++ " +  Agility score - Armor penalties)"
      }
    ]


card : List (Html.Attribute msg) -> { a | content : Html msg, title : Html msg, tooltip : String } -> Html msg
card attributes_ { content, title, tooltip } =
    div (class "card" :: Html.Attributes.title tooltip :: attributes_)
        [ div [ class "card-content" ]
            [ span [ class "card-title" ] [ title ]
            , content
            ]
        ]


getTotalAttributes : CharacterData -> Int
getTotalAttributes characterData =
    List.foldl (\attribute -> \total -> total + (characterData |> (Maybe.withDefault { accessor = .strength, msg = Strength, tooltip = "" } (getSpecialAttribute attribute) |> .accessor))) 0 specialAttributeNames



-- VIEW


view : HistoryModel -> Browser.Document HistoryMsg
view historyModel =
    let
        model =
            historyModel.model

        data =
            model.characterData

        encumbered =
            data.endurance < getArmorEnduranceRequirement data.armorType

        encumberedClasses =
            classList
                [ ( "encumbered", encumbered )
                ]
    in
    { body =
        [ main_ []
            [ header [] [ h1 [] [ text data.characterName ], h1 [] [ text ("Level " ++ String.fromInt data.level) ] ]
            , section [ class "attributes" ]
                (div [ class "text-center" ] [ text ("Skill total: " ++ String.fromInt (getTotalAttributes data)) ]
                    :: List.map
                        (specialAttributeView UpdateModel model)
                        specialAttributeNames
                )
            , section [ class "derivedStatistics" ] (List.map (card [ encumberedClasses ]) (derivedStatistics data encumbered))
            , section [ class "additionalInfo" ]
                [ card [ encumberedClasses ]
                    { title = text "Armor Type"
                    , content =
                        select [ class "browser-default", onInput (UpdateModel True << UpdateArmor) ]
                            (List.map (armorToOption data.armorType) (List.map Tuple.first (getArmorListOrderedByArmorClass armors)))
                    , tooltip = String.join "\n\n" (List.map getReadableArmorData (getArmorListOrderedByArmorClass armors))
                    }
                ]
            , section []
                (List.map (skillView data) combatSkills)
            ]
        ]
    , title = "Character Sheet - " ++ model.characterData.characterName
    }


skillView : CharacterData -> Skill -> Html msg
skillView data skill =
    let
        specialAttribute =
            getSpecialAttribute skill.attribute
    in
    case specialAttribute of
        Just specialAttribute_ ->
            card [] { title = text skill.name, content = text (String.fromInt (specialAttribute_.accessor data)), tooltip = "" }

        Nothing ->
            text "Something broke"


getPreviousStrength : Model -> Int
getPreviousStrength model =
    model.characterData.strength


updateKey : Bool -> Decode.Decoder HistoryMsg
updateKey value =
    let
        getMsg key =
            UpdateKey key value
    in
    Decode.map getMsg (field "key" string)


specialAttributeView : (Bool -> Msg -> HistoryMsg) -> Model -> String -> Html HistoryMsg
specialAttributeView historyMsg model specialAttributeName =
    let
        specialAttribute =
            getSpecialAttribute specialAttributeName

        sharedAttributeView : List (Attribute HistoryMsg) -> Html HistoryMsg -> SpecialAttribute -> Html HistoryMsg
        sharedAttributeView attributeList attributeElement specialAttribute_ =
            card
                (class "attribute"
                    :: tabindex 0
                    :: attributeList
                )
                { title = text (capitalizeFirstLetter specialAttributeName)
                , tooltip = specialAttribute_.tooltip ++ " Modifier is " ++ String.fromInt (specialAttribute_.accessor model.characterData - modifiers.attributeToMod)
                , content = attributeElement
                }
    in
    case specialAttribute of
        Nothing ->
            card [] { content = text "My bad lul", title = text "Something broke", tooltip = "" }

        Just specialAttribute_ ->
            if specialAttributeName == model.editingAttribute then
                sharedAttributeView []
                    (input
                        [ on "blur" (Decode.succeed (historyMsg False StopEditing)), on "change" (changeDecoder (historyMsg True) (UpdateAttribute specialAttribute_.msg)), type_ "number", maxlength 2, id specialAttributeName ]
                        []
                    )
                    specialAttribute_

            else
                sharedAttributeView
                    [ onFocus (historyMsg False (EditAttribute specialAttributeName))
                    , onDoubleClick (historyMsg False (EditAttribute specialAttributeName))
                    ]
                    (h3 [] [ text (String.fromInt (specialAttribute_.accessor model.characterData)) ])
                    specialAttribute_


getReadableArmorData : ( String, Armor ) -> String
getReadableArmorData ( armorName, armor ) =
    String.join " "
        [ capitalizeFirstLetter armorName
        , "|"
        , String.fromInt armor.armorClass
        , "AC | Moves cost"
        , String.fromInt armor.penalty
        , "more AP | Requires"
        , String.fromInt armor.enduranceRequirement
        , "Endurance to wear correctly"
        ]


capitalizeFirstLetter : String -> String
capitalizeFirstLetter string =
    String.toUpper (String.left 1 string) ++ String.dropLeft 1 string


getArmorListOrderedByArmorClass : Dict String Armor -> List ( String, Armor )
getArmorListOrderedByArmorClass armorList =
    List.sortBy (\armorTuple -> .armorClass (Tuple.second armorTuple)) (Dict.toList armorList)


getTotalArmorClass : CharacterData -> Int
getTotalArmorClass data =
    modifiers.acBase + getArmorBonus data


getArmorBonus : CharacterData -> Int
getArmorBonus { armorType, endurance } =
    case maybeArmor armorType of
        Just armor ->
            if endurance < armor.enduranceRequirement then
                Basics.max 0 (armor.armorClass + modifiers.encumberancePenalty)

            else
                Basics.max 0 armor.armorClass

        Nothing ->
            0


getMoveCost : CharacterData -> Int
getMoveCost { agility, armorType, endurance } =
    case maybeArmor armorType of
        Just armor ->
            let
                unencumberedMoveCost =
                    modifiers.moveCostBase - (agility - modifiers.attributeToMod) - armor.penalty
            in
            if endurance < armor.enduranceRequirement then
                Basics.max 4 (unencumberedMoveCost - (2 * modifiers.encumberancePenalty))

            else
                Basics.max 4 unencumberedMoveCost

        Nothing ->
            20


getApModifierText : CharacterData -> Bool -> String
getApModifierText data encumbered =
    let
        apModifier =
            getApModifier data encumbered
    in
    if apModifier > 0 then
        "+ " ++ String.fromInt apModifier

    else
        String.fromInt apModifier


getApModifier : CharacterData -> Bool -> Int
getApModifier data encumbered =
    let
        baseApModifier =
            modifiers.apBase + data.agility
    in
    if encumbered then
        baseApModifier + (4 * modifiers.encumberancePenalty)

    else
        baseApModifier


getArmorEnduranceRequirement : String -> Int
getArmorEnduranceRequirement armorType =
    case maybeArmor armorType of
        Just armor ->
            armor.enduranceRequirement

        Nothing ->
            0


maybeArmor : String -> Maybe Armor
maybeArmor armorType =
    Dict.get armorType armors


getHitpoints : Int -> Int -> Int
getHitpoints level endurance =
    modifiers.hpBase + (endurance * level)


modifiers =
    { apBase = 10
    , attributeToMod = 5
    , hpBase = 10
    , acBase = 12
    , moveCostBase = 3
    , encumberancePenalty = -2
    }


type alias Armor =
    { armorClass : Int
    , enduranceRequirement : Int
    , penalty : Int
    }


armors =
    Dict.fromList
        [ ( "none", Armor 0 0 0 )
        , ( "light", Armor 1 2 -1 )
        , ( "medium", Armor 3 5 -2 )
        , ( "heavy", Armor 5 7 -4 )
        ]


armorToOption : String -> String -> Html HistoryMsg
armorToOption selectedArmor armorName =
    option [ value armorName, selected (armorName == selectedArmor) ] [ text (capitalizeFirstLetter armorName) ]


changeDecoder : (Msg -> HistoryMsg) -> (String -> Msg) -> Decode.Decoder HistoryMsg
changeDecoder historyMsg msg =
    Decode.map (\value -> historyMsg (msg value)) (at [ "target", "value" ] string)
