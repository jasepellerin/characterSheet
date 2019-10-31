import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import getCharacterById from './utils/api'
import getId from './utils/getId'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const id = parseInt(getId(location.href), 10)

const handleSuccessfulLogin = () => {
    if (id) {
        getCharacterById(id).then(response => {
            Elm.Main.init(user, response)
        })
    } else {
        Elm.Main.init(user, {})
    }
}

if (user === null) {
    netlifyIdentity.open()
} else {
    handleSuccessfulLogin()
}

netlifyIdentity.on('login', () => {
    handleSuccessfulLogin()
})
netlifyIdentity.on('logout', () => {
    netlifyIdentity.open()
})
