import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import api from './utils/api'
import getId from './utils/getId'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const id = getId(location.href)
const storageKey = `characterData:${id}`
const localStorageCharacterData = JSON.parse(localStorage.getItem(storageKey))

const initializeElm = flags => {
    const elmApp = Elm.Main.init({ flags })
    elmApp.ports.log.subscribe(data => {
        console.log(data)
    })
    elmApp.ports.setLocalCharacterData.subscribe(data => {
        console.log('setting in local storage', data)
        localStorage.setItem(storageKey, JSON.stringify(data))
    })
    elmApp.ports.setDbCharacterData.subscribe(data => {
        console.log('setting in db', data)
        api.updateCharacterById(id, data)
    })
}

const handleSuccessfulLogin = () => {
    const elmFlags = {
        currentPlayerId: user ? user.id : ''
    }
    if (id) {
        api.getCharacterById(id).then(response => {
            console.log(response)
            initializeElm({
                ...elmFlags,
                characterData: response.data
            })
        })
    } else {
        console.log('No sheet with that id was found')
        // TODO: Show existing sheets for this user and New Sheet button
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
