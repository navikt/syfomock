module OpprettSykmelding exposing (lagSykmeldingBestilling, postNySykmelding, sykmeldingBestillingEncoder, sykmeldingForm, sykmeldingsperiodeEncoder, sykmeldingstypeEncoder)

import Felleskomponenter exposing (alertStripeSuksess, lagMockUrl, skjemaElement)
import Html exposing (Html, button, div, form, span, text)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onSubmit)
import Http exposing (post)
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (Model, Msg(..), RequestStatus(..), Sykemeldingstype(..), SykmeldingBestilling, SykmeldingPeriode)


sykmeldingForm : Model -> Html Msg
sykmeldingForm model =
    let
        requestStatus =
            model.opprettSykmelding.requestStatus

        formClass =
            case requestStatus of
                FEILET ->
                    "skjema__feilomrade skjema__feilomrade--harFeil"

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
                        [ text "Opprett sykmelding"
                        , span [ class "knapp__spinner" ] []
                        ]

                _ ->
                    button [ class "knapp knapp--hoved" ] [ text "Opprett sykmelding" ]

        feilmelding =
            case requestStatus of
                FEILET ->
                    div [ class "skjemaelement__feilmelding" ] [ text "Kunne ikke opprette sykmelding" ]

                _ ->
                    div [] []
    in
    form [ onSubmit SubmitOpprettSykmelding, class formClass ]
        [ suksessmelding
        , div [ class "blokk-m" ]
            [ skjemaElement "Fødselsnummer" "text" model.opprettSykmelding.fnr Fnr
            , skjemaElement "Startdato" "date" model.opprettSykmelding.startDato StartDato
            , skjemaElement "Sluttdato" "date" model.opprettSykmelding.sluttDato SluttDato
            ]
        , submitknapp
        , feilmelding
        ]


postNySykmelding : SykmeldingBestilling -> Cmd Msg
postNySykmelding bestilling =
    let
        body =
            bestilling
                |> sykmeldingBestillingEncoder
                |> Http.jsonBody
    in
    post
        { url = lagMockUrl "/sykmelding"
        , body = body
        , expect = Http.expectJson SykmeldingSendt Decode.string
        }


lagSykmeldingBestilling : Model -> SykmeldingBestilling
lagSykmeldingBestilling model =
    { fnr = model.opprettSykmelding.fnr
    , syketilfelleStartDato = model.opprettSykmelding.startDato
    , identdato = model.opprettSykmelding.startDato
    , utstedelsesdato = model.opprettSykmelding.startDato
    , smtype = "SM2013"
    , perioder =
        [ { fom = model.opprettSykmelding.startDato
          , tom = model.opprettSykmelding.sluttDato
          , sykmeldingstype = HUNDREPROSENT
          }
        ]
    , manglendeTilrettelegging = False
    }


sykmeldingBestillingEncoder : SykmeldingBestilling -> Encode.Value
sykmeldingBestillingEncoder bestilling =
    Encode.object
        [ ( "fnr", Encode.string bestilling.fnr )
        , ( "syketilfelleStartDato", Encode.string bestilling.syketilfelleStartDato )
        , ( "identdato", Encode.string bestilling.identdato )
        , ( "utstedelsesdato", Encode.string bestilling.utstedelsesdato )
        , ( "smtype", Encode.string bestilling.smtype )
        , ( "perioder", Encode.list sykmeldingsperiodeEncoder bestilling.perioder )
        , ( "manglendeTilrettelegging", Encode.bool bestilling.manglendeTilrettelegging )
        ]


sykmeldingsperiodeEncoder : SykmeldingPeriode -> Encode.Value
sykmeldingsperiodeEncoder periode =
    Encode.object
        [ ( "fom", Encode.string periode.fom )
        , ( "tom", Encode.string periode.tom )
        , ( "type", sykmeldingstypeEncoder periode.sykmeldingstype )
        ]


sykmeldingstypeEncoder : Sykemeldingstype -> Encode.Value
sykmeldingstypeEncoder smtype =
    case smtype of
        _ ->
            Encode.string "HUNDREPROSENT"
