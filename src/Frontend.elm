module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import ExerciseList
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Grade exposing (..)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Html.Events as Evts exposing (onClick, onInput, onMouseOver)
import Json.Decode as Decode
import Lamdera
import List.Extra
import Set exposing (Set)
import Task
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


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , selected = Nothing
      , expanded = Set.fromList []
      , user = Nothing
      , pass = ""
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

        LoadFile ->
            ( model, Select.file [ "application/json" ] FileSelected )

        FileSelected file ->
            ( model, Task.perform FileLoaded (File.toString file) )

        FileLoaded content ->
            ( model, Lamdera.sendToBackend <| UploadData content )

        StartDownload ->
            ( model, Lamdera.sendToBackend GetJsonString )

        UpdatePass str ->
            ( { model | pass = str }, Cmd.none )

        Login ->
            ( model, Lamdera.sendToBackend <| LoggedOn model.pass )

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
            updateSelectedEvaluation model (\a -> { a | clarity = Just grade })

        SetUsefulness grade ->
            updateSelectedEvaluation model (\a -> { a | usefulness = Just grade })

        SetFun grade ->
            updateSelectedEvaluation model (\a -> { a | fun = Just grade })

        EditTheGood str ->
            updateSelectedEvaluation model (\a -> { a | theGood = str })

        EditTheBad str ->
            updateSelectedEvaluation model (\a -> { a | theBad = str })

        EditTheUgly str ->
            updateSelectedEvaluation model (\a -> { a | theUgly = str })


updateSelectedEvaluation : Model -> (Evaluation -> Evaluation) -> ( Model, Cmd FrontendMsg )
updateSelectedEvaluation model func =
    let
        id =
            model.selected |> Maybe.map .id |> Maybe.withDefault 0

        name =
            model.user
                |> Maybe.map .name
                |> Maybe.withDefault ""

        evaluations =
            model.user
                |> Maybe.map (\a -> a.evaluations)
                |> Maybe.map
                    (Dict.map
                        (\k v ->
                            if k == id then
                                func v

                            else
                                v
                        )
                    )
                |> Maybe.withDefault Dict.empty

        evaluation =
            evaluations
                |> Dict.get id
                |> Maybe.withDefault emptyEvaluation

        user =
            model.user |> Maybe.map (\a -> { a | evaluations = evaluations })
    in
    ( { model | user = user }, Lamdera.sendToBackend <| SaveEvaluation name id evaluation )


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

        GotUser user ->
            ( { model | user = user }, Cmd.none )

        Download jsonString ->
            ( model
            , Download.string "course-evaluations.json" "application/json;charset=utf-8" jsonString
            )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "sedarg"
    , body = [ mainView model ]
    }


mainView : Model -> Html FrontendMsg
mainView model =
    case model.user of
        Just user ->
            authenticatedView model user

        Nothing ->
            loginView model


loginView : Model -> Html FrontendMsg
loginView model =
    Html.div [ Attr.class "center-card" ]
        [ Html.div [ Attr.class "login-card" ]
            [ Html.input [ Attr.value model.pass, Evts.onInput UpdatePass, onEnter Login ] []
            , Html.button [ Evts.onClick Login ] [ Html.text "Enter" ]
            ]
        ]


authenticatedView : Model -> User -> Html FrontendMsg
authenticatedView model user =
    if user.name == "Coach" then
        div []
            [ h3 [] [ text user.name ]
            , Html.button [ onClick StartDownload ] [ text "▼" ]
            , Html.button [ onClick LoadFile ] [ text "▲" ]
            ]

    else
        div [ class "layout" ]
            [ div [ class "master" ]
                [ h3 [] [ text user.name ]
                , viewExercisesSelectable user.evaluations ExerciseList.all model.selected
                ]
            , div [ class "detail" ]
                [ case model.selected of
                    Just ex ->
                        case Dict.get ex.id user.evaluations of
                            Just eval ->
                                let
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
                                Html.text "Problem: evaluation not found."

                    Nothing ->
                        div [ class "placeholder" ]
                            [ text "Select an exercise to view its evaluation." ]
                ]
            ]


summaryView : Model -> Html FrontendMsg
summaryView model =
    h3 [] [ text "Summary" ]


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

        commented str =
            let
                completeLabel =
                    if String.isEmpty str then
                        "_"

                    else
                        "✓"
            in
            span [] [ span [ class "comment" ] [ text completeLabel ] ]

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
                    ul [ class "exercises" ]
                        (List.map (viewItem evaluations selected) xs)
    in
    case Dict.get exercise.id evaluations of
        Just eval ->
            li [ class cssClass ]
                [ button [ class "exercise-btn", onClick (SelectExercise exercise.id) ]
                    [ text label, getCompletion eval ]
                , childrenView
                ]

        Nothing ->
            Html.text "Problem: evaluation not found."


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


onEnter : msg -> Html.Attribute msg
onEnter msg =
    let
        isEnter key =
            if key == "Enter" then
                Decode.succeed msg

            else
                Decode.fail "Not Enter"
    in
    Evts.on "keydown" (Decode.field "key" Decode.string |> Decode.andThen isEnter)
