# Todo: highlight passed
# todo: deactivate pass button after one click !! reactivate later

# Evolution.controller('EvolutionCtrl', ($scope) ->

angular.module('EvolutionApp').controller 'EvolutionCtrl', ($scope, utils, io, EvolutionCommons) ->

	$scope.isMyTurn = ()->
		return $scope.ec? and $scope.ec.isPlayerTurn( $scope.playerId )

	$scope.isMyTurnAndEvolutionPhase = ()->
		return $scope.isMyTurn() and $scope.isEvolutionPhase()

	$scope.canPassFoodAndFoodPhase = ()->
		return $scope.isFoodPhase() and $scope.ec.canPassFood()

	$scope.showPassButton = ()->
		return $scope.isMyTurnAndEvolutionPhase() or $scope.canPassFoodAndFoodPhase()

	$scope.isEvolutionPhase = ()->
		return $scope.ec?.phase() == 'Evolution'

	$scope.isFoodPhase = ()->
		return $scope.ec?.phase() == 'Food'

	$scope.isExtinctionPhase = ()->
		return $scope.ec?.phase() == 'Extinction'

	$scope.me = ()->
		return $scope.ec?.player($scope.playerId)

	# check if playerIndex corresponds to me (used in ng-repeat in index.html)
	$scope.isMe = (playerIndex)->
		return $scope.playerId == playerIndex

	$scope.passPhaseEvolution = ()->
		console.log "pass evolution"
		io.emit('pass phase evolution')
		return

	$scope.passPhaseFood = ()->
		console.log "pass food"
		io.emit('pass phase food')
		return

	$scope.passPhase = ()->
		switch $scope.ec.phase()
			when 'Evolution'
				$scope.passPhaseEvolution()
			when 'Food'
				$scope.passPhaseFood()
		return

	$scope.endTurnEvolution = (cardIndex, specieIndex, addSpecie=false)->
		console.log "next player"
		console.log cardIndex
		io.emit('end turn evolution', {cardIndex: cardIndex, specieIndex: specieIndex, addSpecie: addSpecie})
		return

	$scope.selectedCard = ()->
		for card, i in $scope.me().hand
			if card.selected then return i
		return null

	$scope.hasCardSelected = ()->
		return $scope.selectedCard() != null

	$scope.selectCard = (cardIndex)->
		if not $scope.isMyTurn() then return
		if $scope.ec.phase() != "Evolution" then return
		$scope.ec.card($scope.selectedCard())?.selected = false
		card = $scope.ec.card(cardIndex)
		card.selected = true
		$scope.checkCompatibleEvolution(card)
		return

	$scope.feedSpecie = (specieIndex)->
		if $scope.ec.specie(specieIndex).compatible 
			$scope.ec.feedSpecie(specieIndex)
			io.emit "end turn food", { specieIndex: specieIndex}
		return

	$scope.useTrait = (specieIndex, traitIndex)->

		return

	$scope.checkCompatibleEvolution = (card)->
		for specie in $scope.me().species
			$scope.ec.checkCompatibleEvolution(specie, card)
		return

	$scope.checkCompatibleFood = ()->
		for specie in $scope.me().species
			$scope.ec.checkCompatibleFood(specie)
		return

	# Check is specie must be highlighted (we can feed it or we can use it) and it is our card	
	$scope.isHighlightedSpecie = (specie, playerId)->
		return specie.compatible and $scope.isMyTurn()

	# Check is trait must be highlighted(we can feed it or we can use it) and it is our card
	$scope.isHighlightedTrait = (trait, playerId)->
		return trait.compatible and playerId == $scope.playerId

	$scope.clearCompatible = ()->
		for player in $scope.ec.game.players
			for specie in player.species
				specie.compatible = false
		return

	# --- play trait/ --- #

	$scope.selectSpecieEvolution = (specieIndex)->
		if $scope.ec.specie(specieIndex).compatible
			cardIndex = $scope.selectedCard()
			nextPhase = $scope.ec.addTrait(specieIndex, cardIndex)
			$scope.clearCompatible()
			$scope.endTurnEvolution(cardIndex, specieIndex)
		return

	$scope.selectSpecie = (specieIndex)->
		if not $scope.isMyTurn() then return
		switch $scope.ec.phase()
			when 'Evolution'
				$scope.selectSpecieEvolution(specieIndex)
			when 'Food'
				$scope.feedSpecie(specieIndex)
		return

	$scope.addSpecie = (cardIndex)->
		$scope.ec.addSpecie(cardIndex)
		$scope.clearCompatible()
		$scope.endTurnEvolution(cardIndex, -1, true)
		return
	
	# --- /play trait --- #

	$scope.currentPlayerClass = (id)->
		result = ''
		if id == $scope.ec.currentPlayerId()
			result += 'currentPlayer'
		if id > $scope.playerId
			result += ' flex_order-1'
		if $scope.ec.game.players[id].finished
			result += ' finished'
		return result

	loadGame = ()->
		gameData = { gameId: (if localStorage.gameId? then parseInt(localStorage.gameId) else null), playerId: (if localStorage.playerId? then parseInt(localStorage.playerId) else null) }
		io.emit "load game", gameData
		return

	$scope.restartGame = ()->
		io.emit "restart game"
		return

	$scope.initializeFoodPhase = ()->
		$scope.clearCompatible()
		$scope.checkCompatibleFood()
		return

	$scope.initializeEvolutionPhase = ()->
		return

	$scope.initializeGame = ()->
		switch $scope.ec.phase()
			when 'Evolution'
				$scope.initializeEvolutionPhase()
			when 'Food'
				$scope.initializeFoodPhase()
		return

	io.on "get id", (data)->
		localStorage

	io.on "connect", ()->
		loadGame()
		return
	
	io.on "evolution connect", ()->
		location.reload()
		return

	io.on "game loaded", (data)->
		$scope.ec = new EvolutionCommons(data.game)
		console.log "Game: " + data.gameId + ", player: " + data.playerId
		localStorage.setItem("playerId", data.playerId)
		localStorage.setItem("gameId", data.gameId)
		# localStorage.gameId = data.gameId

		$scope.playerId = data.playerId
		$scope.initializeGame()
		$scope.$apply()
		return

	# pass to next player only for other players (not for the one who just played, since we passed when we play the card before sending to server)
	io.on "next player evolution", (data)->
		previousPlayerId = $scope.ec.currentPlayerId()
		# if previousPlayerId != $scope.playerId 	# if we are not the previous player
		$scope.ec.nextPlayer()
		player = $scope.ec.game.players[previousPlayerId]
		if not data.addSpecie
			player.species[data.specieIndex].traits.push(data.card)
		else
			$scope.ec.createSpecie(player)
		if player.cardNumber?
			player.cardNumber--
			if player.cardNumber == 0
				player.finished = true
		$scope.$apply()
		return

	io.on "player passed evolution", (data)->
		nextPhase = $scope.ec.playerPassedEvolution()
		$scope.$apply()
		return

	io.on "next player food", (data)->
		console.log "next player food"
		nextPhase = $scope.ec.feedSpecie(data.specieIndex)
		$scope.clearCompatible()
		if not nextPhase then $scope.checkCompatibleFood()
		$scope.$apply()
		return

	io.on "player passed food", (data)->
		nextPhase = $scope.ec.playerPassedFood()
		$scope.$apply()
		return

	io.on "phase food", (data)->
		console.log "phase food"
		$scope.ec.game.foodAmount = data.foodAmount

		for player in $scope.ec.game.players
			player.finished = false
		
		$scope.initializeFoodPhase()

		$scope.$apply()
		return

	io.on "phase evolution", (data)->
		console.log "phase evolution"
		$scope.ec.clearExtinctedSpecies()
		$scope.me().hand = data.hand
		$scope.ec.game.deck.number = data.number
		for player, i in $scope.ec.game.players
			player.cardNumber = data.playersCardNumber[i]
		$scope.$apply()
		return

	io.on "error", (data)->
		console.log data.description.stack
		throw data
		return

	io.on "game error", (data)->
		console.log data
		return

	io.on "evolution error", (data)->
		$scope.ec.players[data.ec.currentPlayerId()].species[data.specieId].traits.pop()
		console.log "ahah t'as perdu ta carte :D"
		return

	return

