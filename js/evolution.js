(function() {
  angular.module('EvolutionApp').controller('EvolutionCtrl', function($scope, utils, io, EvolutionCommons) {
    var loadGame, scopeApply;
    $scope.selectedCard = null;
    scopeApply = function() {
      $scope.refreshIds();
      $scope.$apply();
    };
    $scope.refreshIds = function() {
      var card, i, j, k, l, len, len1, len2, len3, len4, m, n, o, p, player, ref, ref1, ref2, ref3, specie, trait;
      ref = $scope.ec.game.players;
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        player = ref[i];
        player.id = i;
        ref1 = player.species;
        for (j = m = 0, len1 = ref1.length; m < len1; j = ++m) {
          specie = ref1[j];
          specie.id = j;
          ref2 = specie.traits;
          for (k = n = 0, len2 = ref2.length; n < len2; k = ++n) {
            trait = ref2[k];
            trait.id = k;
          }
        }
        if (player.hand != null) {
          ref3 = player.hand;
          for (j = o = 0, len3 = ref3.length; o < len3; j = ++o) {
            card = ref3[j];
            card.id = j;
            for (k = p = 0, len4 = card.length; p < len4; k = ++p) {
              trait = card[k];
              trait.id = k;
            }
          }
        }
      }
    };
    $scope.isMyTurn = function() {
      return ($scope.ec != null) && $scope.ec.isPlayerTurn($scope.playerId);
    };
    $scope.isMyTurnAndEvolutionPhase = function() {
      return $scope.isMyTurn() && $scope.isEvolutionPhase();
    };
    $scope.canPassFoodAndFoodPhase = function() {
      return $scope.isFoodPhase() && $scope.ec.canPassFood();
    };
    $scope.showPassButton = function() {
      return $scope.isMyTurnAndEvolutionPhase() || $scope.canPassFoodAndFoodPhase();
    };
    $scope.isEvolutionPhase = function() {
      var ref;
      return ((ref = $scope.ec) != null ? ref.phase() : void 0) === 'Evolution';
    };
    $scope.isFoodPhase = function() {
      var ref;
      return ((ref = $scope.ec) != null ? ref.phase() : void 0) === 'Food';
    };
    $scope.isExtinctionPhase = function() {
      var ref;
      return ((ref = $scope.ec) != null ? ref.phase() : void 0) === 'Extinction';
    };
    $scope.me = function() {
      var ref;
      return (ref = $scope.ec) != null ? ref.player($scope.playerId) : void 0;
    };
    $scope.isMe = function(playerIndex) {
      return $scope.playerId === playerIndex;
    };
    $scope.passPhaseEvolution = function() {
      console.log("pass evolution");
      io.emit('pass phase evolution');
    };
    $scope.passPhaseFood = function() {
      console.log("pass food");
      io.emit('pass phase food');
    };
    $scope.passPhase = function() {
      switch ($scope.ec.phase()) {
        case 'Evolution':
          $scope.passPhaseEvolution();
          break;
        case 'Food':
          $scope.passPhaseFood();
      }
      $scope.refreshIds();
    };
    $scope.endTurnEvolution = function(specieIndex, addSpecie) {
      if (addSpecie == null) {
        addSpecie = false;
      }
      console.log("next player");
      io.emit('end turn evolution', {
        selectedCard: $scope.selectedCard,
        specieIndex: specieIndex,
        addSpecie: addSpecie
      });
      $scope.selectedCard = null;
    };
    $scope.hasCardSelected = function() {
      return $scope.selectedCard !== null;
    };
    $scope.selectCard = function(cardIndex, traitIndex) {
      var trait;
      if (!$scope.isMyTurn()) {
        return;
      }
      if ($scope.ec.phase() !== "Evolution") {
        return;
      }
      $scope.selectedCard = {
        cardIndex: cardIndex,
        traitIndex: traitIndex
      };
      trait = $scope.ec.card(cardIndex)[traitIndex];
      $scope.checkCompatibleEvolution(trait);
    };
    $scope.feedSpecie = function(specieIndex, playerId) {
      if ($scope.isMe(playerId) && $scope.ec.specie(specieIndex).compatible) {
        $scope.ec.feedSpecie(specieIndex);
        io.emit("end turn food", {
          specieIndex: specieIndex
        });
      }
    };
    $scope.useTrait = function(specieIndex, traitIndex, playerId) {
      if ($scope.ec.specie(specieIndex).compatible) {
        if ($scope.ec.useTrait(specieIndex, traitIndex, playerId) === "end turn") {
          io.emit("end turn food", {
            specieIndex: specieIndex
          });
        }
      }
    };
    $scope.checkCompatibleEvolution = function(card) {
      var l, len, ref, specie;
      ref = $scope.me().species;
      for (l = 0, len = ref.length; l < len; l++) {
        specie = ref[l];
        $scope.ec.checkCompatibleEvolution(specie, card);
      }
    };
    $scope.checkCompatibleFood = function() {
      var l, len, ref, specie;
      ref = $scope.me().species;
      for (l = 0, len = ref.length; l < len; l++) {
        specie = ref[l];
        $scope.ec.checkCompatibleFood(specie);
      }
    };
    $scope.isHighlightedSpecie = function(specie, playerId) {
      return specie.compatible || specie.eatable && $scope.isMyTurn();
    };
    $scope.isHighlightedTrait = function(trait, playerId) {
      return trait.compatible && playerId === $scope.playerId;
    };
    $scope.isHighlightedCardTrait = function(cardIndex, traitIndex) {
      var ref, ref1;
      return ((ref = $scope.selectedCard) != null ? ref.cardIndex : void 0) === cardIndex && ((ref1 = $scope.selectedCard) != null ? ref1.traitIndex : void 0) === traitIndex;
    };
    $scope.clearCompatible = function() {
      var l, len, len1, len2, m, n, player, ref, ref1, ref2, specie, trait;
      ref = $scope.ec.game.players;
      for (l = 0, len = ref.length; l < len; l++) {
        player = ref[l];
        ref1 = player.species;
        for (m = 0, len1 = ref1.length; m < len1; m++) {
          specie = ref1[m];
          specie.compatible = false;
          ref2 = specie.traits;
          for (n = 0, len2 = ref2.length; n < len2; n++) {
            trait = ref2[n];
            trait.compatible = false;
          }
        }
      }
    };
    $scope.selectSpecieEvolution = function(specieIndex, playerId) {
      var nextPhase;
      if ($scope.isMe(playerId) && $scope.ec.specie(specieIndex).compatible) {
        nextPhase = $scope.ec.addTrait(specieIndex, $scope.selectedCard);
        $scope.clearCompatible();
        $scope.endTurnEvolution(specieIndex);
      }
    };
    $scope.selectSpecie = function(specieIndex, playerId) {
      if (!$scope.isMyTurn()) {
        return;
      }
      switch ($scope.ec.phase()) {
        case 'Evolution':
          $scope.selectSpecieEvolution(specieIndex, playerId);
          break;
        case 'Food':
          $scope.feedSpecie(specieIndex, playerId);
      }
      $scope.refreshIds();
    };
    $scope.addSpecie = function() {
      $scope.ec.addSpecie($scope.selectedCard);
      $scope.clearCompatible();
      $scope.endTurnEvolution(-1, true);
    };
    $scope.currentPlayerClass = function(id) {
      var result;
      result = '';
      if (id === $scope.ec.currentPlayerId()) {
        result += 'currentPlayer';
      }
      if (id > $scope.playerId) {
        result += ' flex_order-1';
      }
      if ($scope.ec.game.players[id].finished) {
        result += ' finished';
      }
      return result;
    };
    loadGame = function() {
      var gameData;
      gameData = {
        gameId: (localStorage.gameId != null ? parseInt(localStorage.gameId) : null),
        playerId: (localStorage.playerId != null ? parseInt(localStorage.playerId) : null)
      };
      io.emit("load game", gameData);
    };
    $scope.restartGame = function() {
      io.emit("restart game");
    };
    $scope.initializeFoodPhase = function() {
      $scope.clearCompatible();
      $scope.checkCompatibleFood();
    };
    $scope.initializeEvolutionPhase = function() {};
    $scope.initializeGame = function() {
      switch ($scope.ec.phase()) {
        case 'Evolution':
          $scope.initializeEvolutionPhase();
          break;
        case 'Food':
          $scope.initializeFoodPhase();
      }
    };
    io.on("get id", function(data) {
      return localStorage;
    });
    io.on("connect", function() {
      loadGame();
    });
    io.on("evolution connect", function() {
      location.reload();
    });
    io.on("game loaded", function(data) {
      $scope.ec = new EvolutionCommons(data.game);
      console.log("Game: " + data.gameId + ", player: " + data.playerId);
      localStorage.setItem("playerId", data.playerId);
      localStorage.setItem("gameId", data.gameId);
      $scope.playerId = data.playerId;
      $scope.initializeGame();
      scopeApply();
    });
    io.on("next player evolution", function(data) {
      var player, previousPlayerId;
      previousPlayerId = $scope.ec.currentPlayerId();
      $scope.ec.nextPlayer();
      player = $scope.ec.game.players[previousPlayerId];
      if (!data.addSpecie) {
        player.species[data.specieIndex].traits.push({
          shortName: data.trait
        });
      } else {
        $scope.ec.createSpecie(player);
      }
      if (player.cardNumber != null) {
        player.cardNumber--;
        if (player.cardNumber === 0) {
          player.finished = true;
        }
      }
      scopeApply();
    });
    io.on("player passed evolution", function(data) {
      var nextPhase;
      nextPhase = $scope.ec.playerPassedEvolution();
      scopeApply();
    });
    io.on("next player food", function(data) {
      var nextPhase;
      console.log("next player food");
      nextPhase = $scope.ec.feedSpecie(data.specieIndex);
      $scope.clearCompatible();
      if (!nextPhase) {
        $scope.checkCompatibleFood();
      }
      scopeApply();
    });
    io.on("player passed food", function(data) {
      var nextPhase;
      nextPhase = $scope.ec.playerPassedFood();
      scopeApply();
    });
    io.on("phase food", function(data) {
      var l, len, player, ref;
      console.log("phase food");
      $scope.ec.game.foodAmount = data.foodAmount;
      ref = $scope.ec.game.players;
      for (l = 0, len = ref.length; l < len; l++) {
        player = ref[l];
        player.finished = false;
      }
      $scope.initializeFoodPhase();
      scopeApply();
    });
    io.on("phase evolution", function(data) {
      var i, l, len, player, ref;
      console.log("phase evolution");
      $scope.ec.clearExtinctedSpecies();
      $scope.me().hand = data.hand;
      $scope.ec.game.cardNumberInDeck = data.cardNumberInDeck;
      ref = $scope.ec.game.players;
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        player = ref[i];
        player.cardNumber = data.playersCardNumber[i];
      }
      scopeApply();
    });
    io.on("error", function(data) {
      console.log(data.description.stack);
      throw data;
    });
    io.on("game error", function(data) {
      console.log(data);
    });
    io.on("evolution error", function(data) {
      console.log(data);
      $scope.ec.players[$scope.ec.currentPlayerId()].species[data.specieId].traits.pop();
    });
  });

}).call(this);
