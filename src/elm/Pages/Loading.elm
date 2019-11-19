module Pages.Loading exposing (view)

import Html exposing (Html, div, i, span, text)
import Html.Attributes exposing (class)


view : { content : List (Html msg), title : String }
view =
    { content =
        [ div [ class "loader" ] [ i [ class "spinner la la-radiation-alt la-spin" ] [], span [] [ text "Searching rusty filing cabinet..." ] ] ]
    , title = "Loading..."
    }
