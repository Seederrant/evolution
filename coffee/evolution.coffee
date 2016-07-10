# Todo: highlight passed
# todo: deactivate pass button after one click !! reactivate later

# Evolution.controller('EvolutionCtrl', ($scope) ->

angular.module('EvolutionApp').controller 'EvolutionCtrl', ($scope, utils, io, EvolutionCommons) ->

	$scope.selectedCard = null


	scopeApply = ()->
		$scope.refreshIds()
		$scope.$apply()
		return

	#dirty mother fucking angular shit hack
	$scope.refreshIds = ()->
		for player, i in $scope.ec.game.players
			player.id = i
			for specie, j in player.species
				specie.id = j
				for trait, k in specie.traits
					trait.id = k
			if player.hand?
				for card, j in player.hand
					card.id = j
					for trait, k in card
						trait.id = k
		return

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

		$scope.refreshIds()
		return

	$scope.endTurnEvolution = (specieIndex, addSpecie=false)->
		console.log "next player"
		io.emit('end turn evolution', {selectedCard: $scope.selectedCard, specieIndex: specieIndex, addSpecie: addSpecie})
		$scope.selectedCard = null
		return

	# $scope.selectedCard = ()->
	# 	for card, i in $scope.me().hand
	# 		if card.selected != -1 then return { cardIndex: i, traitIndex: card.selected }
	# 	return null

	$scope.hasCardSelected = ()->
		return $scope.selectedCard != null

	$scope.selectCard = (cardIndex, traitIndex)->
		if not $scope.isMyTurn() then return
		if $scope.ec.phase() != "Evolution" then return
		$scope.selectedCard = { cardIndex: cardIndex, traitIndex: traitIndex }
		trait = $scope.ec.card(cardIndex)[ traitIndex ]
		$scope.checkCompatibleEvolution(trait)
		return

	$scope.feedSpecie = (specieIndex, playerId)->
		if $scope.isMe(playerId) and $scope.ec.specie(specieIndex).compatible
			$scope.ec.feedSpecie(specieIndex)
			io.emit "end turn food", { specieIndex: specieIndex }
		return

	$scope.useTrait = (specieIndex, traitIndex, playerId)->
		if $scope.ec.specie(specieIndex).compatible
			if $scope.ec.useTrait(specieIndex, traitIndex, playerId) == "end turn"
				io.emit "end turn food", { specieIndex: specieIndex }
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
		return specie.compatible or specie.eatable and $scope.isMyTurn()

	# Check is trait must be highlighted(we can feed it or we can use it) and it is our card
	$scope.isHighlightedTrait = (trait, playerId)->
		return trait.compatible and playerId == $scope.playerId

	$scope.isHighlightedCardTrait = (cardIndex, traitIndex)->
		return $scope.selectedCard?.cardIndex == cardIndex and $scope.selectedCard?.traitIndex == traitIndex

	$scope.clearCompatible = ()->
		for player in $scope.ec.game.players
			for specie in player.species
				specie.compatible = false
				for trait in specie.traits
					trait.compatible = false
		return

	# --- play trait/ --- #

	$scope.selectSpecieEvolution = (specieIndex, playerId)->
		if $scope.isMe(playerId) and $scope.ec.specie(specieIndex).compatible
			nextPhase = $scope.ec.addTrait(specieIndex, $scope.selectedCard)
			$scope.clearCompatible()
			$scope.endTurnEvolution(specieIndex)
		return

	$scope.selectSpecie = (specieIndex, playerId)->
		if not $scope.isMyTurn() then return
		switch $scope.ec.phase()
			when 'Evolution'
				$scope.selectSpecieEvolution(specieIndex, playerId)
			when 'Food'
				# using trait carnivorous
				$scope.feedSpecie(specieIndex, playerId)

		$scope.refreshIds()
		return

	$scope.addSpecie = ()->
		$scope.ec.addSpecie($scope.selectedCard)
		$scope.clearCompatible()
		$scope.endTurnEvolution(-1, true)
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

		scopeApply()
		return

	# pass to next player only for other players (not for the one who just played, since we passed when we play the card before sending to server)
	io.on "next player evolution", (data)->
		previousPlayerId = $scope.ec.currentPlayerId()
		# if previousPlayerId != $scope.playerId 	# if we are not the previous player
		$scope.ec.nextPlayer()
		player = $scope.ec.game.players[previousPlayerId]
		if not data.addSpecie
			player.species[data.specieIndex].traits.push({ shortName: data.trait })
		else
			$scope.ec.createSpecie(player)
		if player.cardNumber?
			player.cardNumber--
			if player.cardNumber == 0
				player.finished = true

		scopeApply()
		return

	io.on "player passed evolution", (data)->
		nextPhase = $scope.ec.playerPassedEvolution()

		scopeApply()
		return

	io.on "next player food", (data)->
		console.log "next player food"
		nextPhase = $scope.ec.feedSpecie(data.specieIndex)
		$scope.clearCompatible()
		if not nextPhase then $scope.checkCompatibleFood()

		scopeApply()
		return

	io.on "player passed food", (data)->
		nextPhase = $scope.ec.playerPassedFood()

		scopeApply()
		return

	io.on "phase food", (data)->
		console.log "phase food"
		$scope.ec.game.foodAmount = data.foodAmount

		for player in $scope.ec.game.players
			player.finished = false

		$scope.initializeFoodPhase()

		scopeApply()
		return

	io.on "phase evolution", (data)->
		console.log "phase evolution"
		$scope.ec.clearExtinctedSpecies()
		$scope.me().hand = data.hand
		$scope.ec.game.cardNumberInDeck = data.cardNumberInDeck
		for player, i in $scope.ec.game.players
			player.cardNumber = data.playersCardNumber[i]

		scopeApply()
		return

	io.on "error", (data)->
		console.log data.description.stack
		throw data
		return

	io.on "game error", (data)->
		console.log data
		return

	io.on "evolution error", (data)->
		console.log data
		$scope.ec.players[$scope.ec.currentPlayerId()].species[data.specieId].traits.pop()
		return

	return
