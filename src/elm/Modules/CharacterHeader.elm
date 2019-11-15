module Modules.CharacterHeader exposing (characterHeader)

import Html exposing (Html, button, div, h1, header, input, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick, onDoubleClick)
import Types.CharacterData exposing (CharacterData)


characterHeader : msg -> msg -> CharacterData -> Html msg
characterHeader saveMessage editMessage characterData =
    header []
        [ div [ class "name-container" ]
            [ nameView characterData.name ]
        , h1 [] [ text ("Level " ++ String.fromInt characterData.level) ]
        , button [ onClick saveMessage ] [ text "Save" ]
        ]


nameView : String -> Html msg
nameView name =
    h1 [] [ text name ]
