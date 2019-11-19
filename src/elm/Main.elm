module Main exposing (main)

import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Modules.CharacterData exposing (characterDataEncoder)
import Modules.Player exposing (Player, getCharactersForPlayer)
import Pages.CharacterSelect as CharacterSelect
import Pages.CharacterSheet as CharacterSheet
import Pages.CharacterSheet.Msg as CharacterSheetMsg
import Pages.CreateCharacter as CreateCharacter
import Pages.Loading as Loading
import Ports exposing (log)
import Route exposing (Route(..), changeRoute, fromUrl)
import Types.CharacterData exposing (CharacterData)
import Url exposing (Url)
import Url.Builder



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , route : Route
    , player : Player
    , selectedCharacterId : String
    , selectedTab : String
    , urlBuilder : UrlBuilder
    }


type ModelConverter
    = CharacterSelectConverter (CharacterSelect.Model { route : Route, navKey : Nav.Key, selectedTab : String })
    | CharacterSheetConverter (CharacterSheet.Model { route : Route, navKey : Nav.Key })
    | CreateCharacterConverter (CreateCharacter.Model { navKey : Nav.Key, selectedTab : String })


convertModel : Model -> ModelConverter -> Model
convertModel model converter =
    case converter of
        CharacterSelectConverter subModel ->
            { model | selectedCharacterId = subModel.selectedCharacterId, player = subModel.player }

        CharacterSheetConverter subModel ->
            { model | player = subModel.player }

        CreateCharacterConverter subModel ->
            { model | player = subModel.player, selectedCharacterId = subModel.selectedCharacterId }


init : { currentPlayerId : String } -> Url -> Nav.Key -> ( Model, Cmd Msg )
init { currentPlayerId } url navKey =
    let
        urlBuilder =
            case url.host == "localhost" of
                True ->
                    Url.Builder.crossOrigin "http://localhost:8888"

                False ->
                    Url.Builder.absolute

        initialModel =
            { navKey = navKey
            , route = Route.Loading
            , player = Player currentPlayerId Dict.empty
            , selectedCharacterId = ""
            , selectedTab = ""
            , urlBuilder = urlBuilder
            }
    in
    ( initialModel, getCharactersForPlayer (Initialized url) initialModel )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        makePage : (msg -> Msg) -> { content : List (Html msg), title : String } -> Browser.Document Msg
        makePage toMsg { content, title } =
            Browser.Document title (List.map (Html.map toMsg) content)
    in
    case model.route of
        CharacterSelect ->
            makePage GotCharacterSelectMsg (CharacterSelect.view model)

        CharacterSheet slug tab ->
            makePage GotCharacterSheetMsg (CharacterSheet.view model)

        CreateCharacter ->
            makePage GotCreateCharacterMsg (CreateCharacter.view model)

        Loading ->
            makePage (\msg -> NoOp) Loading.view



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotCharacterSelectMsg CharacterSelect.Msg
    | GotCharacterSheetMsg CharacterSheetMsg.Msg
    | GotCreateCharacterMsg CreateCharacter.Msg
    | Initialized Url (Result Http.Error (Dict String CharacterData))
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedUrl url ->
            changeRoute (Route.fromUrl url) model

        ClickedLink request ->
            case request of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        GotCharacterSelectMsg msg_ ->
            CharacterSelect.update msg_ model
                |> updateWith CharacterSelectConverter GotCharacterSelectMsg model

        GotCharacterSheetMsg msg_ ->
            CharacterSheet.update msg_ model
                |> updateWith CharacterSheetConverter GotCharacterSheetMsg model

        GotCreateCharacterMsg msg_ ->
            CreateCharacter.update msg_ model
                |> updateWith CreateCharacterConverter GotCreateCharacterMsg model

        Initialized url result ->
            let
                player =
                    model.player
            in
            case result of
                Ok result_ ->
                    changeRoute (Route.fromUrl url) { model | player = { player | characters = result_ } }

                Err error ->
                    case error of
                        Http.BadBody errorMsg ->
                            ( model, log (Encode.string errorMsg) )

                        _ ->
                            ( model, log (Encode.string "Unknown Error") )

        NoOp ->
            ( model, Cmd.none )


updateWith : (subModel -> ModelConverter) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( convertModel model (toModel subModel)
    , Cmd.map toMsg subCmd
    )



-- MAIN


main : Program { currentPlayerId : String } Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
