
class @ActiveRecordObject # @ attaches it to the window
	constructor: (obj) ->
		this[prop] = val for prop, val of obj

