module Modules.SpecialAttribute exposing (SpecialAttribute, SpecialAttributeMsg(..), getAttributeModifier, getAttributeValueFromNameWithDefault, getSpecialAttribute, specialAttributeNames, specialAttributeView)

import Data.Modifiers exposing (modifiers)
import Dict exposing (Dict)
import Html exposing (Html, h3, input, text)
import Html.Attributes exposing (class, classList, id, maxlength, placeholder, type_)
import Modules.Card exposing (card)
import Types.CharacterData exposing (CharacterData)
import Utils.String exposing (capitalizeFirstLetter)


type SpecialAttributeMsg
    = Strength
    | Perception
    | Endurance
    | Charisma
    | Intelligence
    | Agility
    | Luck
    | AttributeNoOp


type alias SpecialAttribute =
    { accessor : CharacterData -> Int
    , msg : SpecialAttributeMsg
    , tooltip : String
    }


specialAttributeNames : List String
specialAttributeNames =
    [ "strength"
    , "perception"
    , "endurance"
    , "charisma"
    , "intelligence"
    , "agility"
    , "luck"
    ]


specialAttributes : Dict String SpecialAttribute
specialAttributes =
    Dict.fromList
        [ ( "strength", { msg = Strength, accessor = .strength, tooltip = "💪" } )
        , ( "perception", { msg = Perception, accessor = .perception, tooltip = "🕵" } )
        , ( "endurance", { msg = Endurance, accessor = .endurance, tooltip = "\u{1F98D}" } )
        , ( "charisma", { msg = Charisma, accessor = .charisma, tooltip = "🗣" } )
        , ( "intelligence", { msg = Intelligence, accessor = .intelligence, tooltip = "\u{1F9E0}" } )
        , ( "agility", { msg = Agility, accessor = .agility, tooltip = "🏃" } )
        , ( "luck", { msg = Luck, accessor = .luck, tooltip = "🍀" } )
        ]


getSpecialAttribute : String -> Maybe SpecialAttribute
getSpecialAttribute string =
    Dict.get string specialAttributes


getAttributeValueFromNameWithDefault : Int -> CharacterData -> String -> Int
getAttributeValueFromNameWithDefault default characterData attributeName =
    Maybe.withDefault default (Maybe.map (\attribute -> .accessor attribute characterData) (getSpecialAttribute attributeName))


getAttributeModifier : Int -> Int
getAttributeModifier attributeScore =
    attributeScore - modifiers.attributeToMod


specialAttributeView : Bool -> CharacterData -> String -> Html msg
specialAttributeView editing characterData specialAttributeName =
    let
        specialAttribute =
            getSpecialAttribute specialAttributeName

        ( specialAttributeValue, specialAttributeTooltip, specialAttributeMsg ) =
            case specialAttribute of
                Just specialAttribute_ ->
                    ( specialAttribute_.accessor characterData, specialAttribute_.tooltip, specialAttribute_.msg )

                Nothing ->
                    ( -1, "", AttributeNoOp )

        modifier =
            getAttributeModifier specialAttributeValue

        modifierPrefix =
            case modifier >= 0 of
                True ->
                    "+"

                False ->
                    ""

        sharedAttributeView : List (Html.Attribute msg) -> Html msg -> Html msg
        sharedAttributeView attributeList attributeElement =
            card
                (List.append
                    [ class "attribute" ]
                    attributeList
                )
                { title = text (capitalizeFirstLetter specialAttributeName)
                , tooltip = specialAttributeTooltip ++ " Modifier is " ++ modifierPrefix ++ String.fromInt modifier
                , content = attributeElement
                }
    in
    if editing then
        sharedAttributeView []
            (input [ id specialAttributeName, type_ "number", maxlength 2, placeholder (String.fromInt specialAttributeValue) ] [])

    else
        sharedAttributeView
            []
            (h3 [] [ text (String.fromInt specialAttributeValue) ])
