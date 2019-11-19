module Pages.CharacterSheet.Skills exposing (skillsView)

import Data.Modifiers exposing (modifiers)
import Dict exposing (Dict)
import Html exposing (Html, b, div, h2, input, label, text)
import Html.Attributes exposing (checked, class, for, id, type_)
import Modules.Card exposing (card)
import Modules.Skills exposing (Skill, characterSkillsDecoder, combatSkills, nonCombatSkills)
import Modules.SpecialAttribute exposing (getSpecialAttribute)
import Types.CharacterData exposing (CharacterData)
import Utils.String exposing (capitalizeFirstLetter, getTitleFromSnakeCase)


skillsView : CharacterData -> Html msg
skillsView characterData =
    div []
        [ div [ class "grid-standard" ] (List.map (skillView True characterData) combatSkills)
        , div [ class "grid-standard two-column" ] (List.map (skillView False characterData) nonCombatSkills)
        ]


skillView : Bool -> CharacterData -> Skill -> Html msg
skillView isCombat data skill =
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
        { title = text (getTitleFromSnakeCase skill.name)
        , content =
            div [ class "skill" ]
                [ h2 [] [ text (String.fromInt totalScore) ]
                , b [] [ text (modifierPrefix ++ String.fromInt modifier) ]
                , div [ class "checkbox-wrapper" ]
                    [ input [ type_ "checkbox", checked isTrained, id skill.name ] []
                    , label [ class "checkbox-label", for skill.name ] [ text "Trained" ]
                    ]
                ]
        , tooltip = "Governed by " ++ capitalizeFirstLetter skill.attribute
        }
