module Pages.CharacterSelect exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api
import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, div, h1, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Modules.Player exposing (Player)
import Url exposing (Url)
import Route exposing (Route(..))



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
    { content = div [] [h1 [] [ text "Your characters" ]
    , div [] (Dict.values (Dict.map (\characterId -> \character ->  a [ href (Route.toHref (CharacterSheet characterId)) ] [ text character.name ] ) player.characters))]
    , title = "Hello"
    }



-- UPDATE


getChar : Model a -> Cmd Msg
getChar {player, selectedCharacterId, urlBuilder} =
    Api.get (Endpoint.getCharacter urlBuilder selectedCharacterId) GotText (Decode.at [ "data", "armorType" ] Decode.string)


type Msg
    = NoOp
    | HandleClick UrlBuilder
    | GotText (Result Http.Error String)


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HandleClick urlBuilder ->
            ( model, getChar model )

        GotText result ->
            ( model, Cmd.none )
