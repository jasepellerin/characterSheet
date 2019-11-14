module.exports = function getId({ queryStringParameters, path }) {
    // eslint-disable-next-line no-useless-escape
    return queryStringParameters.id || path.match(/([^\/]*)\/*$/)[0]
}
