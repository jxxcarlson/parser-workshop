port module Main exposing (main)

import M1.Parse as Parse
import M1.Render as Render
import Platform exposing (Program)


type alias InputType =
    String


type alias OutputType =
    String


port get : (InputType -> msg) -> Sub msg


port put : OutputType -> Cmd msg


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    ()


type Msg
    = Input String


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            ( model, put (transform input) )


subscriptions : Model -> Sub Msg
subscriptions _ =
    get Input


transform : InputType -> InputType
transform inp =
    Parse.parseDocument inp |> Debug.toString
