module Main exposing (main)

import Api.UrlBuilder exposing (UrlBuilder)
import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html
import Json.Encode as Encode
import Modules.Player exposing (Player, getCharactersForPlayer)
import Pages.CharacterSelect as CharacterSelect
import Pages.CharacterSheet as CharacterSheet
import Route exposing (Route(..), fromUrl)
import Url exposing (Url)
import Url.Builder
import Ports exposing (log)
import Types.CharacterData exposing (CharacterData)
import Http
import Modules.CharacterData exposing (characterDataEncoder)


-- MODEL


type alias Model =
    { navKey : Nav.Key
    , route : Route
    , player : Player
    , selectedCharacterId : String
    , urlBuilder : UrlBuilder
    }


type ModelConverter
    = CharacterSelectConverter (CharacterSelect.Model {route : Route, navKey: Nav.Key})
    | CharacterSheetConverter (CharacterSheet.Model {route : Route, navKey: Nav.Key})


convertModel : Model -> ModelConverter -> Model
convertModel model converter =
    case converter of
        CharacterSelectConverter subModel ->
            { model | selectedCharacterId = subModel.selectedCharacterId, player = subModel.player }

        CharacterSheetConverter subModel ->
            {model | player = subModel.player}


init : { currentPlayerId : String } -> Url -> Nav.Key -> ( Model, Cmd Msg )
init { currentPlayerId } url navKey =
    let
        urlBuilder =
            case url.host == "localhost" of
                True ->
                    Url.Builder.crossOrigin "http://localhost:8888"

                False ->
                    Url.Builder.absolute

        initialModel = { navKey = navKey, route = Route.CharacterSelect, player = Player currentPlayerId Dict.empty, selectedCharacterId = "", urlBuilder = urlBuilder }
    in
    (initialModel, getCharactersForPlayer (Initialized url) initialModel)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        makePage toMsg { content, title } =
            Browser.Document title (List.map (Html.map toMsg) [ content ])
    in
    case model.route of
        CharacterSelect ->
            makePage GotCharacterSelectMsg (CharacterSelect.view model)

        CharacterSheet slug ->
            makePage GotCharacterSheetMsg (CharacterSheet.view model)



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotCharacterSelectMsg CharacterSelect.Msg
    | GotCharacterSheetMsg CharacterSheet.Msg
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

        Initialized url result ->
            let
                player = model.player
            in
            case result of
                Ok result_ ->
                    changeRoute (Route.fromUrl url) {model | player = {player | characters = result_}}
                            
                Err error ->
                    case error of
                        Http.BadBody errorMsg ->
                            ( model, log (Encode.string errorMsg))
                    
                        _ ->
                            ( model, log (Encode.string "Unknown Error") )

        NoOp ->
            ( model, Cmd.none )


changeRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( model, log (Encode.string "Not found") )

        Just Route.CharacterSelect ->
            ( { model | route = Route.CharacterSelect }, log (Encode.string "CharacterSelect") )

        Just (Route.CharacterSheet slug) ->
            ( { model | route = Route.CharacterSheet slug, selectedCharacterId = slug }, log (Encode.string ("CharacterSheet - " ++ slug)) )


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
