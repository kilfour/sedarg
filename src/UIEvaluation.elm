module UIEvaluation exposing (view)

import Dict
import Env
import Grade exposing (..)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Evts
import Types exposing (..)


view : FrontendModel -> User -> Html FrontendMsg
view model user =
    case model.selected of
        Just exercise ->
            case Dict.get exercise.id user.evaluations of
                Just eval ->
                    evaluationView exercise eval

                Nothing ->
                    Html.text "Problem: evaluation not found."

        Nothing ->
            div [ Attr.class "placeholder" ]
                [ text "Select an exercise to view its evaluation." ]


evaluationView : Exercise -> Evaluation -> Html FrontendMsg
evaluationView exercise eval =
    let
        link =
            Env.githubUrl ++ exercise.link ++ "/readme.md"
    in
    div []
        [ h2 []
            [ text (exercise.title ++ " : ")
            , Html.a [ Attr.href link, Attr.target "_blank", Attr.rel "noopener noreferrer" ] [ text "README" ]
            ]
        , div [ Attr.class "evaluation" ]
            [ table [ Attr.class "grades" ]
                [ thead [] [ tr [] [ th [] [ text "Aspect" ], th [] [ text "Grade" ] ] ]
                , tbody []
                    [ viewGradeRow "Clarity" eval.clarity SetClarity
                    , viewGradeRow "Usefulness" eval.usefulness SetUsefulness
                    , viewGradeRow "Fun" eval.fun SetFun
                    ]
                ]
            , section "The Good" eval.theGood EditTheGood
            , section "The Bad" eval.theBad EditTheBad
            , section "The Ugly" eval.theUgly EditTheUgly
            ]
        ]


viewGradeRow : String -> Maybe Grade -> (Grade -> msg) -> Html msg
viewGradeRow label maybeGrade action =
    let
        currentGrade =
            maybeGrade
                |> Maybe.map gradeToString
                |> Maybe.withDefault ""
    in
    tr []
        [ td [ Attr.class "grade-label" ] [ text label ]
        , td [ Attr.class "grade-value" ] [ viewGradeControl maybeGrade action ]
        ]


viewGradeControl : Maybe Grade -> (Grade -> msg) -> Html msg
viewGradeControl maybeGrade action =
    div [ Attr.class "grade-control" ]
        (Grade.mapAll (viewGradeControlPart maybeGrade action))


viewGradeControlPart : Maybe Grade -> (Grade -> msg) -> Grade -> Html msg
viewGradeControlPart maybeGrade action grade =
    let
        val =
            maybeGrade
                |> Maybe.map gradeToInt
                |> Maybe.withDefault 0

        getClass =
            gradeClass grade
                ++ (if val == gradeToInt grade then
                        " grade filled"

                    else
                        " grade"
                   )
    in
    span [ Attr.class getClass, Evts.onClick (action grade) ] [ text (gradeToControlString grade) ]


section : String -> String -> (String -> msg) -> Html msg
section title content action =
    div [ Attr.class "evaluation-section" ]
        [ h3 [] [ text title ]
        , textarea [ Attr.value content, Evts.onInput action ] []
        ]
