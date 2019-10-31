import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import api from './utils/api'
import getId from './utils/getId'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const id = parseInt(getId(location.href), 10)

const initializeElm = initialData => {
    const elmApp = Elm.Main.init(initialData)
    elmApp.ports.log.subscribe(data => {
        localStorage.setItem(`characterData:${id}`, JSON.stringify(data))
    })
}

const handleSuccessfulLogin = () => {
    const elmData = {
        flags: {
            userId: user ? user.id : ''
        }
    }
    if (id) {
        api.getCharacterById(id).then(response => {
            initializeElm({
                ...elmData,
                characterData: response
            })
        })
    } else {
        initializeElm(elmData)
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
