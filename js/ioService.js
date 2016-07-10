(function() {
  angular.module("IoService", []).service("io", function() {
    return this.io = io("http://192.168.0.10:3000/");
  });

}).call(this);
