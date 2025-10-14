module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Evaluation exposing (..)
import ExerciseList
import Grade exposing (..)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Html.Events exposing (onClick, onInput, onMouseOver)
import Lamdera
import List.Extra
import Set exposing (Set)
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


demoUser : User
demoUser =
    { name = "Demo"
    , pass = "demo"
    , evaluations = buildEvaluations
    }


buildEvaluations =
    List.range 1 61
        |> List.map (\a -> ( a, emptyEvaluation ))
        |> Dict.fromList


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , selected = Nothing
      , expanded = Set.fromList []
      , user = demoUser
      }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        SelectExercise id ->
            let
                selected =
                    findExerciseById id ExerciseList.all
            in
            ( { model | selected = selected }, Cmd.none )

        ToggleExpand id ->
            let
                newExpanded =
                    if Set.member id model.expanded then
                        Set.remove id model.expanded

                    else
                        Set.insert id model.expanded
            in
            ( { model | expanded = newExpanded }, Cmd.none )

        SetClarity grade ->
            let
                user =
                    updateSelectedEvaluation model (\a -> { a | clarity = Just grade })
            in
            ( { model | user = user }, Cmd.none )

        SetUsefulness grade ->
            let
                user =
                    updateSelectedEvaluation model (\a -> { a | usefulness = Just grade })
            in
            ( { model | user = user }, Cmd.none )

        SetFun grade ->
            let
                user =
                    updateSelectedEvaluation model (\a -> { a | fun = Just grade })
            in
            ( { model | user = user }, Cmd.none )

        EditTheGood str ->
            let
                user =
                    updateSelectedEvaluation model (\a -> { a | theGood = str })
            in
            ( { model | user = user }, Cmd.none )

        EditTheBad str ->
            let
                user =
                    updateSelectedEvaluation model (\a -> { a | theBad = str })
            in
            ( { model | user = user }, Cmd.none )

        EditTheUgly str ->
            let
                user =
                    updateSelectedEvaluation model (\a -> { a | theUgly = str })
            in
            ( { model | user = user }, Cmd.none )


updateSelectedEvaluation : Model -> (Evaluation -> Evaluation) -> User
updateSelectedEvaluation model func =
    let
        id =
            model.selected |> Maybe.map .id |> Maybe.withDefault 0

        evaluations =
            model.user.evaluations
                |> Dict.map
                    (\k a ->
                        if k == id then
                            func a

                        else
                            a
                    )

        user =
            model.user
    in
    { user | evaluations = evaluations }


findExerciseById : Int -> Exercises -> Maybe Exercise
findExerciseById id (Exercises list) =
    List.foldl
        (\ex acc ->
            case acc of
                Just _ ->
                    acc

                Nothing ->
                    if ex.id == id then
                        Just ex

                    else
                        findExerciseById id ex.children
        )
        Nothing
        list


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


emptyEvaluation : Evaluation
emptyEvaluation =
    { clarity = Nothing
    , usefulness = Nothing
    , fun = Nothing
    , theGood = ""
    , theBad = ""
    , theUgly = ""
    }


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "Exercises"
    , body =
        [ div [ class "layout" ]
            [ div [ class "master" ]
                [ h3 [] [ text model.user.name ]
                , viewExercisesSelectable model.user.evaluations ExerciseList.all model.selected
                ]
            , div [ class "detail" ]
                [ case model.selected of
                    Just ex ->
                        let
                            eval =
                                Dict.get ex.id model.user.evaluations
                                    |> Maybe.withDefault emptyEvaluation

                            link =
                                "https://github.com/becodeorg/GNT-2025-05-Dotnet/tree/main/TheCSharpPart/"
                                    ++ ex.link
                                    ++ "/readme.md"
                        in
                        div []
                            [ h2 []
                                [ text (ex.title ++ " : ")
                                , Html.a
                                    [ Attr.href link
                                    , Attr.target "_blank"
                                    , Attr.rel "noopener noreferrer"
                                    ]
                                    [ text "README" ]
                                ]
                            , viewEvaluation eval
                            ]

                    Nothing ->
                        div [ class "placeholder" ]
                            [ text "Select an exercise to view its evaluation." ]
                ]
            ]
        ]
    }


viewExercisesSelectable : Dict Int Evaluation -> Exercises -> Maybe Exercise -> Html FrontendMsg
viewExercisesSelectable evaluations (Exercises items) selected =
    ul [ class "exercises" ]
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

        eval =
            Dict.get exercise.id evaluations
                |> Maybe.withDefault emptyEvaluation

        completion maybeGrade =
            let
                completeClass =
                    maybeGrade
                        |> Maybe.map gradeClass
                        |> Maybe.withDefault ""
            in
            span [] [ span [ class ("dot filled " ++ completeClass) ] [] ]

        getCompletion evaluation =
            span []
                [ completion evaluation.clarity
                , completion evaluation.usefulness
                , completion evaluation.fun
                ]

        label =
            exercise.title ++ " "

        childrenView =
            case exercise.children of
                Exercises [] ->
                    text ""

                Exercises xs ->
                    ul [ class "exercises" ]
                        (List.map (viewItem evaluations selected) xs)
    in
    li [ class cssClass ]
        [ button [ class "exercise-btn", onClick (SelectExercise exercise.id) ]
            [ text label, getCompletion eval ]
        , childrenView
        ]


viewEvaluation : Evaluation -> Html FrontendMsg
viewEvaluation eval =
    div [ class "evaluation" ]
        [ table [ class "grades" ]
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


viewGradeRow : String -> Maybe Grade -> (Grade -> msg) -> Html msg
viewGradeRow label maybeGrade action =
    let
        currentGrade =
            maybeGrade
                |> Maybe.map gradeToString
                |> Maybe.withDefault ""
    in
    tr []
        [ td [ class "grade-label" ] [ text label ]
        , td [ class "grade-value" ] [ viewGradeControl maybeGrade action ]
        ]


viewGradeControl : Maybe Grade -> (Grade -> msg) -> Html msg
viewGradeControl maybeGrade action =
    div [ class "grade-control" ]
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
    span [ class getClass, onClick (action grade) ] [ text (gradeToControlString grade) ]


section : String -> String -> (String -> msg) -> Html msg
section title content action =
    div [ class "evaluation-section" ]
        [ h3 [] [ text title ]
        , textarea [ Attr.value content, onInput action ] []
        ]
