if not _?
  throw 'StateMachine requires the lodash library.'

class StateMachine
  constructor: (config) ->
    @config = _.extend
      exceptions:false
      otherwise: "otherwise"
    , config
    @states = []
    @currentState = null
    @onChangeCallbacks = []

  onStateChange: (callback) ->
    @onChangeCallbacks.push callback
    return _.extend this,
      stop: ->
        _.remove @onChangeCallbacks, (c) -> c is callback

  transitionToState: (stateName) ->
    state = _.find @states, name: stateName
    if not state?
      if @config.exceptions then throw ("State #{stateName} does not exist.")  else return
    @currentState.callbacks.onExit() if @currentState?
    _.forEach @onChangeCallbacks, (c) => c fromState: (if @currentState? then @currentState.name else null), toState: state.name
    @currentState = state
    @currentState.callbacks.onEnter()
  
  performAction: (actionName) ->
    return if not @currentState
    @currentState.callbacks.preAction()
    action = @currentState.actions[actionName]
    if action then action() else @currentState.actions.otherwise(actionName)
    @currentState.callbacks.postAction()

  state: (stateName, actions, callbacks) ->
    index = _.findIndex @states, name: stateName
    index = @states.length if index is -1
    if actions?
      splitactions = {}
      Object.keys(actions).forEach (action) ->
        action.split("|").forEach (name) ->
          splitactions[name] = actions[action]
      actions = splitactions
    @states[index] =
      name:stateName,
      callbacks: _.extend 
        onEnter: ->
        onExit: ->
        preAction: ->
        postAction: ->
      , callbacks
      actions: _.extend
        otherwise: ->
      ,  actions
    return @

window.StateMachine = StateMachine