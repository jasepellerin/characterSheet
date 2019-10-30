import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
if (user === null) {
    netlifyIdentity.open()
} else {
    Elm.Main.init()
}

netlifyIdentity.on('login', () => {
    netlifyIdentity.close()
    Elm.Main.init()
})
