/* eslint-disable no-console */
import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import getCharacterById from './utils/api'
import getId from './utils/getId'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const id = parseInt(getId(location.href), 10)

console.log('user', user)
console.log('id', id)
const handleSuccessfulLogin = () => {
    if (id) {
        console.log(getCharacterById)
        getCharacterById(id)
            .then(response => {
                console.log('response', response)
                Elm.Main.init(user, response)
            })
            .error(error => {
                console.error('error', error)
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
