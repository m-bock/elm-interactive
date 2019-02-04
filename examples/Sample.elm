module Sample exposing (..)

import Html exposing (..)
import Interactive
import Keyboard.Extra as Keyboard


-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
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
            (case subMsg of
                Interactive.Mouse _ ->
                    ( { model | notification = "Mouse Event" }, Cmd.none )

                Interactive.KeyboardMsg subMsg ->
                    ( { model | notification = "Keyboard Event" }, Cmd.none )
                        |> Tuple.mapFirst
                            (\model ->
                                case Interactive.getKeys model.interactive of
                                    [ Keyboard.Control, Keyboard.CharC ] ->
                                        { model | notification = "" }

                                    _ ->
                                        model
                            )

                _ ->
                    ( model, Cmd.none )
            )
                |> Tuple.mapFirst
                    (\model ->
                        { model
                            | interactive =
                                Interactive.update subMsg model.interactive
                        }
                    )



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
                , td [] [ text <| toString interactive.time ]
                ]
            , tr []
                [ td [] [ text "Mouse" ]
                , td [] [ text <| toString interactive.mouse ]
                ]
            , tr []
                [ td [] [ text "KeysDown" ]
                , td [] [ text <| toString interactive.keysDown ]
                ]
            , tr []
                [ td [] [ text "WindowSize" ]
                , td [] [ text <| toString interactive.windowSize ]
                ]
            ]
        , text notification
        ]
