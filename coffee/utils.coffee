angular.module('UtilsService').service 'utils', () ->


	this.getTime = ()->
		return new Date().getTime()

	this.sign = (x) ->
		(if typeof x is "number" then (if x then (if x < 0 then -1 else 1) else (if x is x then 0 else NaN)) else NaN)

	# removes itemToRemove from array 
	Array.prototype.remove = (itemToRemove) ->
		this.splice(this.indexOf(itemToRemove),1)

	# get first element of array
	Array.prototype.first = () ->
		return this[0]

	# get last element of array
	Array.prototype.last = () ->
		return this[this.length-1]

	# get random element of array
	Array.prototype.random = () ->
		return this[Math.floor(Math.random()*this.length)]
