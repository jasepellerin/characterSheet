module Modules.CharacterData exposing (characterDataDecoder, characterDataEncoder)

import Dict
import Json.Decode as Decode exposing (at, int, string)
import Json.Decode.Pipeline exposing (custom, requiredAt)
import Json.Encode as Encode
import Modules.Skills exposing (characterSkillsDecoder)
import Modules.SpecialAttribute exposing (getAttributeValueFromNameWithDefault, specialAttributeNames)
import Types.CharacterData exposing (CharacterData)


characterDataEncoder : CharacterData -> Encode.Value
characterDataEncoder characterData =
    Encode.object
        (List.append
            [ ( "name", Encode.string characterData.name )
            , ( "level", Encode.int characterData.level )
            , ( "armorType", Encode.string characterData.armorType )
            , ( "playerId", Encode.string characterData.playerId )
            , ( "skills"
              , Encode.object
                    (Dict.values (Dict.map (\skillName -> \isTrained -> ( skillName, Encode.bool isTrained )) characterData.skills))
              )
            ]
            (List.map
                (\attributeName -> ( attributeName, Encode.int (getAttributeValueFromNameWithDefault 0 characterData attributeName) ))
                specialAttributeNames
            )
        )


characterDataDecoder : String -> Decode.Decoder CharacterData
characterDataDecoder key =
    let
        atArray name =
            case key == "" of
                True ->
                    [ name ]

                False ->
                    [ key, name ]
    in
    Decode.succeed CharacterData
        |> requiredAt (atArray "name") string
        |> requiredAt (atArray "level") int
        |> requiredAt (atArray "armorType") string
        |> requiredAt (atArray "strength") int
        |> requiredAt (atArray "perception") int
        |> requiredAt (atArray "endurance") int
        |> requiredAt (atArray "charisma") int
        |> requiredAt (atArray "intelligence") int
        |> requiredAt (atArray "agility") int
        |> requiredAt (atArray "luck") int
        |> custom (at (atArray "skills") characterSkillsDecoder)
        |> requiredAt (atArray "playerId") string
