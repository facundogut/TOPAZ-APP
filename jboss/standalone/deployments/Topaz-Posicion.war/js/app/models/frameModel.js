App.Frame = Ember.Object.extend({
	id : null,
	title : null,
	iconImage : null,
	loading : true,
	service : null,
	links : null,
	page : null,
	isCollapsed:false,
	isEnabled:false,
	enabledData: null,
	
	parseFrameGenericData : function(frameJson){		
		var links = null;
		if (frameJson.links) {
			links = [];

			for (var j = 0; j < frameJson.links.length; j++) {
				var link = App.Link.create({
					name : frameJson.links[j].name,
					to : frameJson.links[j].to,
					parameters : frameJson.links[j].parameters,
					enabledData : frameJson.links[j].enabled ? frameJson.links[j].enabled : null
				});

				links.push(link);
			}
		}

		this.set("id", frameJson.id);
		this.set("title", frameJson.title);
		this.set("input", frameJson.input);
		var isMainFrame = frameJson.mainFrame ? Boolean(frameJson.mainFrame) : false;
		this.set("isMainFrame", isMainFrame);
		this.set("links", links);
		this.set("templateName", frameJson.type + "FrameView");

		var enabledData = frameJson.enabled ? frameJson.enabled : null;
		this.set("enabledData", enabledData);
				
		var isCollapsed = frameJson.collapsed ? Boolean(frameJson.collapsed) : false;
		this.set("isCollapsed", isCollapsed);

		var iconImage = frameJson.icon ? frameJson.icon : "default.png";
		this.set("iconImage", iconImage);
	},
	
	getInputParameters : function(){
		var parameters = "";
		var values = "";
		for (var j = 0; j < this.input.parameters.length; j++) {
			var parameter = this.input.parameters[j];
			parameters += parameter + ',';

			if (this.input.type === "service") {
				var value = this.page.getParameterValue(parameter);
				values += value + ',';
			}else if (this.input.type === "nested"){
				//Primero buscamos en la grilla anidada y si no se encuentra buscamos en los atributos de la pagina
				var value = this.page.getParameterValue(parameter, this.input.frameId);
				
				if(value == null){
					 value = this.page.getParameterValue(parameter);
				}

				values += value + ',';
			}
		}
		
		var result = {
			"ids" : parameters,
			"values" : values
		};
		
		return result;
	},
	
	resolveFrameDataInput : function() {	
		if (this.input.type === "service") {
			if(this.page.get('attributesLoaded')) {
				this.getFrameData();
			}
		} else if (this.input.type === "nested") {
			var subjectFrame = this.page.getFrame(this.input.frameId);

			if (subjectFrame != null) {
				subjectFrame.addDataSelectionObserver(this);
			} else {
				this.page.addPendingObserver([this.input.frameId, this]);
			}

			//this.checkFrameEnabled();
		}
	},

	updateOnDataSelectionChanged : function() {
		this.getFrameData();
	},
	
	checkFrameEnabled : function() {
		try{
			if(this.enabledData){
				var condition = this.enabledData.condition;
				
				if(this.enabledData.parameters){
					for(var i=0; i < this.enabledData.parameters.length; i++)
					{
						var enabledParameter = this.enabledData.parameters[i];

						var value;
						if (this.input.type === "nested") {
							value = this.page.getParameterValue(enabledParameter, this.input.frameId);
						}
						else {
							value = this.page.getParameterValue(enabledParameter);
						}
						
						condition = condition.replace('#' + enabledParameter, "'" + value + "'");
					}
				}

				this.set("isEnabled", eval(condition));	
			}
			else{
				this.set("isEnabled", true);
			}
		}
		catch(e)
		{
			this.set("isEnabled", false);

			this.page.addError('Hubo un error al evaluar la condición (' + this.enabledData.condition + ') del frame ' + this.id);
		}
	}
});
