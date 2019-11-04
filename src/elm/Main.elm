port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (a, text)
import Html.Attributes exposing (href)
import Json.Encode as Encode
import Modules.Player exposing (Player)
import Pages.CharacterSelect as CharacterSelect
import Pages.CharacterSheet as CharacterSheet
import Route exposing (Route(..), fromUrl)
import Url exposing (Url)



-- PORTS


port log : Encode.Value -> Cmd msg



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , route : Route
    , player : Player
    }


type ModelConverter
    = CharacterSelectConverter
    | CharacterSheetConverter


convertModel : Model -> ModelConverter -> subModel -> Model
convertModel model converter subModel =
    case converter of
        CharacterSelectConverter ->
            model

        CharacterSheetConverter ->
            model


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRoute (Route.fromUrl url) { navKey = navKey, route = Route.CharacterSelect, player = Player "" Dict.empty }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view { route, player } =
    let
        makePage toMsg { content, title } =
            Browser.Document title (List.map (Html.map toMsg) [ content ])
    in
    case route of
        CharacterSelect ->
            makePage GotCharacterSelectMsg (CharacterSelect.view { player = player })

        CharacterSheet slug ->
            makePage GotCharacterSheetMsg (CharacterSheet.view { player = player, characterId = slug })



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotCharacterSelectMsg CharacterSelect.Msg
    | GotCharacterSheetMsg CharacterSheet.Msg
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
            CharacterSelect.update msg_ { player = model.player }
                |> updateWith CharacterSelectConverter GotCharacterSelectMsg model

        GotCharacterSheetMsg msg_ ->
            CharacterSheet.update msg_ { player = model.player }
                |> updateWith CharacterSheetConverter GotCharacterSheetMsg model

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
            ( { model | route = Route.CharacterSheet slug }, log (Encode.string "CharacterSheet") )


updateWith : ModelConverter -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( convertModel model toModel subModel
    , Cmd.map toMsg subCmd
    )



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
