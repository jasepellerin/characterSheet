// eslint-disable-next-line no-useless-escape
const getId = urlPath => urlPath.match(/([^\/]*)\/*$/)[0]

export default getId
