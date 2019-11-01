/* eslint-disable no-console */
import isLocalHost from './isLocalHost'

const logger = (...parameters) => {
    if (isLocalHost()) {
        console.log(...parameters)
    }
}

export default logger
