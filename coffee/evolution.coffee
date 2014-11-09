# Todo: highlight passed

# Evolution.controller('EvolutionCtrl', ($scope) ->

angular.module('EvolutionApp').controller 'EvolutionCtrl', ($scope, utils, io) ->

	$scope.phase = null
	$scope.deck = null
	$scope.players = []
	$scope.players.dirty = 0
	$scope.currentPlayerId = 0
	$scope.game = null

	# $scope.phase = "Evolution"
	# $scope.deck = { number: 40 }
	
	# $scope.players = [ 
	# 	{
	# 		name: 'Edouard', 
	# 		hand: [ { shortName:"intellect" }, { shortName:"carnivorous" }, { shortName:"vivaporous" }, { shortName:"tailLoss"} ],
	# 		species: [ [], [ { name:"intellect", shortName:"intellect" }, { name:"carnivorous", cost:1, shortName:"intellect"} ] ]
	# 	},
	# 	{
	# 		name: 'Jacob', 
	# 		cardNumber: 5,
	# 		species: [ [], [ { name:"tailLoss", shortName:"tailLoss" }, { name:"vivaporous", cost:1, shortName:"vivaporous"} ] ]
	# 	},
	# 	{
	# 		name: 'Charlotte',
	# 		cardNumber: 2,
	# 		species: [ [], [ { name:"tailLoss", shortName:"tailLoss" } ] ]
	# 	} 
	# ]

	$scope.isMyTurn = ()->
		return $scope.game? and $scope.currentPlayerId == $scope.playerId

	$scope.player = ()->
		return $scope.players[$scope.playerId]

	$scope.pass = ()->
		console.log "pass"
		io.emit('pass turn')

	$scope.end = (cardId, specieId)->
		console.log "next player"
		io.emit('end turn', {cardId: cardId, specieId: specieId})

	$scope.selectedCard = ()->
		for card, i in $scope.player().hand
			if card.selected then return { card: card, id: i }
		return

	$scope.selectCard = (card)->
		if not $scope.isMyTurn() then return
		$scope.selectedCard()?.selected = false
		card.selected = true
		$scope.checkCompatible(card)

	$scope.checkCompatible = (card)->
		for specie in $scope.player().species
			specie.compatible = false
			# check
			specie.compatible = true

	$scope.selectSpecie = (specie, specieId)->
		if not $scope.isMyTurn() then return
		if specie.compatible
			cardData = $scope.selectedCard()
			$scope.player().hand.remove(cardData.card)
			specie.push(cardData.card)
			$scope.end(cardData.id, specieId)

	$scope.currentPlayerClass = (id)->
		result = ''
		if id == $scope.currentPlayerId
			result += 'currentPlayer'
		if id > $scope.playerId
			result += ' flex_order-1'
		if $scope.players[id].finished
			result += ' finished'
		return result

	io.on "get id", (data)->
		localStorage

	io.on "game loaded", (data)->
		console.log "Game: " + data.gameId + ", player: " + data.playerId
		localStorage.setItem("playerId", data.playerId)
		localStorage.setItem("gameId", data.gameId)
		# localStorage.gameId = data.gameId

		$scope.playerId = data.playerId
		$scope.phase = data.game.phase
		$scope.deck = data.game.deck
		$scope.players = data.game.players
		$scope.game = data.game
		$scope.currentPlayerId = data.game.currentPlayerId
		$scope.$apply()
		return

	io.on "next player", (data)->
		if data.previousPlayerId != $scope.playerId
			player = $scope.players[data.previousPlayerId]
			if player.cardNumber?
				player.cardNumber--
				if player.cardNumber == 0
					player.finished = true
			player.species[data.specieId].push(data.card.card)
		else
			if player.hand.length == 0
				player.finished = true
		$scope.currentPlayerId = data.currentPlayerId
		$scope.$apply()
		return

	io.on "player passed", (data)->
		$scope.players[data.previousPlayerId].finished = true
		$scope.currentPlayerId = data.currentPlayerId
		player.finished = true
		$scope.$apply()
		return

	io.on "error", (data)->
		console.log data
		return

	io.on "game error", (data)->
		console.log data
		return

	io.on "evolution error", (data)->
		$scope.players[data.currentPlayerId].species[data.specieId].pop()
		console.log "ahah t'as perdu ta carte :D"
		return

	gameData = { gameId: (if localStorage.gameId? then parseInt(localStorage.gameId) else null), playerId: (if localStorage.playerId? then parseInt(localStorage.playerId) else null) }
	console.log gameData

	io.emit "load game", gameData

	return

