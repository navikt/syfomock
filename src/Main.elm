module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class)
import Model exposing (..)
import NullstillBruker exposing (nullstillBruker, nullstillBrukerForm)
import OpprettSykmelding exposing (lagSykmeldingBestilling, postNySykmelding, sykmeldingForm)
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
