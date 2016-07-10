(function() {
  var EvolutionCommons;

  EvolutionCommons = (function() {
    function EvolutionCommons(game) {
      this.game = game;
      this.phases = ["Evolution", "Food"];
      this.cards = [
        {
          number: 8,
          traits: ['swimming']
        }, {
          number: 2,
          traits: ['swimming', 'ambushHunting']
        }, {
          number: 2,
          traits: ['swimming', 'vivaporous']
        }, {
          number: 4,
          traits: ['carnivorous', 'poisonous']
        }, {
          number: 4,
          traits: ['carnivorous', 'parasite']
        }, {
          number: 2,
          traits: ['carnivorous', 'metamorphosis']
        }, {
          number: 2,
          traits: ['carnivorous', 'flight']
        }, {
          number: 4,
          traits: ['carnivorous', 'communication']
        }, {
          number: 4,
          traits: ['carnivorous', 'highBodyWeight']
        }, {
          number: 4,
          traits: ['carnivorous', 'cooperation']
        }, {
          number: 4,
          traits: ['anglerFish']
        }, {
          number: 4,
          traits: ['carnivorous', 'hibernationAbility']
        }, {
          number: 2,
          traits: ['fatTissue', 'trematode']
        }, {
          number: 4,
          traits: ['fatTissue', 'camouflage']
        }, {
          number: 4,
          traits: ['fatTissue', 'parasite']
        }, {
          number: 4,
          traits: ['fatTissue', 'cooperation']
        }, {
          number: 4,
          traits: ['fatTissue', 'burrowing']
        }, {
          number: 2,
          traits: ['fatTissue', 'intellect']
        }, {
          number: 4,
          traits: ['fatTissue', 'highBodyWeight']
        }, {
          number: 4,
          traits: ['fatTissue', 'sharpVision']
        }, {
          number: 4,
          traits: ['fatTissue', 'grazing']
        }, {
          number: 2,
          traits: ['specializationA', 'flight']
        }, {
          number: 2,
          traits: ['specializationA', 'metamorphosis']
        }, {
          number: 2,
          traits: ['specializationA', 'intellect']
        }, {
          number: 2,
          traits: ['specializationB', 'flight']
        }, {
          number: 2,
          traits: ['specializationB', 'vivaporous']
        }, {
          number: 2,
          traits: ['specializationB', 'ambushHunting']
        }, {
          number: 4,
          traits: ['shell']
        }, {
          number: 4,
          traits: ['inkCloud']
        }, {
          number: 4,
          traits: ['scavenger']
        }, {
          number: 4,
          traits: ['piracy']
        }, {
          number: 4,
          traits: ['running']
        }, {
          number: 4,
          traits: ['tailLoss']
        }, {
          number: 4,
          traits: ['mimicry']
        }, {
          number: 4,
          traits: ['symbiosis']
        }, {
          number: 4,
          traits: ['trematode', 'cooperation']
        }, {
          number: 4,
          traits: ['trematode', 'communication']
        }
      ];
      this.traits = {
        swimming: {
          canBeEatenBy: (function(_this) {
            return function(specie, carnivorousSpecie) {
              return _this.hasTrait(carnivorousSpecie, "swimming");
            };
          })(this)
        },
        running: {
          attackSuccesful: function(specie) {
            return Math.random() > 0.5;
          }
        },
        mimicry: {},
        scavenger: {},
        symbiosis: {},
        piracy: {},
        tailLoss: {},
        communication: {},
        grazing: {},
        highBodyWeight: {
          cost: 1
        },
        hibernationAbility: {},
        poisonous: {},
        cooperation: {},
        burrowing: {},
        camouflage: {
          canBeEatenBy: (function(_this) {
            return function(specie, carnivorousSpecie) {
              return _this.hasTrait(carnivorousSpecie, "sharpVision");
            };
          })(this)
        },
        sharpVision: {},
        carnivorous: {
          cost: 1
        },
        fatTissue: {},
        parasite: {
          cost: 2
        },
        shell: {},
        intellect: {
          cost: 1
        },
        anglerFish: {},
        specializationA: {},
        specializationB: {},
        trematode: {
          cost: 1
        },
        metamorphosis: {},
        inkCloud: {},
        vivaporous: {
          cost: 1
        },
        ambushHunting: {},
        flight: {
          canBeEatenBy: function(specie, carnivorousSpecie) {
            return carnivorousSpecie.traits.length < specie.traits.length;
          }
        }
      };
      return;
    }

    EvolutionCommons.prototype.isPlayerTurn = function(playerId) {
      return this.currentPlayerId() === playerId;
    };

    EvolutionCommons.prototype.currentPlayer = function() {
      return this.game.players[this.currentPlayerId()];
    };

    EvolutionCommons.prototype.player = function(index) {
      return this.game.players[index];
    };

    EvolutionCommons.prototype.currentPlayerId = function() {
      return this.game.currentPlayerId;
    };

    EvolutionCommons.prototype.foodAmountRequired = function(specie) {
      var cost, j, len, ref, trait, traitCost;
      cost = 1;
      ref = specie.traits;
      for (j = 0, len = ref.length; j < len; j++) {
        trait = ref[j];
        traitCost = this.traits[trait.shortName].cost;
        if (traitCost != null) {
          cost += traitCost;
        }
      }
      return cost;
    };

    EvolutionCommons.prototype.isFed = function(specie) {
      return specie.foodEaten === this.foodAmountRequired(specie);
    };

    EvolutionCommons.prototype.checkCompatibleEvolution = function(specie, card, addSpecie) {
      specie.compatible = true;
    };

    EvolutionCommons.prototype.checkCompatibleFood = function(specie) {
      var finished, hasCompatibleTrait, j, len, ref, specieFed, trait;
      specieFed = this.isFed(specie);
      if (!specieFed && this.game.foodAmount > 0) {
        specie.compatible = true;
      } else {
        specie.compatible = false;
      }
      finished = specieFed || this.game.foodAmount === 0;
      hasCompatibleTrait = false;
      ref = specie.traits;
      for (j = 0, len = ref.length; j < len; j++) {
        trait = ref[j];
        trait.compatible = false;
        switch (trait.shortName) {
          case 'grazing':
            if (!trait.used && this.game.foodAmount > 0) {
              trait.compatible = true;
            }
            break;
          case 'carnivorous':
            if (!trait.used && !this.isFed(specie)) {
              trait.compatible = true;
            }
            break;
          case 'fatTissue':
            if (!trait.used && this.isFed(specie) && this.game.foodAmount > 0) {
              trait.compatible = true;
            }
        }
        hasCompatibleTrait = hasCompatibleTrait || trait.compatible;
      }
      finished = finished && !hasCompatibleTrait;
      specie.finished = finished;
    };

    EvolutionCommons.prototype.checkPlayerFinishedFood = function() {
      var j, len, player, ref, specie;
      player = this.currentPlayer();
      ref = player.species;
      for (j = 0, len = ref.length; j < len; j++) {
        specie = ref[j];
        if (!specie.finished) {
          return;
        }
      }
      player.finished = true;
    };

    EvolutionCommons.prototype.canPassFood = function() {
      var j, len, player, ref, specie;
      player = this.currentPlayer();
      if (player.finished) {
        return false;
      }
      if (this.game.foodAmount === 0) {
        return true;
      }
      ref = player.species;
      for (j = 0, len = ref.length; j < len; j++) {
        specie = ref[j];
        if (!this.isFed(specie)) {
          return false;
        }
      }
      return true;
    };

    EvolutionCommons.prototype.card = function(cardIndex) {
      return this.currentPlayer().hand[cardIndex];
    };

    EvolutionCommons.prototype.specie = function(specieIndex, playerId) {
      if (playerId == null) {
        playerId = this.currentPlayerId();
      }
      return this.player(playerId).species[specieIndex];
    };

    EvolutionCommons.prototype.feedSpecie = function(specieIndex, playerId) {
      var specie;
      if (playerId == null) {
        playerId = this.currentPlayerId();
      }
      specie = this.specie(specieIndex, playerId);
      specie.foodEaten++;
      this.game.foodAmount--;
      this.checkCompatibleFood(specie);
      this.checkPlayerFinishedFood();
      return this.nextPlayer();
    };

    EvolutionCommons.prototype.setSpecieEatable = function(specie, carnivorousSpecie) {
      var j, len, ref, trait, traitDescription;
      ref = specie.traits;
      for (j = 0, len = ref.length; j < len; j++) {
        trait = ref[j];
        traitDescription = this.traits[trait.shortName];
        if ((traitDescription.canBeEatenBy != null) && !traitDescription.canBeEatenBy(specie, carnivorousSpecie)) {
          specie.eatable = false;
          return;
        }
      }
      specie.eatable = true;
    };

    EvolutionCommons.prototype.checkEatable = function(playerId, carnivorousSpecie) {
      var i, j, k, len, len1, player, ref, ref1, specie;
      if (playerId == null) {
        playerId = this.currentPlayerId();
      }
      ref = this.game.players;
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        player = ref[i];
        if (i !== playerId) {
          ref1 = player.species;
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            specie = ref1[k];
            this.setSpecieEatable(specie, carnivorousSpecie);
          }
        }
      }
    };

    EvolutionCommons.prototype.useTrait = function(specieIndex, traitIndex, playerId) {
      var specie, trait;
      specie = this.specie(specieIndex, playerId);
      trait = specie.traits[traitIndex];
      switch (trait.shortName) {
        case 'carnivorous':
          trait.compatible = false;
          this.checkEatable(specie);
      }
    };

    EvolutionCommons.prototype.createSpecie = function(player) {
      if (player == null) {
        player = this.currentPlayer();
      }
      player.species.push({
        traits: [],
        foodEaten: 0
      });
    };

    EvolutionCommons.prototype.addSpecie = function(selectedCard) {
      var card, player;
      player = this.currentPlayer();
      card = player.hand.splice(selectedCard.cardIndex, 1)[0];
      this.createSpecie(player);
      if (player.hand.length === 0) {
        player.finished = true;
      }
      return this.nextPlayer();
    };

    EvolutionCommons.prototype.hasTrait = function(specie, traitShortName) {
      var j, len, ref, trait;
      ref = specie.traits;
      for (j = 0, len = ref.length; j < len; j++) {
        trait = ref[j];
        if (trait.shortName === traitShortName) {
          return true;
        }
      }
      return false;
    };

    EvolutionCommons.prototype.addTrait = function(specieIndex, selectedCard) {
      var player, trait;
      player = this.currentPlayer();
      trait = player.hand.splice(selectedCard.cardIndex, 1)[0][selectedCard.traitIndex];
      if (player.hand.length === 0) {
        player.finished = true;
      }
      this.specie(specieIndex).traits.push({
        shortName: trait
      });
      return this.nextPlayer();
    };

    EvolutionCommons.prototype.playerPassedEvolution = function() {
      var player;
      player = this.currentPlayer();
      player.finished = true;
      return this.nextPlayer();
    };

    EvolutionCommons.prototype.playerPassedFood = function() {
      var player;
      player = this.currentPlayer();
      player.finished = true;
      return this.nextPlayer();
    };

    EvolutionCommons.prototype.nextPlayer = function() {
      var i, players;
      i = 0;
      players = this.game.players;
      while (i < players.length) {
        this.game.currentPlayerId = (this.game.currentPlayerId + 1) % players.length;
        if (!this.player(this.game.currentPlayerId).finished) {
          break;
        }
        i++;
      }
      console.log(this.game.currentPlayerId);
      if (i === players.length) {
        this.game.currentPlayerId = this.game.firstPlayerId;
        this.nextPhase();
        return true;
      }
      return false;
    };

    EvolutionCommons.prototype.phase = function() {
      return this.phases[this.game.phaseIndex];
    };

    EvolutionCommons.prototype.extinctSpecies = function() {
      var j, k, len, len1, player, ref, ref1, specie;
      ref = this.game.players;
      for (j = 0, len = ref.length; j < len; j++) {
        player = ref[j];
        ref1 = player.species;
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          specie = ref1[k];
          if (!this.isFed(specie)) {
            specie.extinct = true;
          }
        }
      }
      this.phaseIndex = 0;
    };

    EvolutionCommons.prototype.clearExtinctedSpecies = function() {
      var i, j, len, player, ref, specie;
      ref = this.game.players;
      for (j = 0, len = ref.length; j < len; j++) {
        player = ref[j];
        i = player.species.length - 1;
        while (i >= 0) {
          specie = player.species[i];
          specie.foodEaten = 0;
          if (specie.extinct) {
            player.species.splice(i, 1);
          }
          i--;
        }
      }
    };

    EvolutionCommons.prototype.nextPhase = function() {
      var j, len, player, ref;
      this.game.phaseIndex = (this.game.phaseIndex + 1) % this.phases.length;
      ref = this.game.players;
      for (j = 0, len = ref.length; j < len; j++) {
        player = ref[j];
        player.finished = false;
      }
      switch (this.phase()) {
        case "Evolution":
          this.extinctSpecies();
          this.game.foodAmount = null;
          this.game.firstPlayerId = (this.game.firstPlayerId + 1) % this.game.players.length;
          this.game.currentPlayerId = this.game.firstPlayerId;
      }
    };

    return EvolutionCommons;

  })();

  if (typeof module !== "undefined" && module !== null) {
    module.exports = EvolutionCommons;
  }

  if (typeof angular !== "undefined" && angular !== null) {
    angular.module("EvolutionCommonsService", []).service("EvolutionCommons", function() {
      return this.EvolutionCommons = EvolutionCommons;
    });
  }

}).call(this);
