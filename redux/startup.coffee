import { createActions } from 'reduxsauce'

{ Types, Creators } = createActions(
    startup: null
, { prefix: 'startup/' })

export { Types as StartupTypes }
export default Creators
