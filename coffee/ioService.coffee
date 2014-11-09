angular.module("IoService", []).service "io" , ()->

	this.io = io("http://localhost:3000/")
