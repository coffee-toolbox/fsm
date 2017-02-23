# FSM
An actor-based Finite State Machine

### NOTE
Do NOT download from npm!

Just add the dependency that use https git repo url as a version.

    "@coffee-toolbox/fsm": "https://github.com/coffee-toolbox/fsm.git"

npm is evil that it limit the publish of more than one project.
And its restriction on version number is terrible for fast development that
require local reference. (npm link sucks!)
[why npm link sucks](https://github.com/webpack/webpack/issues/554)

It ruined my productivity for a whole three days!

For any one who values his life, please be away from npm.

----

## State and StateHandlers
`@state` is a string that store the current state of the machine.
When `@nextState new_state` is called, `@state` will change to the `new_state`
and the StateHandler registered through `@setStateHandlers` will handle the
new State.

Internally, new state is set by calling `$set_new_state`. Then a
`'$run_state_handler'` message is sent when `@nextState` called, as is
shown by the example below.

## Example
```coffeescript
{FSM} = require('@coffee-toolbox/fsm')

class FSMTester extends FSM
	constructor: ->
		super {debug: true}
		@setStateHandlers
			STARTED: @do_start
			STOPPED: @do_stop

		@$start
			receive:
				start: @start
				stop: @stop

	start: (from, msg)=>
		if @state is 'INIT'
			@logger.log 'starting'
			@nextState 'STARTED', msg

	stop: (from)=>
		if @state is 'STARTED'
			@logger.log 'stopping'
			@nextState 'STOPPED'

	do_start: (msg)=>
		@logger.log @state
		@logger.log msg
		# do something ...
		setTimeout =>
			@$send_to this, 'stop'
		, 1000
		@$next()

	do_stop: =>
		@logger.log @state
		@logger.log 'done'
		@$next()

a = new FSMTester()
a.$send_to a, 'start', 'start working'

###
FSMTester => FSMTester:
  start
 : start working
FSMTester <= FSMTester:
  start
 : start working
FSMTester starting
FSMTester => FSMTester:
  $run_state_handler
 : { state: 'STARTED', args: [ 'start working' ] }
FSMTester <= FSMTester:
  $run_state_handler
 : { state: 'STARTED', args: [ 'start working' ] }
FSMTester STARTED
FSMTester start working
FSMTester => FSMTester:
  stop
 : undefined
FSMTester <= FSMTester:
  stop
 : undefined
FSMTester stopping
FSMTester => FSMTester:
  $run_state_handler
 : { state: 'STOPPED', args: [] }
FSMTester <= FSMTester:
  $run_state_handler
 : { state: 'STOPPED', args: [] }
FSMTester STOPPED
FSMTester done
###
```
