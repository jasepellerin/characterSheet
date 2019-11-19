module Utils.String exposing (capitalizeFirstLetter, getTitleFromSnakeCase)


capitalizeFirstLetter : String -> String
capitalizeFirstLetter string =
    String.toUpper (String.left 1 string) ++ String.dropLeft 1 string


getTitleFromSnakeCase : String -> String
getTitleFromSnakeCase string =
    String.split "_" string |> List.map capitalizeFirstLetter |> String.join " "
