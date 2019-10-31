module.exports = function getId(urlPath) {
    // eslint-disable-next-line no-useless-escape
    return urlPath.match(/([^\/]*)\/*$/)[0]
}
