port module Ports exposing (log)

import Json.Encode as Encode



-- PORTS


port log : Encode.Value -> Cmd msg
