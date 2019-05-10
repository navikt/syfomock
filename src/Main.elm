module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class)
import Model exposing (..)
import NullstillBruker exposing (nullstillBruker, nullstillBrukerForm)
import OpprettSykmelding
    exposing
        ( lagSykmeldingBestilling
        , opprettSykmeldingDefaulState
        , postNySykmelding
        , stringTilSykmeldingstype
        , sykmeldingForm
        )
import Url exposing (Url)



-- MODEL


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    ( { opprettSykmelding = opprettSykmeldingDefaulState
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



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fnr fnr ->
            let
                opprettSykmelding =
                    model.opprettSykmelding
            in
            ( { model
                | opprettSykmelding = { opprettSykmelding | fnr = fnr }
              }
            , Cmd.none
            )

        NullstillFnr fnr ->
            let
                nullstillBruker =
                    model.nullstillBruker
            in
            ( { model
                | nullstillBruker = { nullstillBruker | fnr = fnr }
              }
            , Cmd.none
            )

        StartDato startDato ->
            let
                opprettSykmelding =
                    model.opprettSykmelding

                periode =
                    opprettSykmelding.periode
            in
            ( { model
                | opprettSykmelding = { opprettSykmelding | periode = { periode | startDato = startDato } }
              }
            , Cmd.none
            )

        SluttDato sluttDato ->
            let
                opprettSykmelding =
                    model.opprettSykmelding

                periode =
                    opprettSykmelding.periode
            in
            ( { model
                | opprettSykmelding = { opprettSykmelding | periode = { periode | sluttDato = sluttDato } }
              }
            , Cmd.none
            )

        PeriodeSykmeldingstype sykmeldingstype ->
            let
                opprettSykmelding =
                    model.opprettSykmelding

                periode =
                    opprettSykmelding.periode
            in
            ( { model
                | opprettSykmelding = { opprettSykmelding | periode = { periode | sykmeldingstype = stringTilSykmeldingstype sykmeldingstype } }
              }
            , Cmd.none
            )

        SubmitOpprettSykmelding ->
            ( model, postNySykmelding (lagSykmeldingBestilling model) )

        SykmeldingSendt result ->
            let
                opprettSykmeldingModel =
                    model.opprettSykmelding

                opprettSykmelding =
                    case result of
                        Ok _ ->
                            { opprettSykmeldingDefaulState | requestStatus = OK }

                        Err error ->
                            { opprettSykmeldingModel | requestStatus = FEILET, error = Just error }
            in
            ( { model | opprettSykmelding = opprettSykmelding }, Cmd.none )

        SubmitNullstillBruker ->
            let
                nullstillBrukerModel =
                    model.nullstillBruker
            in
            ( { model
                | nullstillBruker = { nullstillBrukerModel | requestStatus = STARTET }
              }
            , nullstillBruker model.nullstillBruker.fnr
            )

        BrukerNullstillt result ->
            let
                nullstillBrukerModel =
                    model.nullstillBruker

                nullstillBruker =
                    case result of
                        Ok _ ->
                            { nullstillBrukerModel | fnr = "", requestStatus = OK }

                        Err error ->
                            { nullstillBrukerModel | requestStatus = FEILET, error = Just error }
            in
            ( { model
                | nullstillBruker = nullstillBruker
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



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
