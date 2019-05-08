module Main exposing (main)

import Api exposing (nullstillBruker)
import Browser
import Browser.Navigation as Nav
import Felleskomponenter exposing (skjemaElement)
import Html exposing (..)
import Html.Attributes exposing (class, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (post)
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (..)
import NullstillBruker exposing (nullstillBruker, nullstillBrukerForm)
import Url exposing (Url)



-- MODEL


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    ( { fnr = ""
      , startDato = ""
      , sluttDato = ""
      , nullstillBruker =
            { fnr = ""
            , requestStatus = IKKE_STARTET
            , error = Nothing
            }
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Syfomock"
    , body =
        [ h1 [ class "header typo-sidetittel blokk-l" ] [ text "Syfomock" ]
        , div [ class "skjema" ]
            [ h2 [ class "blokk-m typo-innholdstittel" ] [ text "Opprett sykmelding" ]
            , sykmeldingForm model
            , h2 [ class "blokk-m typo-innholdstittel" ] [ text "Nullstill bruker" ]
            , nullstillBrukerForm model
            ]
        ]
    }


sykmeldingForm : Model -> Html Msg
sykmeldingForm model =
    form [ onSubmit SubmitOpprettSykmelding ]
        [ div [ class "blokk-m" ]
            [ skjemaElement "Fødselsnummer" "text" model.fnr Fnr
            , skjemaElement "Startdato" "date" model.startDato StartDato
            , skjemaElement "Sluttdato" "date" model.sluttDato SluttDato
            ]
        , button [ class "knapp knapp--hoved" ] [ text "Opprett sykmelding" ]
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fnr fnr ->
            ( { model | fnr = fnr }, Cmd.none )

        NullstillFnr fnr ->
            ( { model
                | nullstillBruker = { fnr = fnr, requestStatus = model.nullstillBruker.requestStatus, error = Nothing }
              }
            , Cmd.none
            )

        StartDato startDato ->
            ( { model | startDato = startDato }, Cmd.none )

        SluttDato sluttDato ->
            ( { model | sluttDato = sluttDato }, Cmd.none )

        SubmitOpprettSykmelding ->
            ( model, postNySykmelding (lagSykmeldingBestilling model) )

        SykmeldingSendt _ ->
            ( model, Cmd.none )

        SubmitNullstillBruker ->
            ( { model
                | nullstillBruker = { fnr = model.nullstillBruker.fnr, requestStatus = STARTET, error = Nothing }
              }
            , nullstillBruker model.nullstillBruker.fnr
            )

        BrukerNullstillt result ->
            case result of
                Ok _ ->
                    ( { model | nullstillBruker = { fnr = "", requestStatus = OK, error = Nothing } }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | nullstillBruker = { fnr = model.nullstillBruker.fnr, requestStatus = FEILET, error = Just error }
                      }
                    , Cmd.none
                    )

        NoOp ->
            ( model, Cmd.none )


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
    { fnr = model.fnr
    , syketilfelleStartDato = model.startDato
    , identdato = model.startDato
    , utstedelsesdato = model.startDato
    , smtype = "HUNDEREPROSENT"
    , perioder =
        [ { fom = model.startDato
          , tom = model.sluttDato
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



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \s -> Sub.none
        , onUrlRequest = \_ -> NoOp
        , onUrlChange = \_ -> NoOp
        }
