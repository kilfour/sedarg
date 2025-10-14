module UIUtils exposing (onEnter)

import Html
import Html.Events as Evts
import Json.Decode


onEnter : msg -> Html.Attribute msg
onEnter msg =
    let
        isEnter key =
            if key == "Enter" then
                Json.Decode.succeed msg

            else
                Json.Decode.fail "Not Enter"
    in
    Evts.on "keydown" (Json.Decode.field "key" Json.Decode.string |> Json.Decode.andThen isEnter)
