# elm-interactive

This package let's you setup an interactive Elm application. It makes it easy to have the current time, mouse position, pressed keys and window size inside the model of your app. It is a thin wrapper around some native and community packages that provide you the necessary subscriptions, it saves you from dealing with some boilerplate to quickly get something interactive running.

You just have to add the following steps to your app:

## Import

```elm
import Interactive
```

## Connect Model

```elm

type alias Model =
    { interactive : Interactive.Model
    }
```

## Connect Init

```elm

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

```

## Connect Msg

```elm

type Msg
    = InteractiveMsg Interactive.Msg
```


## Connect Update


```elm

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
```

## Connect Subscriptions

```elm

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.map InteractiveMsg Interactive.subscriptions
```

This would subscribe to everything covered by this package. You can also have selective subscriptions. Check out the API for this.

