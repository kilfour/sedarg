module Backend exposing (..)

import Dict exposing (Dict)
import Json.Decode
import Json.Encode
import Lamdera exposing (ClientId, SessionId)
import List.Extra
import Serialize exposing (decodeUsers, encodeUsers)
import Types exposing (..)
import Users


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { users = Users.list }, Cmd.none )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        LoggedOn pass ->
            let
                user =
                    model.users
                        |> List.filter (\a -> a.pass == pass)
                        |> List.head
            in
            ( model
            , Lamdera.sendToFrontend clientId <| GotUser user
            )

        SaveEvaluation name id evaluation ->
            case List.Extra.find (\u -> u.name == name) model.users of
                Just user ->
                    let
                        newEvals =
                            if Dict.member id user.evaluations then
                                Dict.insert id evaluation user.evaluations

                            else
                                user.evaluations

                        newUsers =
                            List.Extra.updateIf
                                (\a -> a.name == name)
                                (\a -> { a | evaluations = newEvals })
                                model.users
                    in
                    ( { model | users = newUsers }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        GetJsonString ->
            let
                jsonString =
                    Json.Encode.encode 2 (encodeUsers model.users)
            in
            ( model, Lamdera.sendToFrontend clientId <| Download jsonString )

        UploadData jsonString ->
            case Json.Decode.decodeString decodeUsers jsonString of
                Ok users ->
                    ( { model | users = users }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )
