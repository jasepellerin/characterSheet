module Pages.CharacterSelect exposing (Model, Msg, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, div, h1, text)
import Html.Attributes exposing (href)
import Modules.Player exposing (Player)
import Url exposing (Url)
import Route exposing (Route(..))
import Modules.CharacterData exposing (characterDataEncoder)
import Ports exposing (log)
import Json.Encode as Encode
import Types.CharacterData exposing (CharacterData)
import Api.UrlBuilder exposing (UrlBuilder)
import Http



-- MODEL


type alias Model a =
    { a
        | player : Player
        , selectedCharacterId : String
        , urlBuilder : UrlBuilder
    }



-- VIEW


view : Model a -> { content : Html Msg, title : String }
view { player } =
    { content = div [] [h1 [] [ text "Your characters" ] , a [href (Route.toHref CreateCharacter)] [text "Create New"]
    , div [] (Dict.values (Dict.map (\characterId -> \character ->  a [ href (Route.toHref (CharacterSheet characterId)) ] [ text character.name ] ) player.characters))]
    , title = "Hello"
    }



-- UPDATE


type Msg
    = NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
