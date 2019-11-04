module Route exposing (Route(..))
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)


type Route
    = CharacterSelect
    | CharacterSheet

parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map CharacterSelect Parser.top
        , Parser.map CharacterSelect (s "characters")
        , Parser.map CharacterSheet (s "character")
        ]
