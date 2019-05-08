module Api exposing (lagMockUrl, nullstillBruker)

import Http exposing (post)
import Json.Decode as Decode
import Model exposing (Msg(..))


lagMockUrl : String -> String
lagMockUrl utvidelse =
    String.append "https://syfomockproxy-q.nav.no" utvidelse


nullstillBruker : String -> Cmd Msg
nullstillBruker fnr =
    post
        { url = lagMockUrl (String.append "/person/" (String.append fnr "/nullstill"))
        , body = Http.emptyBody
        , expect = Http.expectJson BrukerNullstillt Decode.string
        }
