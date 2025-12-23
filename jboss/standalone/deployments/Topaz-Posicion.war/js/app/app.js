App.initializer({
    name: 'app',
	initialize: function(container, application) {
        application.register('constants:main', App.Constants, {
            singleton: true,
            instantiate: true
        });

        application.inject('model', 'const', 'constants:main');
        application.inject('controller', 'const', 'constants:main');
        application.inject('view', 'const', 'constants:main');
    }
});

App.Router.map(function() {
	this.resource("page", {
		path : ":page_id"
	});
});

App.PageRoute = Ember.Route.extend({
	queryParams : {
		values : {
			refreshModel : true
		},
		params : {
			refreshModel : true
		}
	},

	model : function(params) {
		var pageId = params['page_id'];

		var paramsIds = params['params'];
		var values = params['values'];
		var parameters = {};
		for (var i = 0; i < values.length; i++) {
			parameters[paramsIds[i]] = values[i];
		}

		var route = this;

		var page = App.Page.create({
			id : pageId
		});

		return page.getData(parameters, params['prev']).then(function(resultOK) {
			if (resultOK) {
				return page;
			} else {
				route.transitionTo("index");
			}
		});
	}
});