App.PageController = Ember.ObjectController.extend({
	queryParams : [ "params", "values", "prev" ],
	params : [],
	values : [],
	prev : [],

	actions : {
		logOutClick : function() {
			var controller = this;
			
			Ember.$.post("LogoutServlet").then(function(result) {
				controller.transitionToRoute("index");
			});
		}
	}
});