App.FormFrame = App.Frame.extend({
	data : null,

	updateOnDataSelectionCleared : function() {
		for (var i = 0; i < this.data.length; i++) {
			var dataRow = this.data[i];
			
			for(var j = 0; j < dataRow.length; j++) {

				dataRow[j].set("value", null);
			}
		}

		this.checkFrameEnabled();
	},

	parseFrame : function(frameJson) {
		this.parseFrameGenericData(frameJson);
		
		var dataRows = [];
		for (var i = 0; i < frameJson.formProperties.data.length; i++) {
			var dataRow = frameJson.formProperties.data[i];
			var fields = [];
			
			for(var j = 0; j < dataRow.length; j++) {
				var columnSpan = 2;
				
				var hiddenField = dataRow[j].hidden ? Boolean(dataRow[j].hidden) : false;
											
				if(dataRow[j].columnSpan  && !hiddenField){
					columnSpan = Number(dataRow[j].columnSpan);
				}
				
				fields.push(App.FormField.create({
					key : dataRow[j].key,
					label : dataRow[j].label,
					value : dataRow[j].value,
					columnSpan : columnSpan,
					hidden : hiddenField
				}));
			}
			
			dataRows.push(fields);
		}
		this.set("data", dataRows);
		
		this.resolveFrameDataInput();
	},

	getFrameData : function() {
		this.checkFrameEnabled();

		if(this.isEnabled){
			var frame = this;
			
			frame.set('loading', true);
			
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
					if(data.length > 0) {
						if(frame.isMainFrame){
							frame.page.set("mainFrameLoaded", true);							
						}
						
						data = data[0];
						for (var i = 0; i < frame.data.length; i++) {
							var dataRow = frame.data[i];
							
							for(var j = 0; j < dataRow.length; j++) {
								
								if(data[dataRow[j].key])
								{
									dataRow[j].set("value", data[dataRow[j].key]);
								}
								else
								{
									dataRow[j].set("value", "");
								}
							}
						}
					}
					else {
						if(frame.isMainFrame){
							frame.page.set("parametersError", "No hay información para los datos ingresados.");								
						}				
						
						for (var i = 0; i < frame.data.length; i++) {
							var dataRow = frame.data[i];
							
							for(var j = 0; j < dataRow.length; j++) {
								dataRow[j].set("value", "");
							}
						}
					}
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
		for (var i = 0; i < this.data.length; i++) {
			var attribute = this.data[i].filter(function(v) {
				return v["key"] === parameter;
			});

			if (attribute.length != 0) {
				if (attribute[0].value){
					return attribute[0].value;
				}else{
					//TODO: ver que hacer cuando existe el atributo pero no tiene valor, por ahora devolvemos vacio porque sino retorna 'undefined'
					return "";
				}
			}
		}
		
		return null;
	}
});