port module Pages.CharacterSheet exposing (Model, init, update, view)

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
import Modules.DerivedStatistics exposing (derivedStatistics)
import Modules.SpecialAttribute exposing (specialAttributeNames, specialAttributeView)
import Pages.CharacterSheet.CharacterHeader exposing (characterHeader)
import Pages.CharacterSheet.Gear exposing (gearView)
import Pages.CharacterSheet.Msg exposing (Msg(..))
import Pages.CharacterSheet.Skills exposing (skillsView)
import Ports exposing (log)
import Route exposing (Route(..))
import Session exposing (Session)
import Types.CharacterData exposing (CharacterData)
import Utils.String exposing (capitalizeFirstLetter)


port setLocalData : Encode.Value -> Cmd msg



-- MODEL


type alias Model =
    { session : Session
    , selectedCharacterId : String
    , selectedTab : String
    }


init : Session -> String -> Maybe String -> ( Model, Cmd msg )
init session selectedCharacterId selectedTab =
    ( { session = session
      , selectedCharacterId = selectedCharacterId
      , selectedTab = Maybe.withDefault "statistics" selectedTab
      }
    , Cmd.none
    )



-- VIEW


view : Model -> { content : List (Html Msg), title : String }
view model =
    let
        { selectedCharacterId, session } =
            model

        { player } =
            session

        selectedTab =
            getTabFromName model.selectedTab
    in
    case Dict.get selectedCharacterId player.characters of
        Just characterData ->
            { content =
                let
                    isEncumbered =
                        characterData.endurance < getArmorEnduranceRequirement characterData.armorType

                    encumberedClasses =
                        [ ( "encumbered", isEncumbered ) ]

                    tabContents =
                        case selectedTab of
                            Gear ->
                                [ gearView encumberedClasses characterData ]

                            Info ->
                                [ text "info" ]

                            Skills ->
                                [ skillsView characterData ]

                            Special ->
                                [ div [] (List.map (specialAttributeView False characterData) specialAttributeNames) ]

                            Statistics ->
                                [ div [] (List.map (card [ classList encumberedClasses ]) (derivedStatistics characterData isEncumbered)) ]
                in
                List.append
                    [ characterHeader characterData
                    , tabView selectedCharacterId model.selectedTab
                    ]
                    tabContents
            , title = characterData.name ++ " - " ++ capitalizeFirstLetter model.selectedTab
            }

        Nothing ->
            { content = [ text "No character with this ID was found", button [ onClick GetCharacter ] [ text "Check again" ] ]
            , title = "Character not found"
            }



-- SUBVIEWS


tabView : String -> String -> Html Msg
tabView selectedCharacterId selectedTab =
    let
        getTab tabName =
            Dict.get tabName tabNames

        singleTabView tabName =
            a [ classList [ ( "active", selectedTab == tabName ) ], href (Route.toHref (CharacterSheet selectedCharacterId (Just tabName))) ] [ text (capitalizeFirstLetter tabName) ]
    in
    div []
        (List.map singleTabView tabNameOrderedList)



-- INTERNAL TYPES


type Tab
    = Gear
    | Info
    | Skills
    | Special
    | Statistics


tabNameOrderedList =
    [ "special"
    , "skills"
    , "statistics"
    , "gear"
    , "info"
    ]


tabNames =
    Dict.fromList
        [ ( "gear", Gear )
        , ( "info", Info )
        , ( "special", Special )
        , ( "skills", Skills )
        , ( "statistics", Statistics )
        ]


getTabFromName : String -> Tab
getTabFromName tabName =
    case Dict.get tabName tabNames of
        Just tab ->
            tab

        Nothing ->
            Statistics



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        session =
            model.session

        player =
            session.player
    in
    case msg of
        Edit ->
            ( model, Cmd.none )

        GetCharacter ->
            ( model, Cmd.none )

        GotCharacter result ->
            case result of
                Ok result_ ->
                    case result_.playerId == player.id of
                        True ->
                            let
                                updatedCharacters =
                                    Dict.insert model.selectedCharacterId result_ player.characters
                            in
                            ( { model | session = { session | player = { player | characters = updatedCharacters } } }, log (Encode.dict identity characterDataEncoder updatedCharacters) )

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
                    Dict.insert model.selectedCharacterId newData player.characters
            in
            ( { model | session = { session | player = { player | characters = updatedCharacters } } }, setLocalData (Encode.dict identity characterDataEncoder updatedCharacters) )

        NoOp ->
            ( model, Cmd.none )
