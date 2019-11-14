module Pages.CharacterSelect exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api
import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, div, h1, button, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Modules.Player exposing (Player)
import Url exposing (Url)
import Route exposing (Route(..))
import Modules.CharacterData exposing (characterDataDecoder, characterDataEncoder)
import Ports exposing (log)
import Json.Encode as Encode
import Types.CharacterData exposing (CharacterData)



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
    { content = div [] [h1 [] [ text "Your characters" ] , button [onClick HandleUpdate] [text "update"]
    , div [] (Dict.values (Dict.map (\characterId -> \character ->  a [ href (Route.toHref (CharacterSheet characterId)) ] [ text character.name ] ) player.characters))]
    , title = "Hello"
    }



-- UPDATE


getCharactersForPlayer : Model a -> Cmd Msg
getCharactersForPlayer {player, selectedCharacterId, urlBuilder} =
    Api.get (Endpoint.getCharactersForPlayer urlBuilder player.id) GotText (Decode.field "data" characterListDecoder)


type Msg
    = NoOp
    | HandleUpdate
    | GotText (Result Http.Error (Dict String CharacterData))


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HandleUpdate ->
            ( model, getCharactersForPlayer model )

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


characterListDecoder: Decode.Decoder (Dict String CharacterData)
characterListDecoder =
    Decode.map Dict.fromList (Decode.list (Decode.map2 (\key -> \value -> (key, value)) (Decode.at ["ref", "@ref", "id"] Decode.string) (characterDataDecoder "data")))
