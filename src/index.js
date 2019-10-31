import netlifyIdentity from 'netlify-identity-widget'
import { Elm } from './elm/Main'
import './styles/main.scss'

netlifyIdentity.init()
const user = netlifyIdentity.currentUser()
console.log(user)
// if (user === null) {
//     netlifyIdentity.open()
// } else {
//     Elm.Main.init()
// }
// netlifyIdentity.on('login', () => {
//     netlifyIdentity.close()
//     Elm.Main.init()
// })
fetch('/.netlify/functions/getCharacter/123', {
    method: 'GET'
}).then(response => {
    return response.json()
})
