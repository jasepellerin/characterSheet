module Utils.CapitalizeFirstLetter exposing (capitalizeFirstLetter)


capitalizeFirstLetter : String -> String
capitalizeFirstLetter string =
    String.toUpper (String.left 1 string) ++ String.dropLeft 1 string
