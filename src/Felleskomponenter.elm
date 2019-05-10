port module Felleskomponenter exposing (alertStripeSuksess, lagMockUrl, skjemaElement)

import Html exposing (Html, div, input, label, p, span, text)
import Html.Attributes exposing (class, kind, type_, value)
import Html.Events exposing (onInput)
import Svg exposing (Svg, g, svg)
import Svg.Attributes exposing (d, fill, fillRule, height, viewBox, width)


skjemaElement : String -> String -> String -> (String -> msg) -> Html msg
skjemaElement inputLabel inputType inputValue toMsg =
    div [ class "skjemaelement skjemaelement__fullbredde" ]
        [ label [ class "skjemaelement__label" ] [ text inputLabel ]
        , input [ type_ inputType, value inputValue, onInput toMsg, class "skjemaelement__input input--fullbredde" ] []
        ]


lagMockUrl : String -> String
lagMockUrl utvidelse =
    String.append "https://syfomockproxy-q.nav.no" utvidelse


alertStripeSuksess : String -> Html msg
alertStripeSuksess tekst =
    div
        [ class "alertstripe alertstripe--suksess blokk-s" ]
        [ span [ class "alertstripe__ikon" ] [ okSirkelFyll ]
        , p [ class "typo-normal alertstripe__tekst" ] [ text tekst ]
        ]


okSirkelFyll : Svg msg
okSirkelFyll =
    svg [ kind "ok-sirkel-fyll", height "1.5em", width "1.5em", viewBox "0 0 24 24" ] [ g [ fillRule "nonzero", fill "none" ] [ Svg.path [ d "M12 0C5.383 0 0 5.384 0 12s5.383 12 12 12c6.616 0 12-5.384 12-12S18.616 0 12 0z", fill "#1C6937" ] [], Svg.path [ d "M9.64 14.441l6.46-5.839a.997.997 0 0 1 1.376.044.923.923 0 0 1-.046 1.334l-7.15 6.464a.993.993 0 0 1-.662.252.992.992 0 0 1-.69-.276l-2.382-2.308a.923.923 0 0 1 0-1.334.997.997 0 0 1 1.377 0l1.717 1.663z", fill "#FFF" ] [] ] ]
