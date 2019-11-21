module Pages.CharacterSheet.CharacterHeader exposing (characterHeader)

import Html exposing (Html, button, div, h1, header, input, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Pages.CharacterSheet.Msg exposing (Msg(..))
import Types.CharacterData exposing (CharacterData)


characterHeader : CharacterData -> Html Msg
characterHeader characterData =
    header []
        [ div [ class "name-container" ]
            [ nameView characterData.name ]
        , h1 [] [ text ("Level " ++ String.fromInt characterData.level) ]
        , button [ onClick Edit ] [ text "Edit" ]
        ]


nameView : String -> Html Msg
nameView name =
    h1 [] [ text name ]
