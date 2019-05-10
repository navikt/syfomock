module Model exposing
    ( Model
    , Msg(..)
    , NullstillBrukerModel
    , OpprettSykmneldingModel
    , RequestStatus(..)
    , SykmeldingBestilling
    , SykmeldingPeriode
    , Sykmeldingstype(..)
    )

import Http


type alias Model =
    { opprettSykmelding : OpprettSykmneldingModel
    , nullstillBruker : NullstillBrukerModel
    }


type alias OpprettSykmneldingModel =
    { fnr : String
    , periode : OpprettSykmeldingPeriode
    , requestStatus : RequestStatus
    , error : Maybe Http.Error
    }


type alias OpprettSykmeldingPeriode =
    { startDato : String
    , sluttDato : String
    , sykmeldingstype : Sykmeldingstype
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
    = NullstillFnr String
    | Fnr String
    | StartDato String
    | SluttDato String
    | PeriodeSykmeldingstype String
    | SubmitOpprettSykmelding
    | SubmitNullstillBruker
    | SykmeldingSendt (Result Http.Error String)
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
    , sykmeldingstype : Sykmeldingstype
    }


type Sykmeldingstype
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
