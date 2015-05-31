describe 'StateMachineTests', ->
  machine = null
  beforeEach ->
    machine = new StateMachine()
    
  it 'should transition to a new state', ->
    machine.state 'state1'
    machine.transitionToState 'state1'
    expect(machine.currentState.name).toBe 'state1'
  
  it 'should not transition to a state if the state does not exist', ->
    machine.state 'state1'
    machine.transitionToState 'state2'
    expect(machine.currentState).toBe null

  it 'should throw an expception when performing an action it does not know', ->
    machine = new StateMachine exceptions:true
    expect(-> machine.transitionToState 'state1').toThrow()
  
  it 'should perform the on enter state change event when a state changes', ->
    enter = jasmine.createSpy()
    machine.state 'state1', {}, onEnter:enter
    .transitionToState 'state1'
    expect(enter).toHaveBeenCalled()

  it 'should perform the on exit state change event when a state changes', ->
    exit = jasmine.createSpy()
    machine
    .state 'state1', {}, onExit:exit
    .state 'state2'
    machine.transitionToState 'state1'
    machine.transitionToState 'state2'
    expect(exit).toHaveBeenCalled()

  it 'should perform the preAction callback to be called when an action is performed', ->
    before = jasmine.createSpy('before')
    action = jasmine.createSpy('action')
    machine
    .state 'state1', {action:action}, preAction:before
    machine.transitionToState 'state1'
    machine.performAction 'action'
    
    expect(before).toHaveBeenCalled()
    expect(action).toHaveBeenCalled()

  it 'should perform the postAction callback to be called when an action is performed', ->
    after = jasmine.createSpy('before')
    action = jasmine.createSpy('action')
    machine
    .state 'state1', {action:action}, postAction:after
    machine.transitionToState 'state1'
    machine.performAction 'action'
    
    expect(action).toHaveBeenCalled()
    expect(after).toHaveBeenCalled()

  it 'should perform an action on the current state', ->
    toCall = jasmine.createSpy()
    machine.state 'state1', {action:toCall}
    machine.transitionToState 'state1'
    machine.performAction 'action'
    expect(toCall).toHaveBeenCalled()
