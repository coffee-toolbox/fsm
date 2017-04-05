'use strict'
{Actor} = require('@coffee-toolbox/actor')

class FSM extends Actor
	constructor: (config)->
		super config
		@state = 'INIT'
		@stateHandler =
			TERMINATED: (reason)=>
				@$terminate(reason)
				if reason?
					@logger.info 'terminated', reason
				else
					@logger.info 'terminated'

	$start: (reg)->
		reg ?= {}
		reg.call = Object.assign {}, reg.call,
			$set_new_state: (new_state)=>
				@state = new_state.state
				@$send_to this, '$run_state_handler', new_state
		reg.receive = Object.assign {}, reg.receive,
			$run_state_handler: (from, new_state)=>
				@logger.assert from is this
				f = @stateHandler[new_state.state]
				@logger.assert f?,
					"state handler for #{new_state.state} not exist"
				@logger.assert f instanceof Function,
					"state handler for #{new_state.state} is not a Function"
				f new_state.args...
		super reg

	nextState: (state, v...)->
		@$call '$set_new_state',
			state: state
			args: v
		@$next()

	# reg :: { State: Function }
	# State :: string
	# setup StateHandlers.
	setStateHandlers: (reg)->
		@stateHandler = Object.assign {}, @stateHandler, reg

module.exports =
	FSM: FSM
