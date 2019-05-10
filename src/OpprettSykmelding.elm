module OpprettSykmelding exposing
    ( lagSykmeldingBestilling
    , opprettSykmeldingDefaulState
    , postNySykmelding
    , stringTilSykmeldingstype
    , sykmeldingBestillingEncoder
    , sykmeldingForm
    , sykmeldingsperiodeEncoder
    , sykmeldingstypeEncoder
    )

import Felleskomponenter exposing (alertStripeSuksess, lagMockUrl, skjemaElement)
import Html exposing (Html, button, div, form, label, option, select, span, text)
import Html.Attributes exposing (class, disabled, value)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (post)
import Json.Decode as Decode
import Json.Encode as Encode
import Model
    exposing
        ( Model
        , Msg(..)
        , OpprettSykmneldingModel
        , RequestStatus(..)
        , SykmeldingBestilling
        , SykmeldingPeriode
        , Sykmeldingstype(..)
        )


opprettSykmeldingDefaulState : OpprettSykmneldingModel
opprettSykmeldingDefaulState =
    { fnr = ""
    , periode =
        { startDato = ""
        , sluttDato = ""
        , sykmeldingstype = HUNDREPROSENT
        }
    , requestStatus = IKKE_STARTET
    , error = Nothing
    }


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
            , skjemaElement "Startdato" "date" model.opprettSykmelding.periode.startDato StartDato
            , skjemaElement "Sluttdato" "date" model.opprettSykmelding.periode.sluttDato SluttDato
            , velgSykmeldingstypeSkjemaElement
            ]
        , submitknapp
        , feilmelding
        ]


velgSykmeldingstypeSkjemaElement : Html Msg
velgSykmeldingstypeSkjemaElement =
    div [ class "skjemaelement skjemaelement__fullbredde" ]
        [ label [ class "skjemaelement__label" ] [ text "Sykmeldingstype" ]
        , select
            [ onInput PeriodeSykmeldingstype, class "skjemaelement__input input--fullbredde" ]
            (List.map sykmeldingstypeTilString [ HUNDREPROSENT, GRADERT_20 ])
        ]


sykmeldingstypeTilString : Sykmeldingstype -> Html Msg
sykmeldingstypeTilString sykmeldingstype =
    case sykmeldingstype of
        AVVENTENDE ->
            option [ value "Avventende" ] [ text "Avventende" ]

        GRADERT_20 ->
            option [ value "Gradert 20%" ] [ text "Gradert 20%" ]

        GRADERT_40 ->
            option [ value "Gradert 40%" ] [ text "Gradert 40%" ]

        GRADERT_50 ->
            option [ value "Gradert 50%" ] [ text "Gradert 50%" ]

        GRADERT_60 ->
            option [ value "Gradert 60%" ] [ text "Gradert 60%" ]

        GRADERT_80 ->
            option [ value "Gradert 80%" ] [ text "Gradert 80%" ]

        GRADERT_REISETILSKUDD ->
            option [ value "Gradert reisetilskudd" ] [ text "Gradert reisetilskudd" ]

        HUNDREPROSENT ->
            option [ value "Hundre prosent" ] [ text "Hundre prosent" ]

        BEHANDLINGSDAGER ->
            option [ value "Behandlingsdager" ] [ text "Behandlingsdager" ]

        BEHANDLINGSDAG ->
            option [ value "Behandlingsdag" ] [ text "Behandlingsdag" ]

        REISETILSKUDD ->
            option [ value "Reisetilskudd" ] [ text "Reisetilskudd" ]


stringTilSykmeldingstype : String -> Sykmeldingstype
stringTilSykmeldingstype sykmeldingstypeString =
    case sykmeldingstypeString of
        "Avventende" ->
            AVVENTENDE

        "Gradert 20%" ->
            GRADERT_20

        "Gradert 40%" ->
            GRADERT_40

        "Gradert 50%" ->
            GRADERT_50

        "Gradert 60%" ->
            GRADERT_60

        "Gradert 80%" ->
            GRADERT_80

        "Gradert reisetilskudd" ->
            GRADERT_REISETILSKUDD

        "Hundre prosent" ->
            HUNDREPROSENT

        "Behandlingsdager" ->
            BEHANDLINGSDAGER

        "Behandlingsdag" ->
            BEHANDLINGSDAG

        "Reisetilskudd" ->
            REISETILSKUDD

        _ ->
            HUNDREPROSENT


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
    let
        sykmelding =
            model.opprettSykmelding
    in
    { fnr = sykmelding.fnr
    , syketilfelleStartDato = sykmelding.periode.startDato
    , identdato = sykmelding.periode.startDato
    , utstedelsesdato = sykmelding.periode.startDato
    , smtype = "SM2013"
    , perioder =
        [ { fom = sykmelding.periode.startDato
          , tom = sykmelding.periode.sluttDato
          , sykmeldingstype = sykmelding.periode.sykmeldingstype
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


sykmeldingstypeEncoder : Sykmeldingstype -> Encode.Value
sykmeldingstypeEncoder smtype =
    case smtype of
        HUNDREPROSENT ->
            Encode.string "HUNDREPROSENT"

        AVVENTENDE ->
            Encode.string "AVVENTENDE"

        GRADERT_20 ->
            Encode.string "GRADERT_20"

        GRADERT_40 ->
            Encode.string "GRADERT_40"

        GRADERT_50 ->
            Encode.string "GRADERT_50"

        GRADERT_60 ->
            Encode.string "GRADERT_60"

        GRADERT_80 ->
            Encode.string "GRADERT_80"

        GRADERT_REISETILSKUDD ->
            Encode.string "GRADERT_REISETILSKUDD"

        BEHANDLINGSDAGER ->
            Encode.string "BEHANDLINGSDAGER"

        BEHANDLINGSDAG ->
            Encode.string "BEHANDLINGSDAG"

        REISETILSKUDD ->
            Encode.string "REISETILSKUDD"
