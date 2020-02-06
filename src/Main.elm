module Main exposing (main)
import Browser
import Html exposing (Html, button, div, text, select, option)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, list, string)


-- MAIN


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , getCurrencies
  )


-- MODEL


type Model
  = Failure
  | Loading
  | Success (List String)


-- HTTP


getCurrencies : Cmd Msg
getCurrencies =
  Http.get
    { url = "http://localhost:4567/currencies"
    , expect = Http.expectJson GotCurrencies currenciesDecoder
    }


currenciesDecoder : Decoder (List String)
currenciesDecoder =
  field "currencies" (list string)


-- UPDATE


type Msg
  = GotCurrencies (Result Http.Error (List String))


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotCurrencies result ->
      case result of
        Ok currencies ->
          (Success currencies, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)

-- clickMe msg = 


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none


-- VIEW


getOptions : List String -> List (Html msg)
getOptions currencies =
  List.map (\currency -> option [] [ text currency ]) currencies


view : Model -> Html Msg
view model =
  case model of
    Failure ->
      text "Error"

    Loading ->
      text "Loading..."

    Success currencies ->
      let options = getOptions currencies in
      div []
        [
          select [] options
        , select [] options
        , text "fx"
        ]
