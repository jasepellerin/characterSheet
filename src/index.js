import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import api from './utils/api'
import getId from './utils/getId'
import './styles/main.scss'
import logger from './utils/logger'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const id = getId(location.pathname)
const storageKey = `characterData:${id}`
const localStorageCharacterData = JSON.parse(localStorage.getItem(storageKey))

const initializeElm = flags => {
    const elmApp = Elm.Main.init({ flags })
    elmApp.ports.log.subscribe(data => {
        logger('Logging from Elm', data)
    })
    elmApp.ports.setLocalCharacterData.subscribe(data => {
        logger('Setting data in local storage', data)
        localStorage.setItem(storageKey, JSON.stringify(data))
    })
    elmApp.ports.setDbCharacterData.subscribe(data => {
        logger('Setting data in db', data)
        api.updateCharacterById(id, data).then(response => {
            logger('response', response)
            if (response && response.data) {
                elmApp.ports.updateDbData.send(response.data)
            }
        })
    })
    elmApp.ports.createCharacter.subscribe(data => {
        logger('Creating new character', data)
        api.createCharacter(data).then(response => {
            logger('response', response)
            if (response && response.ref) {
                logger(response.ref)
                // For dramatic effect
                setTimeout(() => {
                    location.href = `${location.protocol}//${location.host}/${response.ref['@ref'].id}`
                }, 5000)
            }
        })
    })
}

const handleSuccessfulLogin = () => {
    const currentUser = user || netlifyIdentity.currentUser()
    const elmFlags = {
        currentPlayerId: currentUser ? currentUser.id : ''
    }
    if (id) {
        api.getCharacterById(id).then(response => {
            logger(response)
            const initialData = localStorageCharacterData || response.data
            initializeElm({
                ...elmFlags,
                dbData: response.data,
                characterData: initialData
            })
        })
    } else {
        // TODO: Show existing sheets for this user and New Sheet button
        initializeElm({
            ...elmFlags,
            needsCreation: true
        })
    }
}

if (user === null) {
    netlifyIdentity.open()
} else {
    handleSuccessfulLogin()
}

netlifyIdentity.on('close', () => {
    if (!netlifyIdentity.currentUser()) {
        netlifyIdentity.open()
    }
})
netlifyIdentity.on('login', () => {
    handleSuccessfulLogin()
})
netlifyIdentity.on('logout', () => {
    netlifyIdentity.open()
})
