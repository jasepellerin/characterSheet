module Session exposing (Session)

import Api.UrlBuilder exposing (UrlBuilder)
import Browser.Navigation as Nav
import Modules.Player exposing (Player)


type alias Session =
    { navKey : Nav.Key
    , player : Player
    , urlBuilder : UrlBuilder
    }
