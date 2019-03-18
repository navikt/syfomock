import { Elm } from './Main.elm'
import 'nav-frontend-core'
import 'nav-frontend-paneler-style'
import 'nav-frontend-typografi-style'
import 'nav-frontend-skjema-style'
import 'nav-frontend-knapper-style'

Elm.Main.init({
  node: document.querySelector('main')
})