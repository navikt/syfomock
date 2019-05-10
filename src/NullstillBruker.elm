module NullstillBruker exposing (nullstillBruker, nullstillBrukerForm)

import Felleskomponenter exposing (alertStripeSuksess, lagMockUrl, skjemaElement)
import Html exposing (Html, button, div, form, span, text)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onSubmit)
import Http exposing (post)
import Json.Decode as Decode
import Model exposing (Model, Msg(..), RequestStatus(..))


nullstillBruker : String -> Cmd Msg
nullstillBruker fnr =
    post
        { url = lagMockUrl "/person/" ++ fnr ++ "/nullstill"
        , body = Http.emptyBody
        , expect = Http.expectJson BrukerNullstillt Decode.string
        }


nullstillBrukerForm : Model -> Html Msg
nullstillBrukerForm model =
    let
        requestStatus =
            model.nullstillBruker.requestStatus

        formClass =
            case requestStatus of
                FEILET ->
                    "skjema__feilomrade--harFeil"

                _ ->
                    "skjema__feilomrade"

        suksessmelding =
            case requestStatus of
                OK ->
                    alertStripeSuksess "Bruker nullstillt"

                _ ->
                    div [] []

        submitknapp =
            case requestStatus of
                STARTET ->
                    button
                        [ class "knapp knapp--hoved knapp--spinner knapp--disabled", disabled True ]
                        [ text "Nullstill bruker"
                        , span [ class "knapp__spinner" ] []
                        ]

                _ ->
                    button [ class "knapp knapp--hoved" ] [ text "Nullstill bruker" ]

        feilmelding =
            case requestStatus of
                FEILET ->
                    div [ class "skjemaelement__feilmelding" ] [ text "Kunne ikke nullstille bruker" ]

                _ ->
                    div [] []
    in
    form [ onSubmit SubmitNullstillBruker, class formClass ]
        [ suksessmelding
        , div [ class "blokk-m" ]
            [ skjemaElement "Fødselsnummer" "text" model.nullstillBruker.fnr NullstillFnr ]
        , submitknapp
        , feilmelding
        ]
