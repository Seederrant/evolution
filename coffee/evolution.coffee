# Evolution.controller('EvolutionCtrl', ($scope) ->

angular.module('EvolutionApp').controller 'EvolutionCtrl', ($scope) ->

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

	$scope.end = ()->
		console.log "next player"