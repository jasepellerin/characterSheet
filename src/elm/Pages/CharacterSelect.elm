module Pages.CharacterSelect exposing (Model, Msg, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, div, h1, button, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Modules.Player exposing (Player, getCharactersForPlayer)
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
    { content = div [] [h1 [] [ text "Your characters" ] , button [onClick GetCharacters] [text "update"]
    , div [] (Dict.values (Dict.map (\characterId -> \character ->  a [ href (Route.toHref (CharacterSheet characterId)) ] [ text character.name ] ) player.characters))]
    , title = "Hello"
    }



-- UPDATE


type Msg
    = NoOp
    | GetCharacters
    | GotText (Result Http.Error (Dict String CharacterData))


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetCharacters ->
            ( model, getCharactersForPlayer GotText model )

        GotText result ->
            let
                player = model.player
            in
            case result of
                Ok result_ ->
                    ( {model | player = {player | characters = result_}}, log (Encode.dict identity characterDataEncoder result_))
                            
                Err error ->
                    case error of
                        Http.BadBody errorMsg ->
                            ( model, log (Encode.string errorMsg))
                    
                        _ ->
                            ( model, log (Encode.string "Unknown Error") )
