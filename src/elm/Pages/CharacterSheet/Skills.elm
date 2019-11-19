module Pages.CharacterSheet.Skills exposing (skills)

import Html exposing (Html, button, div, h1, header, input, text)
import Html.Attributes exposing (class)
import Types.CharacterData exposing (CharacterData)


skills : msg -> msg -> CharacterData -> Html msg
skills saveMessage editMessage characterData =
    header []
        [ div [ class "name-container" ]
            [ nameView characterData.name ]
        , h1 [] [ text ("Level " ++ String.fromInt characterData.level) ]
        , button [ onClick saveMessage ] [ text "Save" ]
        ]
