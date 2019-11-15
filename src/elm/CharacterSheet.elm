port module CharacterSheet exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Events exposing (onKeyDown, onKeyUp)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (checked, class, classList, disabled, for, id, maxlength, placeholder, selected, tabindex, title, type_, value)
import Html.Events exposing (on, onCheck, onClick, onDoubleClick, onInput)
import Json.Decode as Decode exposing (at, bool, decodeString, field, int, string)
import Json.Decode.Pipeline exposing (custom, hardcoded, optional, requiredAt)
import Json.Encode as Encode
import List.Extra exposing (find)
import Modules.Skills exposing (Skill, combatSkills, nonCombatSkills)
import Modules.SpecialAttribute exposing (SpecialAttribute, SpecialAttributeMsg(..), getSpecialAttribute, specialAttributeNames)
import Task
import Types.CharacterData exposing (CharacterData)


port setLocalCharacterData : Encode.Value -> Cmd msg


port setDbCharacterData : Encode.Value -> Cmd msg


port createCharacter : Encode.Value -> Cmd msg


port log : Encode.Value -> Cmd msg


port updateDbData : (Encode.Value -> msg) -> Sub msg



-- MAIN


main : Program Decode.Value HistoryModel HistoryMsg
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
    , editing : String
    , currentPlayerId : String
    }


type alias HistoryModel =
    { model : Model
    , undoHistory : List Model
    , history : List Model
    , controlDown : Bool
    , shiftDown : Bool
    , saving : Bool
    , localDbData : CharacterData
    , loading : Bool
    }


modelInit =
    { characterData =
        { name = "Unnamed Wanderer"
        , level = 1
        , armorType = "no armor"
        , strength = 1
        , perception = 1
        , endurance = 1
        , charisma = 1
        , intelligence = 1
        , agility = 1
        , luck = 1
        , skills = Dict.empty
        , playerId = ""
        }
    , currentPlayerId = ""
    , editing = ""
    }


historyModelInit =
    { model = modelInit
    , history = []
    , undoHistory = []
    , controlDown = False
    , shiftDown = False
    , saving = False
    , localDbData = modelInit.characterData
    , loading = False
    }


init : Decode.Value -> ( HistoryModel, Cmd HistoryMsg )
init flags =
    let
        ( decodedDataFromDb, dbResult ) =
            case Decode.decodeValue (characterDataDecoder "dbData") flags of
                Ok decodedData ->
                    ( decodedData, characterDataEncoder decodedData )

                Err err ->
                    ( modelInit.characterData, Encode.string (Decode.errorToString err) )

        currentPlayerId =
            case Decode.decodeValue playerIdDecoder flags of
                Ok currentPlayerId_ ->
                    currentPlayerId_

                Err _ ->
                    ""

        -- TODO: Force logout if we don't have playerId
        ( decodedCharacterData, result ) =
            case Decode.decodeValue (characterDataDecoder "characterData") flags of
                Ok decodedData ->
                    ( decodedData, characterDataEncoder decodedData )

                Err err ->
                    ( modelInit.characterData, Encode.string (Decode.errorToString err) )

        model =
            historyModelInit.model

        characterData =
            historyModelInit.model.characterData

        newModel =
            { historyModelInit | localDbData = decodedDataFromDb, model = { model | characterData = decodedCharacterData, currentPlayerId = currentPlayerId } }

        needsCreation =
            case Decode.decodeValue (field "needsCreation" bool) flags of
                Ok needsCreation_ ->
                    needsCreation_

                Err _ ->
                    False

        canEdit =
            newModel.model.characterData.playerId == currentPlayerId

        ( finalModel, commands ) =
            case needsCreation of
                True ->
                    ( { newModel | loading = True }, createCharacter (characterDataEncoder { characterData | playerId = currentPlayerId }) )

                False ->
                    case canEdit of
                        True ->
                            ( newModel, Cmd.batch [ setLocalCharacterData (characterDataEncoder newModel.model.characterData), log dbResult ] )

                        False ->
                            ( newModel, log dbResult )
    in
    ( finalModel, commands )


subscriptions : HistoryModel -> Sub HistoryMsg
subscriptions model =
    Sub.batch [ onKeyDown (updateKey True), onKeyUp (updateKey False), updateDbData updateLocalDbData ]



-- UPDATE


type Msg
    = EditSection String
    | NoOp
    | SetSkillTrained String Bool
    | StopEditing
    | UpdateArmor String
    | UpdateAttribute SpecialAttributeMsg String
    | UpdateCharacterName String


type HistoryMsg
    = HistoryNoOp
    | HistoryLog String
    | Redo
    | SaveDataToDb
    | Undo
    | UpdateKey String Bool
    | UpdateDbData CharacterData
    | UpdateModel Bool Msg


