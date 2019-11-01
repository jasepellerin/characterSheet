import isLocalHost from './isLocalHost'

const prefix = isLocalHost() ? 'http://localhost:8888' : ''

const getCharacterById = id => {
    return fetch(`${prefix}/.netlify/functions/getCharacter/${id}`, {
        method: 'GET'
    }).then(response => {
        return response.json()
    })
}

const updateCharacterById = (id, data) => {
    return fetch(`${prefix}/.netlify/functions/updateCharacter/${id}`, {
        body: JSON.stringify(data),
        method: 'POST'
    }).then(response => {
        return response.json()
    })
}

const createCharacter = data => {
    return fetch(`${prefix}/.netlify/functions/createCharacter`, {
        body: JSON.stringify(data),
        method: 'POST'
    }).then(response => {
        return response.json()
    })
}

export default { createCharacter, getCharacterById, updateCharacterById }
