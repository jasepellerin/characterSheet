port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (a, text)
import Html.Attributes exposing (href)
import Json.Encode as Encode
import Modules.Player exposing (Player)
import Pages.CharacterSelect as CharacterSelect
import Route exposing (Route(..), fromUrl)
import Url exposing (Url)



-- PORTS


port log : Encode.Value -> Cmd msg



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , page : String
    , player : Player
    }


type ModelConverter
    = CharacterSelectConverter


convertModel : Model -> ModelConverter -> subModel -> Model
convertModel model converter subModel =
    case converter of
        CharacterSelectConverter ->
            model


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRoute (Route.fromUrl url) { navKey = navKey, page = "/", player = Player "" Dict.empty }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view { page, player } =
    let
        makePage toMsg { content, title } =
            Browser.Document title (List.map (Html.map toMsg) [ content ])
    in
    case page of
        "home" ->
            makePage GotCharacterSelectMsg (CharacterSelect.view { player = player })

        _ ->
            { body = [ a [ href "/home" ] [ text "hi" ] ]
            , title = "Hello"
            }



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotCharacterSelectMsg CharacterSelect.Msg
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

        NoOp ->
            ( model, Cmd.none )


changeRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( model, log (Encode.string "Nothing ") )

        Just Route.CharacterSelect ->
            ( model, log (Encode.string "CharacterSelect ") )

        Just (Route.CharacterSheet _) ->
            ( model, log (Encode.string "CharacterSheet ") )


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
