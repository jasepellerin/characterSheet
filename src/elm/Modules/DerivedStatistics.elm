module Modules.DerivedStatistics exposing (derivedStatistics)

import Data.Modifiers exposing (modifiers)
import Html exposing (Html, h2, h3, text)
import Modules.Armor exposing (getMaybeArmor)
import Modules.SpecialAttribute exposing (getAttributeModifier)
import Types.CharacterData exposing (CharacterData)


type alias Statistic msg =
    { title : Html msg
    , content : Html msg
    , tooltip : String
    }


getHitpoints : Int -> Int -> Int
getHitpoints level endurance =
    modifiers.hpBase + (endurance * level)


getTotalArmorClass : CharacterData -> Int
getTotalArmorClass data =
    modifiers.acBase + getArmorBonus data


getArmorBonus : CharacterData -> Int
getArmorBonus { agility, armorType, endurance } =
    case getMaybeArmor armorType of
        Just armor ->
            let
                dodgeBonus =
                    floor (toFloat (getAttributeModifier agility) * armor.dodgeMultiplier)

                armorClass =
                    armor.armorClass + dodgeBonus
            in
            if endurance < armor.enduranceRequirement then
                Basics.max 0 (armorClass + modifiers.encumberancePenalty)

            else
                Basics.max 0 armorClass

        Nothing ->
            0


getMoveCost : CharacterData -> Int
getMoveCost { agility, armorType, endurance } =
    case getMaybeArmor armorType of
        Just armor ->
            let
                unencumberedMoveCost =
                    modifiers.moveCostBase - armor.moveCostPenalty
            in
            if endurance < armor.enduranceRequirement then
                Basics.max modifiers.moveCostBase (unencumberedMoveCost - (2 * modifiers.encumberancePenalty))

            else
                Basics.max modifiers.moveCostBase unencumberedMoveCost

        Nothing ->
            20


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


getApModifierText : CharacterData -> Bool -> String
getApModifierText data encumbered =
    let
        apModifier =
            getApModifier data encumbered
    in
    if apModifier > 0 then
        "+" ++ String.fromInt apModifier

    else
        String.fromInt apModifier


getCriticalHitRoll : Int -> Int
getCriticalHitRoll luck =
    if luck >= 10 then
        18

    else if luck >= 6 then
        19

    else
        20


derivedStatistics : CharacterData -> Bool -> List (Statistic msg)
derivedStatistics data encumbered =
    [ { title = text "Max Hit Points"
      , content = h3 [] [ text (String.fromInt (getHitpoints data.level data.endurance) ++ " HP") ]
      , tooltip = "How tanky you are (" ++ String.fromInt modifiers.hpBase ++ " + (Level * 5) + (Endurance * 20)"
      }
    , { title = text "Armor Class"
      , content = h3 [] [ text (String.fromInt (getTotalArmorClass data) ++ " AC") ]
      , tooltip = "How hard you are to hit (" ++ String.fromInt modifiers.acBase ++ " + Armor Bonus of " ++ String.fromInt (getArmorBonus data)
      }
    , { title = text "Move Cost"
      , content = h3 [] [ text (String.fromInt (getMoveCost data) ++ " AP") ]
      , tooltip = "AP cost to move one tile (" ++ String.fromInt modifiers.moveCostBase ++ " - Armor penalties)"
      }
    , { title = text "AP Modifier"
      , content = h3 [] [ text (getApModifierText data encumbered ++ " AP") ]
      , tooltip = "Modifier to AP roll (" ++ String.fromInt modifiers.apBase ++ " +  Agility score - Armor penalties)"
      }
    , { title = text "Boons"
      , content = h2 [] [ text (String.fromInt (ceiling (toFloat data.luck / 2))) ]
      , tooltip = "Spend one of these to gain advantage on any roll, add 1d6 to damage, gain 10 AP, or just to tip the scales in your favor."
      }
    , { title = text "Critical Hit Roll"
      , content = h2 [] [ text (String.fromInt (getCriticalHitRoll data.luck)) ]
      , tooltip = "If you roll this number or higher, you score a critical hit"
      }
    ]
