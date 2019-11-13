import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import './styles/main.scss'
import logger from './utils/logger'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()

const initializeElm = (flags, localStorageKey) => {
    const elmApp = Elm.Main.init({ flags })
    elmApp.ports.log.subscribe(data => {
        logger('Logging from Elm', data)
    })
    elmApp.ports.setLocalCharacterData.subscribe(data => {
        logger('Setting data in local storage', data)
        localStorage.setItem(localStorageKey, JSON.stringify(data))
    })
}

const handleSuccessfulLogin = () => {
    const currentUser = netlifyIdentity.currentUser()
    if (!currentUser || !currentUser.id) {
        netlifyIdentity.open()
        return
    }

    const currentPlayerId = currentUser.id
    const localStorageKey = `playerData:${currentPlayerId}`
    const localStorageData = JSON.parse(localStorage.getItem(localStorageKey))
    const elmFlags = {
        currentPlayerId,
        localData: localStorageData
    }
    initializeElm(
        {
            ...elmFlags
        },
        localStorageKey
    )
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
