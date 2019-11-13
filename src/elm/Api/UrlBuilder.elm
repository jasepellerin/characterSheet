module Api.UrlBuilder exposing (UrlBuilder)
import Url.Builder exposing (QueryParameter)


type alias UrlBuilder =
    List String -> List QueryParameter -> String