updateWithHistory : HistoryMsg -> HistoryModel -> ( HistoryModel, Cmd HistoryMsg )
updateWithHistory msg historyModel =
    case msg of
        HistoryNoOp ->
            ( historyModel, Cmd.none )

        HistoryLog message ->
            ( historyModel, log (Encode.string message) )

        Redo ->
            case historyModel.undoHistory of
                newModel :: newUndoHistory ->
                    ( { historyModel
                        | model = { newModel | editing = "" }
                        , history = historyModel.model :: historyModel.history
                        , undoHistory = newUndoHistory
                      }
                    , Cmd.none
                    )

                [] ->
                    ( historyModel, Cmd.none )

        SaveDataToDb ->
            ( { historyModel | saving = True }, setDbCharacterData (characterDataEncoder historyModel.model.characterData) )

        Undo ->
            case historyModel.history of
                newModel :: newHistory ->
                    ( { historyModel
                        | model =
                            { newModel
                                | editing = ""
                            }
                        , history = newHistory
                        , undoHistory = historyModel.model :: historyModel.undoHistory
                      }
                    , Cmd.none
                    )

                [] ->
                    ( historyModel, Cmd.none )

        UpdateKey key value ->
            case key of
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

        UpdateDbData data ->
            ( { historyModel | localDbData = data, saving = False }, Cmd.none )

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
    let
        characterData =
            model.characterData

        updateLocalStorage =
            \newModel -> setLocalCharacterData (characterDataEncoder newModel)
    in
    case msg of
        EditSection sectionName ->
            ( { model | editing = sectionName }, Task.attempt (always HistoryNoOp) (Dom.focus sectionName) )

        NoOp ->
            ( model, Cmd.none )

        SetSkillTrained skillName value ->
            let
                newSkillDict =
                    case value of
                        True ->
                            Dict.insert skillName value model.characterData.skills

                        False ->
                            Dict.remove skillName model.characterData.skills

                newModel =
                    { model | characterData = { characterData | skills = newSkillDict } }
            in
            ( newModel, updateLocalStorage newModel.characterData )

        StopEditing ->
            ( { model | editing = "" }, Cmd.none )

        UpdateArmor newArmor ->
            let
                newModel =
                    { model | characterData = { characterData | armorType = newArmor } }
            in
            ( newModel, updateLocalStorage newModel.characterData )

        UpdateAttribute abilityMsg value ->
            let
                newModel =
                    { model | characterData = updateAttributeScore abilityMsg value model.characterData, editing = "" }
            in
            ( newModel, updateLocalStorage newModel.characterData )

        UpdateCharacterName value ->
            let
                newModel =
                    { model | characterData = { characterData | name = value }, editing = "" }
            in
            ( newModel, updateLocalStorage newModel.characterData )


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

        AttributeNoOp ->
            characterData


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


getTotalAttributes : CharacterData -> Int
getTotalAttributes characterData =
    List.foldl (\attribute -> \total -> total + (characterData |> (Maybe.withDefault { accessor = .strength, msg = Strength, tooltip = "" } (getSpecialAttribute attribute) |> .accessor))) 0 specialAttributeNames


sheetSection : { className : String, title : String } -> List (Html msg) -> Html msg
sheetSection { className, title } content =
    section [ class "sheetSection", class className ]
        (h2 [] [ text title ]
            :: content
        )



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

        skillTotalClasses =
            case getTotalAttributes data > modifiers.maximumAttributes of
                True ->
                    "invalid"

                False ->
                    ""

        canEdit =
            model.currentPlayerId == data.playerId

        hasUnsavedChanges =
            historyModel.localDbData /= model.characterData

        saveMessage =
            case canEdit of
                True ->
                    SaveDataToDb

                False ->
                    HistoryNoOp
    in
    { body =
        case historyModel.loading of
            True ->
                [ div [ class "loader" ] [ i [ class "spinner la la-radiation-alt la-spin" ] [], span [] [ text "Initializing character sheet..." ] ] ]

            False ->
                [ sheetSection { title = "Special", className = "attributes" }
                    (List.append
                        (List.map
                            (specialAttributeView canEdit UpdateModel model)
                            specialAttributeNames
                        )
                        [ div [ class "text-center", class skillTotalClasses ] [ text ("Skill total: " ++ String.fromInt (getTotalAttributes data)) ] ]
                    )
                , sheetSection { title = "Gear", className = "additionalInfo" }
                    [ card [ encumberedClasses ]
                        { title = text "Armor Type"
                        , content =
                            armorSelectView canEdit (UpdateModel True << UpdateArmor) data.armorType
                        , tooltip = String.join "\n\n" (List.map getReadableArmorData (getArmorListOrderedByArmorClass armors))
                        }
                    ]
                , sheetSection { title = "Skills", className = "skills" }
                    [ div [ class "grid-standard" ] (List.map (skillView canEdit True data) combatSkills)
                    , div [ class "grid-standard two-column" ] (List.map (skillView canEdit False data) nonCombatSkills)
                    ]
                ]
    , title = "Character Sheet - " ++ model.characterData.name
    }


