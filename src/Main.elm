module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (post)
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (..)
import Url exposing (Url)


type alias Model =
    { fnr : String
    , startDato : String
    , sluttDato : String
    }



-- MODEL


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    ( { fnr = "", startDato = "", sluttDato = "" }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Syfomock"
    , body =
        [ h1 [ class "header typo-sidetittel blokk-l" ] [ text "Syfomock" ]
        , div [ class "skjema" ]
            [ h2 [ class "blokk-m typo-innholdstittel" ] [ text "Opprett sykmelding" ]
            , sykmeldingForm model
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


skjemaElement : String -> String -> String -> (String -> msg) -> Html msg
skjemaElement inputLabel inputType inputValue toMsg =
    div [ class "skjemaelement skjemaelement__fullbredde" ]
        [ label [ class "skjemaelement__label" ] [ text inputLabel ]
        , input [ type_ inputType, value inputValue, onInput toMsg, class "skjemaelement__input input--fullbredde" ] []
        ]


viewValidation : Model -> Html msg
viewValidation model =
    if String.length model.fnr == 11 then
        div [ style "color" "green" ] [ text "OK" ]

    else
        div [ style "color" "red" ] [ text "Feil lengde på fødselsnummer" ]



-- UPDATE


type Msg
    = Fnr String
    | StartDato String
    | SluttDato String
    | SubmitOpprettSykmelding
    | SykmeldingSendt (Result Http.Error (List String))
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fnr fnr ->
            ( { model | fnr = fnr }, Cmd.none )

        StartDato startDato ->
            ( { model | startDato = startDato }, Cmd.none )

        SluttDato sluttDato ->
            ( { model | sluttDato = sluttDato }, Cmd.none )

        SykmeldingSendt _ ->
            ( model, Cmd.none )

        SubmitOpprettSykmelding ->
            ( model, postNySykmelding (lagSykmeldingBestilling model) )

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
