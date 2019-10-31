/* code from functions/todos-create.js */
/* Import faunaDB sdk */
const faunadb = require('faunadb')

/* configure faunaDB Client with our secret */
const q = faunadb.query
const client = new faunadb.Client({
    secret: process.env.FAUNADB_SERVER_SECRET
})

exports.handler = async (event, context) => {
    console.log('event', event)
    console.log('context', context)
    return {
        statusCode: 200,
        body: 'Hello, world'
    }
    /* construct the fauna query */
    // return client
    //     .query(q.Create(q.Ref('classes/todos'), todoItem))
    //     .then(response => {
    //         console.log('success', response)
    //         /* Success! return the response with statusCode 200 */
    //         return {
    //             statusCode: 200,
    //             body: JSON.stringify(response)
    //         }
    //     })
    //     .catch(error => {
    //         console.log('error', error)
    //         /* Error! return the error with statusCode 400 */
    //         return {
    //             statusCode: 400,
    //             body: JSON.stringify(error)
    //         }
    //     })
}
