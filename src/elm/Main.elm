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
import Route exposing (Route, fromUrl)
import Session exposing (Session)
import Types.CharacterData exposing (CharacterData)
import Url exposing (Url)
import Url.Builder



-- MODEL


type alias BaseModel =
    { route : Route
    , selectedCharacterId : String
    , selectedTab : String
    , session : Session
    }


type Model
    = Base BaseModel
    | CharacterSelect CharacterSelect.Model
    | CharacterSheet CharacterSheet.Model
    | CreateCharacter CreateCharacter.Model


type ModelConverter
    = CharacterSelectConverter CharacterSelect.Model
    | CharacterSheetConverter CharacterSheet.Model
    | CreateCharacterConverter CreateCharacter.Model


getSession : Model -> Session
getSession model =
    case model of
        Base base ->
            base.session

        CharacterSelect characterSelect ->
            characterSelect.session

        CharacterSheet characterSheet ->
            characterSheet.session

        CreateCharacter createCharacter ->
            createCharacter.session


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
            { route = Route.Loading
            , selectedCharacterId = ""
            , selectedTab = ""
            , session =
                { navKey = navKey
                , player = Player currentPlayerId Dict.empty
                , urlBuilder = urlBuilder
                }
            }
    in
    ( Base initialModel, getCharactersForPlayer (Initialized url) initialModel.session )


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
    case model of
        Base _ ->
            makePage (\msg -> NoOp) Loading.view

        CharacterSelect characterSelect ->
            makePage GotCharacterSelectMsg (CharacterSelect.view characterSelect)

        CharacterSheet characterSheet ->
            makePage GotCharacterSheetMsg (CharacterSheet.view characterSheet)

        CreateCharacter createCharacter ->
            makePage GotCreateCharacterMsg (CreateCharacter.view createCharacter)



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
    case ( msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRoute (Route.fromUrl url) model

        ( ClickedLink request, _ ) ->
            case request of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (.navKey (getSession model)) (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        ( GotCharacterSelectMsg msg_, CharacterSelect characterSelect ) ->
            CharacterSelect.update msg_ characterSelect
                |> updateWith CharacterSelect GotCharacterSelectMsg model

        ( GotCharacterSheetMsg msg_, CharacterSheet characterSheet ) ->
            CharacterSheet.update msg_ characterSheet
                |> updateWith CharacterSheet GotCharacterSheetMsg model

        ( GotCreateCharacterMsg msg_, CreateCharacter createCharacter ) ->
            CreateCharacter.update msg_ createCharacter
                |> updateWith CreateCharacter GotCreateCharacterMsg model

        ( Initialized url result, Base baseModel ) ->
            let
                session =
                    getSession model

                player =
                    session.player
            in
            case result of
                Ok result_ ->
                    changeRoute (Route.fromUrl url) (Base { baseModel | session = { session | player = { player | characters = result_ } } })

                Err error ->
                    case error of
                        Http.BadBody errorMsg ->
                            ( model, log (Encode.string errorMsg) )

                        _ ->
                            ( model, log (Encode.string "Unknown Error") )

        ( NoOp, _ ) ->
            ( model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- ROUTE


changeRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( model, log (Encode.string "Not found") )

        Just Route.CharacterSelect ->
            ( model, log (Encode.string "CharacterSelect") )

        Just (Route.CharacterSheet slug tab) ->
            CharacterSheet.init (getSession model) slug tab
                |> updateWith CharacterSheet GotCharacterSheetMsg model

        Just Route.CreateCharacter ->
            ( model, log (Encode.string "CreateCharacter") )

        Just Route.Loading ->
            ( model, log (Encode.string "Loading") )



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
