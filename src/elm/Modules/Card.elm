module Modules.Card exposing (card)

import Html exposing (Html, div, span)
import Html.Attributes exposing (class)


card : List (Html.Attribute msg) -> { a | content : Html msg, title : Html msg, tooltip : String } -> Html msg
card attributes_ { content, title, tooltip } =
    div (class "card" :: Html.Attributes.title tooltip :: attributes_)
        [ div [ class "card-content" ]
            [ span [ class "card-title" ] [ title ]
            , div [ class "card-body" ] [ content ]
            ]
        ]
