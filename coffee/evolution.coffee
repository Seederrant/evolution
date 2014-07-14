# Evolution.controller('EvolutionCtrl', ($scope) ->

angular.module('EvolutionApp').controller 'EvolutionCtrl', ($scope, utils, io) ->

	$scope.phase = "Evolution"
	$scope.deck = { number: 40 }
	
	$scope.players = [ 
		{
			name: 'Edouard', 
			hand: [ { shortName:"intellect" }, { shortName:"carnivorous" }, { shortName:"vivaporous" }, { shortName:"tailLoss"} ],
			species: [ [], [ { name:"intellect", shortName:"intellect" }, { name:"carnivorous", cost:1, shortName:"intellect"} ] ]
		},
		{
			name: 'Jacob', 
			cardNumber: 5,
			species: [ [], [ { name:"tailLoss", shortName:"tailLoss" }, { name:"vivaporous", cost:1, shortName:"vivaporous"} ] ]
		},
		{
			name: 'Charlotte',
			cardNumber: 2,
			species: [ [], [ { name:"tailLoss", shortName:"tailLoss" } ] ]
		} 
	]

	$scope.player = ()->
		return $scope.players[0]

	$scope.end = (card, specie)->
		console.log "next player"
		socket.emit('end turn', {card: card, specie: specie})

	$scope.selectedCard = ()->
		for card in $scope.player().hand
			if card.selected then return card
		return

	$scope.selectCard = (card)->
		$scope.selectedCard()?.selected = false
		card.selected = true
		$scope.checkCompatible(card)

	$scope.checkCompatible = (card)->
		for specie in $scope.player().species
			specie.compatible = false
			# check
			specie.compatible = true

	$scope.selectSpecie = (specie)->
		if specie.compatible
			card = $scope.selectedCard()
			$scope.player().hand.remove(card)
			specie.push(card)
			$scope.end(card, specie)



