/* eslint-disable no-console */
const faunadb = require('faunadb')
const getId = require('./utils/getId')

const fQuery = faunadb.query
const client = new faunadb.Client({
    secret: process.env.FAUNADB_SERVER_SECRET
})

exports.handler = async event => {
    const data = JSON.parse(event.body)
    const id = getId(event.path)
    console.log(`Function 'updateCharacter' invoked. Update id: ${id}`)
    return client
        .query(fQuery.Update(fQuery.Ref(`classes/characters/${id}`), data))
        .then(response => {
            console.log('success', response)
            return {
                statusCode: 200,
                body: JSON.stringify(response)
            }
        })
        .catch(error => {
            console.log('error', error)
            return {
                statusCode: 400,
                body: JSON.stringify(error)
            }
        })
}
