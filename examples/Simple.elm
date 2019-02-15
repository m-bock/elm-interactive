module Simple exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Html exposing (..)
import Interactive



-- MAIN


main : Program () Model Msg
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
    }


init : ( Model, Cmd Msg )
init =
    let
        ( subModel, subCmd ) =
            Interactive.init
    in
    ( { interactive = subModel
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
            ( { model
                | interactive =
                    Interactive.update subMsg model.interactive
                        |> Tuple.first
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.map InteractiveMsg Interactive.subscriptions



-- VIEW


view : Model -> Html Msg
view { interactive } =
    pre [] [ text (Debug.toString interactive) ]
