// eslint-disable-next-line no-useless-escape
const getId = urlPath => {
    console.log(urlPath, urlPath.match(/([^\/]*)\/*$/))
    return urlPath.match(/([^\/]*)\/*$/)[0]
}

export default getId
