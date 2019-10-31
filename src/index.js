/* eslint-disable no-console */
import netlifyIdentity from 'netlify-identity-widget'
import queryString from 'query-string'
import { Elm } from './elm/Main'
import getCharacterById from './utils/api'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const { id } = queryString.parse(location.search)

console.log('user', user)
console.log('id', id)
const handleSuccessfulLogin = () => {
    if (id) {
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
    netlifyIdentity.close()
    Elm.Main.init()
})
netlifyIdentity.on('logout', () => {
    netlifyIdentity.open()
})
