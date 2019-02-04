module Interactive
    exposing
        ( Model
        , Msg(..)
        , getKeys
        , init
        , subKeyboard
        , subMouse
        , subTick
        , subWindowResize
        , subscriptions
        , update
        )

{-|

@docs Model, getKeys, init, subscriptions, update, Msg, subMouse, subTick, subKeyboard, subWindowResize

-}

import AnimationFrame exposing (..)
import Keyboard.Extra as Keyboard exposing (Key(..))
import Mouse exposing (..)
import Set
import Task
import Time exposing (Time)
import Window


-- MODEL


{-| -}
type alias Model =
    { time : Time
    , mouse : Mouse.Position
    , keysDown : Keyboard.Model
    , windowSize : Window.Size
    }


{-| -}
init : ( Model, Cmd Msg )
init =
    ( { time = 0
      , mouse = { x = 0, y = 0 }
      , keysDown = Keyboard.init
      , windowSize = { width = 0, height = 0 }
      }
    , Cmd.batch
        [ Task.perform WindowResize Window.size
        ]
    )



-- UPDATE


{-| -}
type Msg
    = Tick Float
    | Mouse Position
    | KeyboardMsg Keyboard.Msg
    | WindowResize Window.Size


{-| -}
update : Msg -> Model -> Model
update msg model =
    case msg of
        Tick time ->
            { model | time = time }

        Mouse position ->
            { model | mouse = position }

        KeyboardMsg subMsg ->
            { model | keysDown = Keyboard.update subMsg model.keysDown }

        WindowResize windowSize ->
            { model | windowSize = windowSize }



-- SELECTORS


{-| -}
getKeys : Model -> List Key
getKeys { keysDown } =
    keysDown
        |> Set.toList
        |> List.map Keyboard.fromCode



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
    times Tick


{-| -}
subMouse : Sub Msg
subMouse =
    moves Mouse


{-| -}
subKeyboard : Sub Msg
subKeyboard =
    Sub.map KeyboardMsg Keyboard.subscriptions


{-| -}
subWindowResize : Sub Msg
subWindowResize =
    Window.resizes WindowResize
