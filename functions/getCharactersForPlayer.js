/* eslint-disable no-console */
const faunadb = require('faunadb')
const getId = require('./utils/getId')

const fQuery = faunadb.query
const client = new faunadb.Client({
    secret: process.env.FAUNADB_SERVER_SECRET
})

exports.handler = async event => {
    const id = getId(event)
    console.log(`Function 'getCharacter' invoked. Read id: ${id}`)
    return client
        .query(
            fQuery.Map(
                fQuery.Paginate(fQuery.Match(fQuery.Index(`by_player_id`), id)),
                fQuery.Lambda('character', fQuery.Get(fQuery.Select(1, fQuery.Var('character'))))
            )
        )
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
