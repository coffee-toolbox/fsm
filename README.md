# FSM
An actor-based Finite State Machine

## State and StateHandlers
`@state` is a string that store the current state of the machine.
When `@nextState new_state` is called, `@state` will change to the `new_state`
and the StateHandler registered through `@setStateHandlers` will be handling
the new State.

Internally, a `'$to_state'` message is sent when `@nextState` called, as is
shown by the example below.

## Example
```coffeescripts
{FSM} = require('@coffee-toolbox/fsm')

class FSMTester extends FSM
	constructor: ->
		super
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

	do_stop: =>
		@logger.log @state
		@logger.log done

a = new FSMTester()
a.$send_to a, 'start', 'start working'

# FSMTester => FSMTester:
#   start
#  : start working
# FSMTester <= FSMTester:
#   start
#  : start working
# FSMTester starting
# FSMTester => FSMTester:
#   $to_state
#  : { state: 'STARTED', args: [ 'start working' ] }
# FSMTester <= FSMTester:
#   $to_state
#  : { state: 'STARTED', args: [ 'start working' ] }
# FSMTester STARTED
# FSMTester start working
# FSMTester => FSMTester:
#   stop
#  : undefined
```
