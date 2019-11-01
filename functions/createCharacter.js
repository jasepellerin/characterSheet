/* eslint-disable no-console */
const faunadb = require('faunadb')

const fQuery = faunadb.query
const client = new faunadb.Client({
    secret: process.env.FAUNADB_SERVER_SECRET
})

exports.handler = async event => {
    const data = JSON.parse(event.body)
    console.log(`Function 'createCharacter' invoked.}`, data)
    return client
        .query(fQuery.Create(fQuery.Collection(`characters`), { data }))
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
