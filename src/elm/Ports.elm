port module Ports exposing (toJs)

import Json.Encode as E


port toJs : E.Value -> Cmd msg
