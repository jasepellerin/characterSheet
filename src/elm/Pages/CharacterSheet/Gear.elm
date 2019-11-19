module Pages.CharacterSheet.Gear exposing (gearView)

import Html exposing (Html, h3, option, select, text)
import Html.Attributes exposing (classList, selected, value)
import Modules.Armor exposing (Armor, armors, getArmorListOrderedByArmorClass)
import Modules.Card exposing (card)
import Types.CharacterData exposing (CharacterData)
import Utils.String exposing (capitalizeFirstLetter)


gearView : List ( String, Bool ) -> CharacterData -> Html msg
gearView encumberedClasses characterData =
    card [ classList encumberedClasses ]
        { title = text "Armor"
        , content =
            armorSelectView True characterData.armorType
        , tooltip = String.join "\n\n" (List.map getReadableArmorData (getArmorListOrderedByArmorClass armors))
        }


armorSelectView : Bool -> String -> Html msg
armorSelectView canEdit armorType =
    case canEdit of
        True ->
            select
                []
                (List.map (armorToOption armorType) (List.map Tuple.first (getArmorListOrderedByArmorClass armors)))

        False ->
            h3 [] [ text (capitalizeFirstLetter armorType) ]


armorToOption : String -> String -> Html msg
armorToOption selectedArmor armorName =
    option [ value armorName, selected (armorName == selectedArmor) ] [ text (capitalizeFirstLetter armorName) ]


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
