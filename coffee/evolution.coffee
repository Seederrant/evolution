# Todo: highlight passed

# Evolution.controller('EvolutionCtrl', ($scope) ->

angular.module('EvolutionApp').controller 'EvolutionCtrl', ($scope, utils, io, EvolutionCommons) ->

	$scope.phase = null
	$scope.deck = null
	$scope.players = []
	$scope.players.dirty = 0
	$scope.game = null

	specie:
		traits: []
		foodEaten: 0

	$scope.isMyTurn = ()->
		return $scope.ec? and $scope.ec.isPlayerTurn( $scope.playerId )
	
	$scope.isMyTurnAndEvolutionPhase = ()->
		return $scope.isMyTurn() and $scope.ec.game.phase == 'Evolution'

	$scope.player = ()->
		return $scope.ec?.player($scope.playerId)

	$scope.passPhaseEvolution = ()->
		console.log "pass"
		io.emit('pass phase evolution', {})

	$scope.endTurnEvolution = (cardIndex, specieIndex)->
		console.log "next player"
		console.log cardIndex
		io.emit('end turn evolution', {cardIndex: cardIndex, specieIndex: specieIndex})

	$scope.selectedCard = ()->
		for card, i in $scope.ec.currentPlayer().hand
			if card.selected then return i
		return

	$scope.selectCard = (cardIndex)->
		if not $scope.isMyTurn() then return
		$scope.ec.card($scope.selectedCard())?.selected = false
		card = $scope.ec.card(cardIndex)
		card.selected = true
		$scope.checkCompatibleEvolution(card)

	$scope.feedSpecie = (specieIndex)->
		$scope.ec.feedSpecie(specieIndex)
		emit "end turn food", { specieIndex: specieIndex}
		return

	$scope.useTrait = (specie, specieIndex, trait, traitIndex)->
		emit "end turn food", { specieIndex: specieIndex, traitIndex: traitIndex }
		return

	$scope.checkCompatibleEvolution = (card)->
		for specie in $scope.player().species
			specie.compatible = $scope.ec.isCompatibleEvolution(specie, card)

	$scope.clearCompatible = (card)->
		for specie in $scope.ec.currentPlayer().species
			specie.compatible = false	

	$scope.selectSpecieEvolution = (specieIndex)->
		if $scope.ec.specie(specieIndex).compatible
			cardIndex = $scope.selectedCard()
			$scope.ec.addTrait(specieIndex, cardIndex)
	
			$scope.clearCompatible()
			$scope.endTurnEvolution(cardIndex, specieIndex)
		return

	$scope.selectSpecie = (specieIndex)->
		if not $scope.isMyTurn() then return
		switch $scope.ec.game.phase
			when 'Evolution'
				$scope.selectSpecieEvolution(specieIndex)
			when 'Food'
				$scope.selectSpecieFood(specieIndex)
		return

	$scope.currentPlayerClass = (id)->
		result = ''
		if id == $scope.ec.currentPlayerId()
			result += 'currentPlayer'
		if id > $scope.playerId
			result += ' flex_order-1'
		if $scope.ec.players()[id].finished
			result += ' finished'
		return result

	io.on "get id", (data)->
		localStorage

	io.on "game loaded", (data)->
		$scope.ec = new EvolutionCommons(data.game)
		console.log "Game: " + data.gameId + ", player: " + data.playerId
		localStorage.setItem("playerId", data.playerId)
		localStorage.setItem("gameId", data.gameId)
		# localStorage.gameId = data.gameId

		$scope.playerId = data.playerId
		$scope.$apply()
		return

	io.on "next player evolution", (data)->
		previousPlayerId = $scope.ec.currentPlayerId()
		$scope.ec.nextPlayer()
		if previousPlayerId != $scope.playerId 	# if we are not the previous player
			player = $scope.ec.players()[previousPlayerId]
			player.species[data.specieIndex].traits.push(data.card)
			if player.cardNumber?
				player.cardNumber--
				if player.cardNumber == 0
					player.finished = true
			
		$scope.$apply()
		return

	io.on "player passed evolution", (data)->
		$scope.ec.playerPassedEvolution()
		# $scope.ec.currentPlayerId() = data.ec.currentPlayerId()
		$scope.$apply()
		return

	io.on "next player food", (data)->
		if data.previousPlayerId != $scope.playerId 	# if we are not the previous player
			player = $scope.players[data.previousPlayerId]
			player.species[data.specieIndex].foodEaten++
			
		# $scope.ec.currentPlayerId() = data.ec.currentPlayerId()
		$scope.$apply()
		return

	io.on "phase food", (data)->
		$scope.game.foodAmount = data.foodAmount
		for player in $scope.players
			player.finished = false
		
		for specie in $scope.player()
			$scope.checkCompatibleFood(specie)

		return

	io.on "error", (data)->
		console.log data
		return

	io.on "game error", (data)->
		console.log data
		return

	io.on "evolution error", (data)->
		$scope.players[data.ec.currentPlayerId()].species[data.specieId].traits.pop()
		console.log "ahah t'as perdu ta carte :D"
		return

	gameData = { gameId: (if localStorage.gameId? then parseInt(localStorage.gameId) else null), playerId: (if localStorage.playerId? then parseInt(localStorage.playerId) else null) }
	console.log gameData

	io.emit "load game", gameData

	return

