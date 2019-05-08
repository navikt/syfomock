module Felleskomponenter exposing (lagMockUrl, skjemaElement)

import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onInput)


skjemaElement : String -> String -> String -> (String -> msg) -> Html msg
skjemaElement inputLabel inputType inputValue toMsg =
    div [ class "skjemaelement skjemaelement__fullbredde" ]
        [ label [ class "skjemaelement__label" ] [ text inputLabel ]
        , input [ type_ inputType, value inputValue, onInput toMsg, class "skjemaelement__input input--fullbredde" ] []
        ]


lagMockUrl : String -> String
lagMockUrl utvidelse =
    String.append "https://syfomockproxy-q.nav.no" utvidelse
