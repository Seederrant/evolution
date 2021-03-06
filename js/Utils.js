(function() {
  angular.module('UtilsService', []).service('utils', function() {
    this.getTime = function() {
      return new Date().getTime();
    };
    this.sign = function(x) {
      if (typeof x === "number") {
        if (x) {
          if (x < 0) {
            return -1;
          } else {
            return 1;
          }
        } else {
          if (x === x) {
            return 0;
          } else {
            return NaN;
          }
        }
      } else {
        return NaN;
      }
    };
    Array.prototype.remove = function(itemToRemove) {
      return this.splice(this.indexOf(itemToRemove), 1);
    };
    Array.prototype.first = function() {
      return this[0];
    };
    Array.prototype.last = function() {
      return this[this.length - 1];
    };
    return Array.prototype.random = function() {
      return this[Math.floor(Math.random() * this.length)];
    };
  });

}).call(this);
