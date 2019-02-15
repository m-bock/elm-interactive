module Advanced exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Html exposing (Html)
import Interactive
import Keyboard
import Svg exposing (..)
import Svg.Attributes exposing (..)



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
    , posRect : Float
    , veloRect : Float
    }


init : ( Model, Cmd Msg )
init =
    let
        ( subModel, subCmd ) =
            Interactive.init
    in
    ( { interactive = subModel
      , posRect = 0.5
      , veloRect = 0
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
        Just (Interactive.OutTick tick) ->
            ( { model | posRect = model.posRect + model.veloRect }, Cmd.none )

        Just (Interactive.OutKeyChange subMsg) ->
            ( model, Cmd.none )
                |> batch (evalKeyChange subMsg model)

        _ ->
            ( model, Cmd.none )


evalKeyChange : Keyboard.KeyChange -> Model -> ( Model, Cmd Msg )
evalKeyChange msg model =
    let
        speed =
            0.005
    in
    case msg of
        Keyboard.KeyDown Keyboard.ArrowLeft ->
            ( { model | veloRect = -speed }, Cmd.none )

        Keyboard.KeyUp Keyboard.ArrowLeft ->
            ( { model | veloRect = 0 }, Cmd.none )

        Keyboard.KeyDown Keyboard.ArrowRight ->
            ( { model | veloRect = speed }, Cmd.none )

        Keyboard.KeyUp Keyboard.ArrowRight ->
            ( { model | veloRect = 0 }, Cmd.none )

        _ ->
            ( model, Cmd.none )


batch : ( Model, Cmd Msg ) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
batch ( model, cmd1 ) ( _, cmd2 ) =
    ( model, Cmd.batch [ cmd1, cmd2 ] )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.map InteractiveMsg Interactive.subscriptions



-- VIEW


view : Model -> Html Msg
view { interactive, posRect } =
    let
        styleSvg =
            "margin: 0px; position: fixed; top: 0px; left: 0px"

        ( winWidth, winHeight ) =
            interactive.windowSize

        ( mouseX, mouseY ) =
            interactive.mouse

        radius1 =
            sin (interactive.time / 1000)
                |> (\x -> (x + 1) / 2)
                |> (*) 30
                |> (+) 10

        rectX =
            posRect * winWidth - 50

        rectY =
            winHeight / 2 - 50
    in
    svg
        [ width <| String.fromFloat winWidth
        , height <| String.fromFloat winHeight
        , Svg.Attributes.style styleSvg
        ]
        [ rect
            [ x <| String.fromFloat rectX
            , y <| String.fromFloat rectY
            , width "100"
            , height "100"
            , Svg.Attributes.style "fill:rgba(0,0,0,0.5)"
            ]
            []
        , line
            [ x1 <| String.fromFloat mouseX
            , y1 <| String.fromFloat mouseY
            , x2 <| String.fromFloat (rectX + 50)
            , y2 <| String.fromFloat (rectY + 50)
            , Svg.Attributes.style "stroke:rgb(255,0,0);stroke-width:2"
            ]
            []
        , circle
            [ cx <| String.fromFloat mouseX
            , cy <| String.fromFloat mouseY
            , r <| String.fromFloat radius1
            , Svg.Attributes.style "fill:rgba(3, 67, 9, 0.5)"
            ]
            []
        ]
