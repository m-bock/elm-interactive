module Sample exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Html exposing (..)
import Interactive
import Keyboard



-- MAIN


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.element
        { init = \_ -> init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { interactive : Interactive.Model
    , notification : String
    }


init : ( Model, Cmd Msg )
init =
    let
        ( subModel, subCmd ) =
            Interactive.init
    in
    ( { interactive = subModel
      , notification = ""
      }
    , Cmd.map InteractiveMsg subCmd
    )



-- UPDATE


type Msg
    = InteractiveMsg Interactive.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InteractiveMsg subMsg ->
            Interactive.update subMsg model.interactive
                |> Tuple.mapFirst (\subModel -> { model | interactive = subModel })
                |> evalInteractive


evalInteractive : ( Model, Maybe Interactive.OutMsg ) -> ( Model, Cmd Msg )
evalInteractive ( model, maybeOutMsg ) =
    case maybeOutMsg of
        Just (Interactive.OutMouse _) ->
            ( { model | notification = "Mouse Event" }, Cmd.none )

        Just (Interactive.OutKeyChange subMsg) ->
            ( { model | notification = "Keyboard Event" }, Cmd.none )
                |> batch (evalKeyChange subMsg model)

        _ ->
            ( model, Cmd.none )


evalKeyChange : Keyboard.KeyChange -> Model -> ( Model, Cmd Msg )
evalKeyChange msg model =
    case ( msg, model.interactive.keysDown ) of
        ( Keyboard.KeyDown _, [ Keyboard.Control, Keyboard.Character "c" ] ) ->
            ( { model | notification = "" }, Cmd.none )

        _ ->
            ( model, Cmd.none )


batch : ( Model, Cmd Msg ) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
batch ( _, cmd1 ) ( model, cmd2 ) =
    ( model, Cmd.batch [ cmd1, cmd2 ] )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.map InteractiveMsg Interactive.subscriptions



-- VIEW


view : Model -> Html Msg
view { interactive, notification } =
    div []
        [ table []
            [ tr []
                [ td [] [ text "Time" ]
                , td [] [ text <| Debug.toString interactive.time ]
                ]
            , tr []
                [ td [] [ text "Mouse" ]
                , td [] [ text <| Debug.toString interactive.mouse ]
                ]
            , tr []
                [ td [] [ text "KeysDown" ]
                , td [] [ text <| Debug.toString interactive.keysDown ]
                ]
            , tr []
                [ td [] [ text "WindowSize" ]
                , td [] [ text <| Debug.toString interactive.windowSize ]
                ]
            ]
        , text notification
        ]
