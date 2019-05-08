module Model exposing (Model, Msg(..), NullstillBrukerModel, RequestStatus(..), Sykemeldingstype(..), SykmeldingBestilling, SykmeldingPeriode)

import Http


type alias Model =
    { fnr : String
    , startDato : String
    , sluttDato : String
    , nullstillBruker : NullstillBrukerModel
    }


type alias NullstillBrukerModel =
    { fnr : String
    , requestStatus : RequestStatus
    , error : Maybe Http.Error
    }


type RequestStatus
    = IKKE_STARTET
    | STARTET
    | OK
    | FEILET


type Msg
    = Fnr String
    | NullstillFnr String
    | StartDato String
    | SluttDato String
    | SubmitOpprettSykmelding
    | SubmitNullstillBruker
    | SykmeldingSendt (Result Http.Error (List String))
    | BrukerNullstillt (Result Http.Error String)
    | NoOp


type alias SykmeldingBestilling =
    { fnr : String
    , syketilfelleStartDato : String
    , identdato : String
    , utstedelsesdato : String
    , smtype : String
    , perioder : List SykmeldingPeriode
    , manglendeTilrettelegging : Bool
    }


type alias SykmeldingPeriode =
    { fom : String
    , tom : String
    , sykmeldingstype : Sykemeldingstype
    }


type Sykemeldingstype
    = AVVENTENDE
    | GRADERT_20
    | GRADERT_40
    | GRADERT_50
    | GRADERT_60
    | GRADERT_80
    | GRADERT_REISETILSKUDD
    | HUNDREPROSENT
    | BEHANDLINGSDAGER
    | BEHANDLINGSDAG
    | REISETILSKUDD
