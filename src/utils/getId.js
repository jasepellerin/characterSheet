const getId = urlPath => {
    const urlPathWithoutTrailingSlash =
        urlPath.substring(urlPath.length - 1) === '/'
            ? urlPath.substring(0, urlPath.length - 1)
            : urlPath

    // eslint-disable-next-line no-useless-escape
    return urlPathWithoutTrailingSlash.match(/([^\/]*)\/*$/)[0]
}

export default getId
