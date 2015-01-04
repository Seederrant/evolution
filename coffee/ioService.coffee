angular.module("IoService", []).service "io" , ()->

	this.io = io("http://192.168.1.84:3000/")
