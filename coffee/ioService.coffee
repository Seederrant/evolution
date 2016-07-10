angular.module("IoService", []).service "io" , ()->

	this.io = io("http://192.168.0.10:3000/")
