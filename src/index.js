import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import api from './utils/api'
import getId from './utils/getId'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
const id = parseInt(getId(location.href), 10)

const handleSuccessfulLogin = () => {
    const elmData = {
        flags: {
            userId: user ? user.id : ''
        }
    }
    if (id) {
        api.getCharacterById(id).then(response => {
            const elmApp = Elm.Main.init({
                ...elmData,
                characterData: response
            })
            elmApp.ports.log.subscribe(data => {
                console.log(data)
            })
        })
    } else {
        const elmApp = Elm.Main.init(elmData)
        elmApp.ports.log.subscribe(data => {
            console.log(data)
        })
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
