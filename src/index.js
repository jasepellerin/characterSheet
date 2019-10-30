import { Elm } from './elm/Main'
import './styles/main.scss'
import netlifyIdentity from 'netlify-identity-widget'

// Elm.Main.init()

netlifyIdentity.init()
netlifyIdentity.open()
