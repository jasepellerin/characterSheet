port module Pages.CharacterSheet exposing (Model, Msg, update, view)

import Api.Endpoint as Endpoint
import Api.Main as Api
import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, text)
import Html.Attributes exposing (classList, href)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Modules.Armor exposing (getArmorEnduranceRequirement)
import Modules.Card exposing (card)
import Modules.CharacterData exposing (characterDataDecoder, characterDataEncoder)
import Modules.CharacterHeader exposing (characterHeader)
import Modules.DerivedStatistics exposing (derivedStatistics)
import Modules.Player exposing (Player)
import Ports exposing (log)
import Route exposing (Route(..))
import Types.CharacterData exposing (CharacterData)


port setLocalData : Encode.Value -> Cmd msg



-- MODEL


type alias Model a =
    { a
        | player : Player
        , selectedCharacterId : String
        , selectedTab : String
        , urlBuilder : UrlBuilder
    }


type Tab
    = Gear
    | Info
    | Skills


getTabFromName : String -> Tab
getTabFromName tabName =
    case String.toLower tabName of
        "gear" ->
            Gear

        "info" ->
            Info

        "skills" ->
            Skills

        _ ->
            Info



-- VIEW


view : Model a -> { content : List (Html Msg), title : String }
view model =
    let
        { selectedCharacterId, player } =
            model

        selectedTab =
            getTabFromName model.selectedTab
    in
    { content =
        case Dict.get selectedCharacterId player.characters of
            Just characterData ->
                let
                    tabContents =
                        case selectedTab of
                            Gear ->
                                [ text "gear" ]

                            Info ->
                                [ derivedStatisticsView characterData ]

                            Skills ->
                                [ text "skills" ]
                in
                List.append
                    [ headerView characterData
                    , tabView selectedCharacterId
                    ]
                    tabContents

            Nothing ->
                [ text "No character with this ID was found", button [ onClick GetCharacter ] [ text "Check again" ] ]
    , title = "Sheet"
    }


headerView : CharacterData -> Html Msg
headerView characterData =
    characterHeader NoOp NoOp characterData


tabView : String -> Html Msg
tabView selectedCharacterId =
    div []
        [ a [ href (Route.toHref (CharacterSheet selectedCharacterId (Just "skills"))) ] [ text "Skills" ]
        , a [ href (Route.toHref (CharacterSheet selectedCharacterId (Just "info"))) ] [ text "Info" ]
        , a [ href (Route.toHref (CharacterSheet selectedCharacterId (Just "gear"))) ] [ text "Gear" ]
        ]


derivedStatisticsView : CharacterData -> Html Msg
derivedStatisticsView characterData =
    let
        encumbered =
            characterData.endurance < getArmorEnduranceRequirement characterData.armorType

        encumberedClasses =
            classList
                [ ( "encumbered", encumbered )
                ]
    in
    div [] (List.map (card [ encumberedClasses ]) (derivedStatistics characterData encumbered))



-- UPDATE


getCharacter : Model a -> Cmd Msg
getCharacter { selectedCharacterId, urlBuilder } =
    Api.get (Endpoint.getCharacter urlBuilder selectedCharacterId) GotCharacter (Decode.field "data" (characterDataDecoder ""))


type Msg
    = GetCharacter
    | GotCharacter (Result Http.Error CharacterData)
    | HandleChange CharacterData
    | NoOp


update : Msg -> Model a -> ( Model a, Cmd Msg )
update msg model =
    let
        player =
            model.player
    in
    case msg of
        GetCharacter ->
            ( model, getCharacter model )

        GotCharacter result ->
            case result of
                Ok result_ ->
                    case result_.playerId == player.id of
                        True ->
                            let
                                updatedCharacters =
                                    Dict.insert model.selectedCharacterId result_ player.characters
                            in
                            ( { model | player = { player | characters = updatedCharacters } }, log (Encode.dict identity characterDataEncoder updatedCharacters) )

                        False ->
                            -- TODO: Show other player's character without updating current player
                            ( model, log (Encode.string "Character does not belong to current player") )

                Err error ->
                    case error of
                        Http.BadBody errorMsg ->
                            ( model, log (Encode.string errorMsg) )

                        _ ->
                            ( model, log (Encode.string "Unknown Error") )

        HandleChange newData ->
            let
                updatedCharacters =
                    Dict.insert model.selectedCharacterId newData model.player.characters
            in
            ( { model | player = { player | characters = updatedCharacters } }, setLocalData (Encode.dict identity characterDataEncoder updatedCharacters) )

        NoOp ->
            ( model, Cmd.none )
