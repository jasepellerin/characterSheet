module Pages.CharacterSheet.CharacterHeader exposing (characterHeader)

import Html exposing (Html, button, div, h1, header, input, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Types.CharacterData exposing (CharacterData)


characterHeader : CharacterData -> Html msg
characterHeader characterData =
    header []
        [ div [ class "name-container" ]
            [ nameView characterData.name ]
        , h1 [] [ text ("Level " ++ String.fromInt characterData.level) ]
        , button [] [ text "Save" ]
        ]


nameView : String -> Html msg
nameView name =
    h1 [] [ text name ]
