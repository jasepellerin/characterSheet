import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import api from './utils/api'
import getId from './utils/getId'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const id = parseInt(getId(location.href), 10)
const storageKey = `characterData:${id}`
const localStorageCharacterData = JSON.parse(localStorage.getItem(storageKey))

const initializeElm = flags => {
    const elmApp = Elm.Main.init({ flags })
    elmApp.ports.setCharacterData.subscribe(data => {
        console.log(data)
        localStorage.setItem(storageKey, JSON.stringify(data))
    })
}

const handleSuccessfulLogin = () => {
    const elmFlags = {
        userId: user ? user.id : ''
    }
    if (id) {
        // api.getCharacterById(id).then(response => {
        console.log(localStorageCharacterData)
        initializeElm({
            ...elmFlags,
            characterData: localStorageCharacterData
        })
        // })
    } else {
        initializeElm(elmFlags)
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
