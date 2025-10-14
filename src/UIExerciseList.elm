module UIExerciseList exposing (view)

import Dict exposing (Dict)
import Grade
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Evts
import Types exposing (..)


view : Dict Int Evaluation -> Exercises -> Maybe Exercise -> Html FrontendMsg
view evaluations (Exercises items) selected =
    ul [ Attr.class "exercises" ]
        (List.map (viewItem evaluations selected) items)


viewItem : Dict Int Evaluation -> Maybe Exercise -> Exercise -> Html FrontendMsg
viewItem evaluations selected exercise =
    let
        isSelected =
            case selected of
                Just sel ->
                    sel.id == exercise.id

                Nothing ->
                    False

        cssClass =
            "exercise"
                ++ (if isSelected then
                        " selected"

                    else
                        ""
                   )

        commented str =
            let
                completeLabel =
                    if String.isEmpty str then
                        "_"

                    else
                        "✓"
            in
            span [] [ span [ Attr.class "comment" ] [ text completeLabel ] ]

        completion maybeGrade =
            let
                completeClass =
                    maybeGrade
                        |> Maybe.map Grade.gradeClass
                        |> Maybe.withDefault ""
            in
            span [] [ span [ Attr.class ("dot filled " ++ completeClass) ] [] ]

        getCompletion evaluation =
            span []
                [ completion evaluation.clarity
                , completion evaluation.usefulness
                , completion evaluation.fun
                , commented evaluation.theGood
                , commented evaluation.theBad
                , commented evaluation.theUgly
                ]

        label =
            exercise.title ++ " "

        childrenView =
            case exercise.children of
                Exercises [] ->
                    text ""

                Exercises xs ->
                    ul [ Attr.class "exercises" ]
                        (List.map (viewItem evaluations selected) xs)
    in
    case Dict.get exercise.id evaluations of
        Just eval ->
            li [ Attr.class cssClass ]
                [ button [ Attr.class "exercise-btn", Evts.onClick (SelectExercise exercise.id) ]
                    [ text label, getCompletion eval ]
                , childrenView
                ]

        Nothing ->
            Html.text "Problem: evaluation not found."
