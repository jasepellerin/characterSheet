/* eslint-disable no-console */
import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
// import getCharacterById from './utils/api'
import getId from './utils/getId'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const id = parseInt(getId(location.href), 10)

const getCharacterById = idTest => {
    console.log(idTest)
    return fetch(`/.netlify/functions/getCharacter/${idTest}`, {
        method: 'GET'
    }).then(response => {
        return response.json()
    })
}

console.log('user', user)
console.log('id', id)
const handleSuccessfulLogin = () => {
    if (id) {
        getCharacterById(id).then(response => {
            console.log('response', response)
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
