(function() {
  angular.module("IoService", []).service("io", function() {
    return this.io = io("http://192.168.1.30:3000/");
  });

}).call(this);
