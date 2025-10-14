module Backend exposing (..)

import Dict exposing (Dict)
import Json.Decode
import Json.Encode
import Lamdera exposing (ClientId, SessionId)
import Serialize exposing (decodeUsers, encodeUsers)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    let
        buildEvaluations =
            List.range 1 61
                |> List.map (\a -> ( a, emptyEvaluation ))
                |> Dict.fromList
    in
    ( { users =
            [ { name = "Abigail"
              , pass = "creative-in-pink"
              , evaluations = buildEvaluations
              }
            , { name = "Alex"
              , pass = "tenacious-poker"
              , evaluations = buildEvaluations
              }
            , { name = "Mathias"
              , pass = "inquisitive-sigh"
              , evaluations = buildEvaluations
              }
            , { name = "Michael"
              , pass = "yes-no-cava"
              , evaluations = buildEvaluations
              }
            , { name = "Naomi"
              , pass = "footless-structure"
              , evaluations = buildEvaluations
              }
            , { name = "Demo"
              , pass = "demo"
              , evaluations = buildEvaluations
              }
            , { name = "Coach"
              , pass = "elmsy"
              , evaluations = Dict.empty
              }
            ]
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
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
            let
                maybeUser =
                    model.users
                        |> List.filter (\a -> a.name == name)
                        |> List.head

                evaluations =
                    maybeUser
                        |> Maybe.map .evaluations
                        |> Maybe.map
                            (Dict.map
                                (\k v ->
                                    if k == id then
                                        evaluation

                                    else
                                        v
                                )
                            )
                        |> Maybe.withDefault Dict.empty

                users =
                    model.users
                        |> List.map
                            (\a ->
                                if a.name == name then
                                    { a | evaluations = evaluations }

                                else
                                    a
                            )
            in
            ( { model | users = users }, Cmd.none )

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
