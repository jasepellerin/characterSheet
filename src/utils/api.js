const getCharacterById = id => {
    return fetch(`/.netlify/functions/getCharacter/${id}`, {
        method: 'GET'
    }).then(response => {
        return response.json()
    })
}

export default {
    getCharacterById
}
