port module Main2 exposing (main)

import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import Json.Decode as D
import Json.Encode as E
import M1.Parse as Parse
import M1.Render as Render
import Platform exposing (Program)


type alias InputType =
    String


type alias OutputType =
    String


port get : (InputType -> msg) -> Sub msg


port put : OutputType -> Cmd msg


port sendFileName : E.Value -> Cmd msg


port receiveData : (E.Value -> msg) -> Sub msg


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { fileContents : Maybe String }


type Msg
    = Input String
    | ReceivedDataFromJS E.Value


type alias Flags =
    ()


init : () -> ( Model, Cmd Msg )
init _ =
    { fileContents = Just example } |> withNoCmd


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ get Input, receiveData ReceivedDataFromJS ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            let
                _ =
                    Debug.log "INPUT" input
            in
            case input == "" of
                True ->
                    model |> withNoCmd

                False ->
                    commandProcessor model input

        ReceivedDataFromJS value ->
            case decodeFileContents value of
                Nothing ->
                    model |> withCmd (put "Couldn't load file")

                Just data ->
                    { model | fileContents = Just data } |> withCmd (put "File contents stored")


commandProcessor : Model -> String -> ( Model, Cmd Msg )
commandProcessor model cmdString =
    let
        _ =
            Debug.log "cmdString" cmdString

        args =
            String.split " " cmdString
                |> List.map String.trim
                |> List.filter (\item -> item /= "")
                |> Debug.log "ARGS"

        cmd =
            List.head args |> Debug.log "cmd"

        arg =
            List.head (List.drop 1 args) |> Debug.log "arg"
    in
    case ( cmd, arg ) of
        ( Just "get", Just fileName ) ->
            loadFile model fileName

        ( Just "p", _ ) ->
            case model.fileContents of
                Nothing ->
                    model |> withCmd (put "No file contents to process")

                Just contents ->
                    model |> withCmd (put (Parse.parseDocument contents |> Debug.toString))

        ( Just "r", _ ) ->
            case model.fileContents of
                Nothing ->
                    model |> withCmd (put "No file contents to process")

                Just contents ->
                    model |> withCmd (put (Render.renderDocument contents))

        ( _, _ ) ->
            model |> withCmd (put "Something weird happened")


transform : InputType -> InputType
transform inp =
    Parse.parseDocument inp
        |> Debug.toString


loadFile model fileName =
    ( model, loadFileCmd fileName )


loadFileCmd : String -> Cmd msg
loadFileCmd filePath =
    sendFileName (E.string <| filePath)


decodeFileContents : E.Value -> Maybe String
decodeFileContents value =
    case D.decodeValue D.string value of
        Ok str ->
            Just str

        Err _ ->
            Nothing


example =
    """|h Intro
             
             Trying out a new
             language here
             
             |s Basics
             
             There are three elements:
             headings, subheadings, and
             paragraphs.
             
             
"""
