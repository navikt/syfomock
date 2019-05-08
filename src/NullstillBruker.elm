module NullstillBruker exposing (nullstillBruker, nullstillBrukerForm)

import Felleskomponenter exposing (lagMockUrl, skjemaElement)
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

        buttonBaseClasses =
            "knapp knapp--hoved"

        buttonClass =
            case requestStatus of
                STARTET ->
                    buttonBaseClasses ++ " knapp--spinner knapp--disabled"

                _ ->
                    buttonBaseClasses

        buttonDisabled =
            case requestStatus of
                STARTET ->
                    True

                _ ->
                    False

        knappinnhold =
            case requestStatus of
                STARTET ->
                    [ text "Nullstill bruker", span [ class "knapp__spinner" ] [] ]

                _ ->
                    [ text "Nullstill bruker" ]

        formClass =
            case requestStatus of
                FEILET ->
                    "skjema__feilomrade--harFeil"

                _ ->
                    "skjema__feilomrade"

        feilmelding =
            case requestStatus of
                FEILET ->
                    div [ class "skjemaelement__feilmelding" ] [ text "Kunne ikke nullstille bruker" ]

                _ ->
                    div [] []
    in
    form [ onSubmit SubmitNullstillBruker, class formClass ]
        [ div [ class "blokk-m" ]
            [ skjemaElement "Fødselsnummer" "text" model.nullstillBruker.fnr NullstillFnr ]
        , button [ class buttonClass, disabled buttonDisabled ] knappinnhold
        , feilmelding
        ]
