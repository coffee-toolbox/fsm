'use strict'
{Actor} = require('@coffee-toolbox/actor')

class FSM extends Actor
	constructor: ->
		super
		@state = 'INIT'
		@stateHandler = {}

	$start: (reg)->
		reg.receive = Object.assign {}, reg.receive,
			$to_state: (from, new_state)=>
				@logger.assert from is this
				@state = new_state.state
				f = @stateHandler[new_state.state]
				@logger.assert f?
				@logger.assert f instanceof Function
				f new_state.args...
		super reg

	nextState: (state, v...)->
		@$send_to this, '$to_state',
			state: state
			args: v
		@$next()

	# reg :: { State: Function }
	# State :: string
	# setup StateHandlers.
	setStateHandlers: (reg)->
		@stateHandler = Object.assign {}, reg

module.exports =
	FSM: FSM
