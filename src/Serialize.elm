module Serialize exposing (..)

import Dict exposing (Dict)
import Grade exposing (..)
import Json.Decode
import Json.Encode
import Types exposing (..)


encodeGrade : Grade -> Json.Encode.Value
encodeGrade grade =
    Json.Encode.int (gradeToInt grade)


decodeGrade : Json.Decode.Decoder Grade
decodeGrade =
    Json.Decode.int |> Json.Decode.map intToGrade


maybeEncodeGrade : Maybe Grade -> Json.Encode.Value
maybeEncodeGrade maybeGrade =
    case maybeGrade of
        Just g ->
            encodeGrade g

        Nothing ->
            Json.Encode.null


maybeDecodeGrade : String -> Json.Decode.Decoder (Maybe Grade)
maybeDecodeGrade fieldName =
    Json.Decode.field fieldName (Json.Decode.nullable decodeGrade)


encodeEvaluation : Evaluation -> Json.Encode.Value
encodeEvaluation eval =
    Json.Encode.object
        [ ( "clarity", maybeEncodeGrade eval.clarity )
        , ( "usefulness", maybeEncodeGrade eval.usefulness )
        , ( "fun", maybeEncodeGrade eval.fun )
        , ( "theGood", Json.Encode.string eval.theGood )
        , ( "theBad", Json.Encode.string eval.theBad )
        , ( "theUgly", Json.Encode.string eval.theUgly )
        ]


decodeEvaluation : Json.Decode.Decoder Evaluation
decodeEvaluation =
    Json.Decode.map6 Evaluation
        (maybeDecodeGrade "clarity")
        (maybeDecodeGrade "usefulness")
        (maybeDecodeGrade "fun")
        (Json.Decode.field "theGood" Json.Decode.string)
        (Json.Decode.field "theBad" Json.Decode.string)
        (Json.Decode.field "theUgly" Json.Decode.string)


encodeEvaluations : Dict Int Evaluation -> Json.Encode.Value
encodeEvaluations dict =
    dict
        |> Dict.toList
        |> List.map (\( k, v ) -> ( String.fromInt k, encodeEvaluation v ))
        |> Json.Encode.object


decodeEvaluations : Json.Decode.Decoder (Dict Int Evaluation)
decodeEvaluations =
    Json.Decode.dict decodeEvaluation
        |> Json.Decode.map
            (Dict.fromList
                << List.map (\( k, v ) -> ( String.toInt k |> Maybe.withDefault 0, v ))
                << Dict.toList
            )


encodeUser : User -> Json.Encode.Value
encodeUser user =
    Json.Encode.object
        [ ( "name", Json.Encode.string user.name )
        , ( "pass", Json.Encode.string user.pass )
        , ( "evaluations", encodeEvaluations user.evaluations )
        ]


decodeUser : Json.Decode.Decoder User
decodeUser =
    Json.Decode.map3 User
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "pass" Json.Decode.string)
        (Json.Decode.field "evaluations" decodeEvaluations)


encodeUsers : List User -> Json.Encode.Value
encodeUsers users =
    Json.Encode.list encodeUser users


decodeUsers : Json.Decode.Decoder (List User)
decodeUsers =
    Json.Decode.list decodeUser
