module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text, select, option)
import Html.Events exposing (onClick, onInput)
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
  ( { currencies = []
    , from = "USD"
    , to = "USD"
    , result = "1"
    }
  , getCurrencies
  )


-- MODEL


type alias Model =
  { currencies : List String
  , from : String
  , to : String
  , result : String
  }


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


convertFromTo : String -> String -> Cmd Msg
convertFromTo from to =
  Http.get
    { url = "http://localhost:4567/" ++ from ++ "/to/" ++ to
    , expect = Http.expectJson GotConversion convertDecoder
    }


convertDecoder : Decoder String
convertDecoder =
  field "result" string


-- UPDATE


type Msg
  = GotCurrencies (Result Http.Error (List String))
  | ChangeFrom String
  | ChangeTo String
  | Convert
  | GotConversion (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotCurrencies result ->
      case result of
        Ok currencies ->
          ({ model | currencies = currencies }, Cmd.none)

        Err _ ->
          (model, Cmd.none)

    ChangeFrom from ->
      ({ model | from = from }, Cmd.none)

    ChangeTo to ->
      ({ model | to = to }, Cmd.none)

    Convert ->
      (model, convertFromTo model.from model.to)

    GotConversion result ->
      case result of
        Ok value ->
          ({ model | result = value }, Cmd.none)

        Err _ ->
          (model, Cmd.none)


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
  let options = getOptions model.currencies in
  div [] [
      select [ onInput ChangeFrom ] options
    , select [ onInput ChangeTo ] options
    , button [ onClick Convert ] [ text "Convert" ]
    , text model.result
  ]
