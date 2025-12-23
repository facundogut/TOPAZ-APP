App.FrameLinksView = Ember.View.extend({
	didInsertElement : function() {
		this._super();
		var data = this.get('context');

		if (data.links && data.constructor.toString() != "App.GridFrame") {
			menuLinks = [];

			var controller = this.get('controller');
			var page = controller.get('model');

			for (var i = 0; i < data.links.length; i++) {
				var link = data.links[i];
				
				var linkEnabled = this.linkEnabled(link, data.id,  data.page);				
				
				if(linkEnabled){
					menuLinks.push({
						title : link.name,
						name : link.name,
						linkTo : link.to,
						frameId : data.id,
						parameters : link.parameters,
						fun : function(event) {
							var link = event.data;
	
							var disabled = disabledPages.filter(function(v) {return v === link.linkTo;});

							if (disabled.length != 0) {
								show_disabledPageModal();
							}
							else{
								var parameters = [];
								var values = [];
								for (var j = 0; j < link.parameters.length; j++) {
									var parameter = link.parameters[j];
									parameters.push('\"' + parameter + '\"');
		
									var value = page.getParameterValue(parameter, link.frameId);
									values.push('\"' + value + '\"');
								}
		
								var prevPages = "\"" + page.getPreviousPagesAndCurrentData() + "\"";
		
								controller.transitionToRoute("/" + link.linkTo + "?params=[" + parameters.toString() + "]&values=[" + values.toString() + "]&prev=" + prevPages);
							}
						}
					});
				}
			}

			var params = [];
			params.push(this);
			params.push(menuLinks);

			Ember.run.scheduleOnce('afterRender', params, function() {
				var context = this[0];
				var links = this[1];

				var element = context.get('element');
				$(element).find('.btnLinks').contextMenu(links);
			});
		}
	},
	
	linkEnabled : function(link, frameId, page){
		try{
			if(link.enabledData){
				var condition = link.enabledData.condition;
				
				if(link.enabledData.parameters){
					for(var j=0; j < link.enabledData.parameters.length; j++)
					{
						var enabledParameter = link.enabledData.parameters[j];
						var value = page.getParameterValue(enabledParameter, frameId);
						
						condition = condition.replace('#' + enabledParameter, "'" + value + "'");
					}
				}
				
				return eval(condition);	
			}
			else{
				return true;
			}
		}
		catch(e)
		{
			App.ErrorManager.create().setLinkVisibilityError(link.name, frameId, link.enabledData.condition, page);
		
			return false;
		}
	}
});