getCanEditMessage : Bool -> HistoryMsg -> HistoryMsg
getCanEditMessage canEdit editMessage =
    case canEdit of
        True ->
            editMessage

        False ->
            HistoryNoOp


armorSelectView : Bool -> (String -> HistoryMsg) -> String -> Html HistoryMsg
armorSelectView canEdit historyMsg armorType =
    case canEdit of
        True ->
            select
                [ onInput historyMsg ]
                (List.map (armorToOption armorType) (List.map Tuple.first (getArmorListOrderedByArmorClass armors)))

        False ->
            h3 [] [ text (capitalizeFirstLetter armorType) ]


nameView : Model -> Html HistoryMsg
nameView model =
    case model.editing == "name" of
        True ->
            editableInput [ id "name", type_ "text", placeholder model.characterData.name ] UpdateModel UpdateCharacterName

        False ->
            h1 [] [ text model.characterData.name ]


skillView : Bool -> Bool -> CharacterData -> Skill -> Html HistoryMsg
skillView canEdit isCombat data skill =
    let
        specialAttribute =
            Maybe.map (\attribute -> attribute.accessor data) (getSpecialAttribute skill.attribute)

        isTrained =
            Maybe.withDefault False (Dict.get skill.name data.skills)

        additionalScore =
            case isTrained of
                True ->
                    15

                False ->
                    0

        totalScore =
            Maybe.withDefault -1
                (Maybe.map (\specialAttribute_ -> additionalScore + (2 * specialAttribute_) + ((data.luck + 1) // 2)) specialAttribute)

        modifier =
            let
                trainedModifier =
                    case isCombat && not isTrained of
                        True ->
                            modifiers.untrainedCombat

                        False ->
                            0
            in
            (totalScore // 10) + trainedModifier

        modifierPrefix =
            case modifier >= 0 of
                True ->
                    "+"

                False ->
                    ""
    in
    card []
        { title = text (getPrettyName skill.name)
        , content =
            div [ class "skill" ]
                [ h2 [] [ text (String.fromInt totalScore) ]
                , b [] [ text (modifierPrefix ++ String.fromInt modifier) ]
                , div [ class "checkbox-wrapper" ]
                    [ input [ type_ "checkbox", checked isTrained, onCheck (\checked -> getCanEditMessage canEdit ((UpdateModel True << SetSkillTrained skill.name) checked)), id skill.name ] []
                    , label [ class "checkbox-label", classList [ ( "pointer", canEdit ) ], for skill.name ] [ text "Trained" ]
                    ]
                ]
        , tooltip = "Governed by " ++ capitalizeFirstLetter skill.attribute
        }


getPrettyName : String -> String
getPrettyName name =
    String.split "_" name |> List.map capitalizeFirstLetter |> String.join " "


updateKey : Bool -> Decode.Decoder HistoryMsg
updateKey value =
    let
        validKeys =
            [ "control", "meta", "shift", "z" ]

        getMsg key =
            let
                lowercaseKey =
                    String.toLower key
            in
            case List.member lowercaseKey validKeys of
                True ->
                    UpdateKey lowercaseKey value

                False ->
                    HistoryLog lowercaseKey
    in
    Decode.map getMsg (field "key" string)


updateLocalDbData : Encode.Value -> HistoryMsg
updateLocalDbData encodedData =
    let
        decodedData =
            Decode.decodeValue (characterDataDecoder "") encodedData
    in
    case decodedData of
        Ok data_ ->
            UpdateDbData data_

        Err _ ->
            HistoryNoOp


getReadableArmorData : ( String, Armor ) -> String
getReadableArmorData ( armorName, armor ) =
    String.join " "
        [ capitalizeFirstLetter armorName
        , "|"
        , String.fromInt armor.armorClass
        , "AC | Moves cost"
        , String.fromInt armor.moveCostPenalty
        , "more AP | Dodge "
        , String.fromFloat armor.dodgeMultiplier
        , "* Agility mod AC | Requires"
        , String.fromInt armor.enduranceRequirement
        , "Endurance"
        ]


getArmorListOrderedByArmorClass : Dict String Armor -> List ( String, Armor )
getArmorListOrderedByArmorClass armorList =
    List.sortBy (\armorTuple -> .armorClass (Tuple.second armorTuple)) (Dict.toList armorList)


armorToOption : String -> String -> Html HistoryMsg
armorToOption selectedArmor armorName =
    option [ value armorName, selected (armorName == selectedArmor) ] [ text (capitalizeFirstLetter armorName) ]
