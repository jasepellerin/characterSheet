module Pages.CharacterSelect exposing (Model, Msg, update, view)

import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, div, h1, text)
import Html.Attributes exposing (href)
import Http
import Json.Encode as Encode
import Modules.CharacterData exposing (characterDataEncoder)
import Modules.Player exposing (Player)
import Ports exposing (log)
import Route exposing (Route(..))
import Types.CharacterData exposing (CharacterData)
import Url exposing (Url)



-- MODEL


type alias Model a =
    { a
        | player : Player
        , selectedCharacterId : String
        , urlBuilder : UrlBuilder
    }



-- VIEW


view : Model a -> { content : List (Html Msg), title : String }
view { player } =
    { content =
        [ h1 [] [ text "Your characters" ]
        , div []
            (Dict.values
                (Dict.map
                    (\characterId -> \character -> a [ href (Route.toHref (CharacterSheet characterId (Just ""))) ] [ text character.name ])
                    player.characters
                )
            )
        ]
    , title = "Hello"
    }



-- UPDATE


type Msg
    = NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
