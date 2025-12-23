
App.ImagesFrame = App.Frame.extend({
	data : null,

	updateOnDataSelectionCleared : function() {
		this.set("data", null);
		this.checkFrameEnabled();
	},
	
	parseFrame : function (frameJson){
		this.parseFrameGenericData(frameJson);
		
		this.resolveFrameDataInput();
	},
	
	getFrameData : function() {
		this.checkFrameEnabled();

		if(this.isEnabled){
			var frame = this;
			frame.set('loading', true);
			
			var controller = this.get('controller');
			
			var parameters = this.getInputParameters();		

			Ember.$.post(this.page.dataServiceUrl, {
				"service" : frame.input.service,
				"serviceType" : "simple",
				"parameters" : parameters.ids,
				"values" : parameters.values
			}).then(function(response) {
				try{
					var data = jQuery.parseJSON(response);
				}
				catch(e)
				{
					App.ErrorManager.create().setFrameParseError(frame.id, response, frame.page);
					frame.set('loading', false);
					return;
				}

				try{		
					var galleryLength = 6;
					
					var dataValues = [];
					var images = [];
					
					for (var i = 0; i < data.length; i++) {
						var imageName = data[i].FILENAME;
						
						images.push(imageName);
		
						if((i+1) % galleryLength === 0){
							dataValues.push(images);					
							images = [];
						}
					}
					
					if(images.length > 0){
						dataValues.push(images);	
					}
					
					frame.set('data', dataValues);		
				}
				catch(e)
				{
					App.ErrorManager.create().setFrameDataError(frame.id, response, frame.page);	
				}

				frame.set('loading', false);
			});
		}
	},

	getParameterValue : function(parameter){
		return null;
	}
});