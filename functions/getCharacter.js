/* eslint-disable no-console */
const faunadb = require('faunadb')

const getId = urlPath => urlPath.match(/([^\/]*)\/*$/)[0]

const q = faunadb.query
const client = new faunadb.Client({
    secret: process.env.FAUNADB_SERVER_SECRET
})

exports.handler = async event => {
    const id = getId(event.path)
    console.log(`Function 'getCharacter' invoked. Read id: ${id}`)
    return client.query(q.Get(q.Match(q.Index('by_id'), id))).then(response => {
        console.log('success', response)
        return {
            statusCode: 200,
            body: JSON.stringify(response)
        }
    })
}
