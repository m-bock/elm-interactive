module Interactive exposing (Model, Msg, OutMsg(..), init, subKeyboard, subMouse, subTick, subWindowResize, subscriptions, update)

import Browser.Dom exposing (getViewport)
import Browser.Events exposing (onAnimationFrame, onMouseMove, onResize)
import Html.Events.Extra.Mouse as Mouse
import Json.Decode as Decode
import Keyboard
import Task exposing (Task)
import Time



-- MODEL


{-| -}
type alias Model =
    { time : Float
    , mouse : ( Float, Float )
    , keysDown : List Keyboard.Key
    , windowSize : ( Float, Float )
    }


{-| -}
init : ( Model, Cmd Msg )
init =
    ( { time = 0
      , mouse = ( 0, 0 )
      , keysDown = []
      , windowSize = ( 0, 0 )
      }
    , Cmd.batch
        [ Task.perform WindowResize getWindowSize
        ]
    )


getWindowSize : Task x ( Float, Float )
getWindowSize =
    getViewport
        |> Task.map (\{ viewport } -> ( viewport.width, viewport.height ))



-- UPDATE


{-| -}
type Msg
    = Tick Float
    | Mouse ( Float, Float )
    | KeyboardMsg Keyboard.Msg
    | WindowResize ( Float, Float )


type OutMsg
    = OutTick Float
    | OutMouse ( Float, Float )
    | OutKeyChange Keyboard.KeyChange
    | OutWindowResize ( Float, Float )


{-| -}
update : Msg -> Model -> ( Model, Maybe OutMsg )
update msg model =
    case msg of
        Tick time ->
            ( { model | time = time }, Just <| OutTick time )

        Mouse mouse ->
            ( { model | mouse = mouse }, Just <| OutMouse mouse )

        KeyboardMsg subMsg ->
            Keyboard.updateWithKeyChange Keyboard.anyKeyOriginal subMsg model.keysDown
                |> Tuple.mapFirst (\subModel -> { model | keysDown = List.reverse subModel })
                |> Tuple.mapSecond (Maybe.map OutKeyChange)

        WindowResize windowSize ->
            ( { model | windowSize = windowSize }, Just <| OutWindowResize windowSize )



-- SUBSCRIPTIONS


{-| -}
subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ subTick
        , subMouse
        , subKeyboard
        , subWindowResize
        ]


{-| -}
subTick : Sub Msg
subTick =
    onAnimationFrame (Time.posixToMillis >> toFloat >> Tick)


{-| -}
subMouse : Sub Msg
subMouse =
    Mouse.eventDecoder
        |> Decode.map (Mouse << .clientPos)
        |> onMouseMove


{-| -}
subKeyboard : Sub Msg
subKeyboard =
    Sub.map KeyboardMsg Keyboard.subscriptions


{-| -}
subWindowResize : Sub Msg
subWindowResize =
    onResize (\x y -> WindowResize ( toFloat x, toFloat y ))
