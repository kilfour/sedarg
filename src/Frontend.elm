module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import ExerciseList
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Lamdera
import List.Extra
import Task
import Types exposing (..)
import UIMain
import Url


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


init : Url.Url -> Nav.Key -> ( FrontendModel, Cmd FrontendMsg )
init url key =
    ( { key = key
      , selected = Nothing
      , user = Nothing
      , pass = ""
      }
    , Cmd.none
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    let
        updateSelectedEvaluation updateEval =
            case ( model.selected, model.user ) of
                ( Just selected, Just user ) ->
                    let
                        id =
                            selected.id

                        name =
                            user.name

                        evaluations =
                            Dict.update id (Maybe.map updateEval) user.evaluations

                        newUser =
                            { user | evaluations = evaluations }

                        evaluation =
                            Dict.get id evaluations
                                |> Maybe.withDefault emptyEvaluation
                    in
                    ( { model | user = Just newUser }
                    , Lamdera.sendToBackend <| SaveEvaluation name id evaluation
                    )

                _ ->
                    ( model, Cmd.none )
    in
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
            ( { model | selected = Dict.get id ExerciseList.index }, Cmd.none )

        SetClarity grade ->
            updateSelectedEvaluation (\a -> { a | clarity = Just grade })

        SetUsefulness grade ->
            updateSelectedEvaluation (\a -> { a | usefulness = Just grade })

        SetFun grade ->
            updateSelectedEvaluation (\a -> { a | fun = Just grade })

        EditTheGood str ->
            updateSelectedEvaluation (\a -> { a | theGood = str })

        EditTheBad str ->
            updateSelectedEvaluation (\a -> { a | theBad = str })

        EditTheUgly str ->
            updateSelectedEvaluation (\a -> { a | theUgly = str })


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
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


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "sedarg"
    , body = [ UIMain.view model ]
    }
