port module Pages.CharacterSheet exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api
import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Http
import Json.Decode as Decode
import Modules.Player exposing (Player)
import Json.Encode as Encode
import Types.CharacterData exposing (CharacterData)
import Modules.CharacterData exposing (characterDataEncoder)



port setLocalData : Encode.Value -> Cmd msg

-- MODEL


type alias Model a =
    { a
        | player : Player
        , selectedCharacterId : String
        , urlBuilder : UrlBuilder
    }



-- VIEW


view : Model a -> { content : Html Msg, title : String }
view { selectedCharacterId, player } =
    { content =
        case Dict.member selectedCharacterId player.characters of
            True ->
                div [] [ text selectedCharacterId ]

            False ->
                div [] [ text "No character with this ID was found" ]
    , title = "Sheet"
    }



-- UPDATE


getChar : {selectedCharacterId: String, urlBuilder: UrlBuilder} -> Cmd Msg
getChar {selectedCharacterId, urlBuilder} =
    Api.get (Endpoint.getCharacter urlBuilder selectedCharacterId) GotText (Decode.at [ "data", "armorType" ] Decode.string)


type Msg
    = GotText (Result Http.Error String)
    | HandleChange CharacterData
    | NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HandleChange newData ->
            let
                updatedCharacters = Dict.insert model.selectedCharacterId newData model.player.characters
                player = model.player
            in
            
            ({model | player = {player | characters = updatedCharacters}}, setLocalData (Encode.dict identity characterDataEncoder updatedCharacters))

        GotText result ->
            ( model, Cmd.none )
