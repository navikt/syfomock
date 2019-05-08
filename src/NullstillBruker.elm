module NullstillBruker exposing (nullstillBruker, nullstillBrukerForm)

import Felleskomponenter exposing (lagMockUrl, skjemaElement)
import Html exposing (Html, button, div, form, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onSubmit)
import Http exposing (post)
import Json.Decode as Decode
import Model exposing (Model, Msg(..))


nullstillBruker : String -> Cmd Msg
nullstillBruker fnr =
    post
        { url = lagMockUrl (String.append "/person/" (String.append fnr "/nullstill"))
        , body = Http.emptyBody
        , expect = Http.expectJson BrukerNullstillt Decode.string
        }


nullstillBrukerForm : Model -> Html Msg
nullstillBrukerForm model =
    let
        requestStatus =
            model.nullstillBruker.requestStatus
    in
    form [ onSubmit SubmitNullstillBruker ]
        [ div [ class "blokk-m" ]
            [ skjemaElement "Fødselsnummer" "text" model.nullstillBruker.fnr NullstillFnr ]
        , button [ class "knapp knapp--hoved" ] [ text "Nullstill bruker" ]
        ]
