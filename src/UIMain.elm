module UIMain exposing (view)

import Dict exposing (Dict)
import ExerciseList
import Grade
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Evts
import Types exposing (..)
import UIEvaluation
import UIExerciseList
import UIUtils


type alias Model =
    FrontendModel


view : Model -> Html FrontendMsg
view model =
    case model.user of
        Just user ->
            authenticatedView model user

        Nothing ->
            loginView model


loginView : Model -> Html FrontendMsg
loginView model =
    Html.div [ Attr.class "center-card" ]
        [ Html.div [ Attr.class "login-card" ]
            [ Html.input [ Attr.value model.pass, Evts.onInput UpdatePass, UIUtils.onEnter Login ] []
            , Html.button [ Evts.onClick Login ] [ Html.text "Enter" ]
            ]
        ]


authenticatedView : Model -> User -> Html FrontendMsg
authenticatedView model user =
    if user.name == "Coach" then
        div []
            [ h3 [] [ text user.name ]
            , Html.button [ Evts.onClick StartDownload ] [ text "▼" ]
            , Html.button [ Evts.onClick LoadFile ] [ text "▲" ]
            ]

    else
        div [ Attr.class "layout" ]
            [ div [ Attr.class "master" ]
                [ h3 [] [ text user.name ]
                , UIExerciseList.view user.evaluations ExerciseList.all model.selected
                ]
            , div [ Attr.class "detail" ] [ UIEvaluation.view model user ]
            ]
