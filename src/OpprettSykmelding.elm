module OpprettSykmelding exposing (lagSykmeldingBestilling, postNySykmelding, sykmeldingBestillingEncoder, sykmeldingForm, sykmeldingsperiodeEncoder, sykmeldingstypeEncoder)

import Felleskomponenter exposing (skjemaElement)
import Html exposing (Html, button, div, form, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onSubmit)
import Http exposing (post)
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (Model, Msg(..), Sykemeldingstype(..), SykmeldingBestilling, SykmeldingPeriode)


sykmeldingForm : Model -> Html Msg
sykmeldingForm model =
    form [ onSubmit SubmitOpprettSykmelding ]
        [ div [ class "blokk-m" ]
            [ skjemaElement "Fødselsnummer" "text" model.opprettSykmelding.fnr Fnr
            , skjemaElement "Startdato" "date" model.opprettSykmelding.startDato StartDato
            , skjemaElement "Sluttdato" "date" model.opprettSykmelding.sluttDato SluttDato
            ]
        , button [ class "knapp knapp--hoved" ] [ text "Opprett sykmelding" ]
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
        { url = "https://httpbin.org/post"
        , body = body
        , expect = Http.expectJson SykmeldingSendt (Decode.list Decode.string)
        }


lagSykmeldingBestilling : Model -> SykmeldingBestilling
lagSykmeldingBestilling model =
    { fnr = model.opprettSykmelding.fnr
    , syketilfelleStartDato = model.opprettSykmelding.startDato
    , identdato = model.opprettSykmelding.startDato
    , utstedelsesdato = model.opprettSykmelding.startDato
    , smtype = "HUNDEREPROSENT"
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
