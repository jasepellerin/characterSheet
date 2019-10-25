module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Dom as Dom
import Browser.Events exposing (onKeyDown, onKeyUp)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onDoubleClick, onInput, stopPropagationOn)
import Json.Decode as Decode exposing (at, decodeString, field, string)
import Json.Encode as Encode
import Task


main : Program () HistoryModel HistoryMsg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = updateWithHistory
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
    clamp 1 10 newValue



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
                [ ( "standout", True )
                , ( "encumbered", encumbered )
                ]
    in
    { body =
        [ main_ []
            [ header [] [ h1 [] [ text data.characterName ], h1 [] [ text ("Level " ++ String.fromInt data.level) ] ]
            , section [ class "attributes" ]
                (List.map
                    (attributeView UpdateModel model)
                    attributes
                )
            , section [ class "derivedStatistics" ]
                [ div [ class "standout", title ("How tanky you are (" ++ String.fromInt modifiers.hpBase ++ " + (Level * 5) + (Endurance * 20)") ]
                    [ h2 [] [ text "Hit Points" ]
                    , h3 [] [ text (String.fromInt (getHitpoints data.level data.endurance) ++ " HP") ]
                    ]
                , div [ encumberedClasses, title ("How hard you are to hit (" ++ String.fromInt modifiers.acBase ++ " + Armor Bonus of " ++ String.fromInt (getArmorBonus data)) ]
                    [ h2 [] [ text "Armor Class" ]
                    , h3 [] [ text (String.fromInt (getTotalArmorClass data) ++ " AC") ]
                    ]
                , div [ encumberedClasses, title ("AP cost to move on tile (" ++ String.fromInt modifiers.moveCostBase ++ " +  Agility modifier - Armor penalties)") ]
                    [ h2 [] [ text "Move Cost" ]
                    , h3 [] [ text (String.fromInt (getMoveCost data) ++ " AP") ]
                    ]
                , div [ encumberedClasses, title ("How far you can move per turn (" ++ String.fromInt modifiers.maxMovesBase ++ " +  Agility modifier - Armor penalties)") ]
                    [ h2 [] [ text "Speed" ]
                    , h3 [] [ text (String.fromInt (getMaxMoves data) ++ " Tiles") ]
                    ]
                , div [ encumberedClasses, title ("Modifier to AP roll (" ++ String.fromInt modifiers.apBase ++ " +  Agility score - Armor penalties)") ]
                    [ h2 [] [ text "AP Modifier" ]
                    , h3 [] [ text (getApModifierText data encumbered ++ " AP") ]
                    ]
                ]
            , section [ class "additionalInfo" ]
                [ div [ encumberedClasses, title (String.join "\n\n" (List.map getReadableArmorData (getArmorListOrderedByArmorClass armors))) ]
                    [ h2 [] [ text "Armor Type" ]
                    , select [ onInput (UpdateModel True << UpdateArmor) ]
                        (List.map (armorToOption data.armorType) (List.map Tuple.first (getArmorListOrderedByArmorClass armors)))
                    ]
                ]
            ]
        ]
    , title = "Character Sheet - " ++ model.characterData.characterName
    }


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


type alias CharacterAttribute a b =
    { accessor : a -> b
    , updateMsg : String -> UpdateAttributeMsg
    }


attributes =
    [ { attributeName = "strength", attribute = CharacterAttribute .strength UpdateStrength, specificTitle = "💪" }
    , { attributeName = "perception", attribute = CharacterAttribute .perception UpdatePerception, specificTitle = "🕵" }
    , { attributeName = "endurance", attribute = CharacterAttribute .endurance UpdateEndurance, specificTitle = "\u{1F98D}" }
    , { attributeName = "charisma", attribute = CharacterAttribute .charisma UpdateCharisma, specificTitle = "🗣" }
    , { attributeName = "intelligence", attribute = CharacterAttribute .intelligence UpdateIntelligence, specificTitle = "\u{1F9E0}" }
    , { attributeName = "agility", attribute = CharacterAttribute .agility UpdateAgility, specificTitle = "🏃" }
    , { attributeName = "luck", attribute = CharacterAttribute .luck UpdateLuck, specificTitle = "🍀" }
    ]


attributeView : (Bool -> Msg -> HistoryMsg) -> Model -> { attributeName : String, attribute : CharacterAttribute CharacterData Int, specificTitle : String } -> Html HistoryMsg
attributeView historyMsg model { attributeName, attribute, specificTitle } =
    let
        createAttributeView : Attribute HistoryMsg -> Html HistoryMsg -> Html HistoryMsg
        createAttributeView clickHandler attributeElement =
            div
                [ class "standout attribute"
                , clickHandler
                , title (specificTitle ++ " Modifier is " ++ String.fromInt (attribute.accessor model.characterData - modifiers.attributeToMod))
                ]
                [ h2 [] [ text (capitalizeFirstLetter attributeName) ]
                , attributeElement
                ]
    in
    if attributeName == model.editingAttribute then
        createAttributeView (stopPropagationOn "click" (Decode.succeed ( HistoryNoOp, True )))
            (input
                [ on "blur" (Decode.succeed (historyMsg False StopEditing)), on "change" (changeDecoder (historyMsg True << UpdateAttribute << attribute.updateMsg)), type_ "number", maxlength 2, id attributeName ]
                []
            )

    else
        createAttributeView (onDoubleClick (historyMsg False (EditAttribute attributeName))) (h3 [] [ text (String.fromInt (attribute.accessor model.characterData)) ])


getReadableArmorData : ( String, Armor ) -> String
getReadableArmorData ( armorName, armor ) =
    String.join " "
        [ capitalizeFirstLetter armorName
        , "|"
        , String.fromInt armor.armorClass
        , "AC |"
        , String.fromInt armor.penalty
        , "speed | Moves cost"
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
                Basics.max 0 (unencumberedMoveCost - 2 * modifiers.encumberancePenalty)

            else
                Basics.max 0 unencumberedMoveCost

        Nothing ->
            0


getMaxMoves : CharacterData -> Int
getMaxMoves { agility, armorType, endurance } =
    case maybeArmor armorType of
        Just armor ->
            let
                unencumberedMaxMoves =
                    modifiers.maxMovesBase + (agility - modifiers.attributeToMod) + armor.penalty
            in
            if endurance < armor.enduranceRequirement then
                Basics.max 0 (unencumberedMaxMoves + modifiers.encumberancePenalty)

            else
                Basics.max 0 unencumberedMaxMoves

        Nothing ->
            0


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
    modifiers.hpBase + modifiers.hpLevelMod * level + modifiers.hpEnduranceMod * endurance


modifiers =
    { apBase = 10
    , attributeToMod = 5
    , hpBase = 95
    , hpEnduranceMod = 20
    , hpLevelMod = 5
    , acBase = 12
    , moveCostBase = 3
    , maxMovesBase = 5
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
        , ( "heavy", Armor 5 7 -3 )
        ]


armorToOption : String -> String -> Html HistoryMsg
armorToOption selectedArmor armorName =
    option [ value armorName, selected (armorName == selectedArmor) ] [ text (capitalizeFirstLetter armorName) ]


changeDecoder : (String -> HistoryMsg) -> Decode.Decoder HistoryMsg
changeDecoder msg =
    Decode.map (valueToMsg msg) (at [ "target", "value" ] string)


valueToMsg : (String -> HistoryMsg) -> String -> HistoryMsg
valueToMsg msg value =
    msg value
