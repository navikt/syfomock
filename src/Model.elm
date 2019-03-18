module Model exposing (Sykemeldingstype(..), SykmeldingBestilling, SykmeldingPeriode)


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
