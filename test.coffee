{FSM} = require('./FSM.coffee')

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
