import isLocalHost from './isLocalHost'

const prefix = isLocalHost() ? 'http://localhost:8888' : ''

const getCharacterById = id => {
    return fetch(`${prefix}/.netlify/functions/getCharacter/${id}`, {
        method: 'GET'
    }).then(response => {
        return response.json()
    })
}

export default { getCharacterById }
