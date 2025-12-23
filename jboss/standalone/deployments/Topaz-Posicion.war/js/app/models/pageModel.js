App.Page = Ember.Object.extend({
	attributes : null,
	globalAttributes : [],
	frames : null,
	pendingFrames : [],
	errorData : null,
	dataServiceUrl : "MiddlewareService",
	mainFrameLoaded : false,
	parametersError : null,
	
	init : function(){
		var errorData = App.ErrorData.create({
			"title" : "Errores",
			"errors" : Ember.A([])
		});

		this.set('errorData', errorData);
	},
	
	hasErrors : function(){
		return this.errorData != null && this.errorData.errors.length > 0; 
	}.property("errorData.errors.[]"),

	addError : function(error) {
		this.errorData.errors.addObject(error);
	},

	getData : function(parameters, prev) {
		var page = this;

		return Ember.$.post("DispatcherService?pageId=" + page.id).then(function(result) {
			if (result == "error") {
				// TODO: redirigir al login?
				return false;
			} else {
				try
				{
					var objetResponse = jQuery.parseJSON(result);
	
					var previousPages = page.getPreviousPages(objetResponse, prev);
					page.set('previousPages', previousPages);
	
					var attributes = page.getAttributes(objetResponse, parameters);
					page.set('attributes', attributes);

					var globalAttributes = [];
					globalAttributes.push(App.Attribute.create({
						key : "USUARIO",
						value : userName
					}));
					page.set('globalAttributes', globalAttributes);			
					
					if(objetResponse.page.attributesService){
						return page.getServiceAttributes(objetResponse).then(function(serviceAttributes)
						{
							for(var i = 0; i < serviceAttributes.length; i++){
								page.globalAttributes.push(serviceAttributes[i]);								
							}
						
							var frames = page.getFrames(page, objetResponse);
							page.set('frames', frames);
							
							return true; 
						});
					}
					else{
						var frames = page.getFrames(page, objetResponse);
						page.set('frames', frames);
						
						return true; 
					} 
				}
				catch(err)
				{	
					var errorData = App.ErrorData.create({
						"title" : "Errores",
						"errors" : Ember.A([])
					});
	
					page.set('errorData', errorData);

					App.ErrorManager.create().setPageParseError(page);
					
					return true; 
				}
			}
		});
	},

	onFramesChanged : function() {
		var processedFrames = [];

		for (var i = 0; i < this.pendingFrames.length; i++) {
			var subjectFrameId = this.pendingFrames[i][0];
			var subjectFrame = this.getFrame(subjectFrameId);

			if (subjectFrame != null) {
				var observerFrame = this.pendingFrames[i][1];

				subjectFrame.addDataSelectionObserver(observerFrame);

				processedFrames.push(this.pendingFrames[i]);
			} else {
				App.ErrorManager.create().setFrameNotFoundError(subjectFrameId, this);
			}
		}

		for (var i = 0; i < processedFrames.length; i++) {
			var index = this.pendingFrames.indexOf(processedFrames[i]);
			this.pendingFrames.splice(index, 1);
		}
	}.observes('frames'),

	attributesLoaded : function() {		
		if (this.attributes == null){
			return false;			
		}

		var loaded = true;

		for (var i = 0; i < this.attributes.length; i++) {
			loaded = loaded && (this.attributes[i].value !== "");
		}

		return loaded;
	}.property('attributes'),
	
	showParametersPanel : function() {
		return this.get("parametersError") != null || !this.get("attributesLoaded");
	}.property('attributesLoaded', 'parametersError'),
	
	showFrames : function() {
		return this.mainFrameLoaded && this.get("attributesLoaded") && this.get("parametersError") == null;
	}.property('attributesLoaded', 'mainFrameLoaded', 'parametersError'),
	
	addPendingObserver : function(frames) {
		this.pendingFrames.push(frames);
	},

	getFrame : function(frameId) {
		if (this.frames == null) {
			return null
		} else {
			var frame = this.frames.filter(function(f) {
				return f.id === frameId;
			});

			if (frame.length != 0) {
				return frame[0];
			} else {
				return null;
			}
		}
	},

	getAttribute : function(parameter) {
		var attribute = this.attributes.filter(function(v) {
			return v["key"] == parameter;
		});
		if (attribute.length != 0) {
			return attribute[0];
		} else {
			var serviceAttribute = this.globalAttributes.filter(function(v) {
				return v["key"] == parameter;
			});
			if (serviceAttribute.length != 0) {
				return serviceAttribute[0];
			} else {
				return null;
				// TODO: manejar error en caso de pedir un atributo que no existe
				//alert('No se encontró el valor para el atributo ' + parameter);
			}
		}
	},
	
	getParameterValue : function(parameter, frameId, rowIndex, groupIndex) {
		// Si se pasa el frameId buscamos el dato en esa grilla
		// Si se pasa el rowIndex tomamos el valor de esa fila, 
		// Si se pasa el groupIndex tomamos el valor de esa fila para ese grupo, es valido para las multiples grillas, 
		// sino tomamos el valor de la filaseleccionada
		if (frameId) {
			var frame = this.getFrame(frameId);
			if (frame != null) {
				var frameValue = frame.getParameterValue(parameter, rowIndex, groupIndex);
				if(frameValue || frameValue === ""){
					return frameValue;
				}
			}
		}

		var attribute = this.attributes.filter(function(v) {
			return v["key"] == parameter;
		});
		if (attribute.length != 0) {
			return attribute[0].value;
		} else {
			var serviceAttribute = this.globalAttributes.filter(function(v) {
				return v["key"] == parameter;
			});
			if (serviceAttribute.length != 0) {
				return serviceAttribute[0].value;
			} else {
				// TODO: manejar error en caso de pedir un parametro que no existe
				//alert('No se encontró el valor para el parámetro ' + parameter);
			}
		}
	},
	
	getServiceAttributes : function(objetResponse){
		var parametersIds = "";
		var parametersValues = "";

		for (var i = 0; i < objetResponse.page.attributesService.parameters.length; i++) {
			var pageAttribute = this.getAttribute(objetResponse.page.attributesService.parameters[i]);
			
			if(pageAttribute) {
				var parameter = pageAttribute.key;					
				parametersIds += parameter + ",";

				var value = $.trim(pageAttribute.value.toUpperCase());
				
				if(value === ""){
					value = " ";
				}
				
				parametersValues += value + ",";
			}
		}
		
		var page = this;
		
		return Ember.$.post(this.dataServiceUrl, {
			"service" : objetResponse.page.attributesService.service,
			"serviceType" : "simple",
			"parameters" : parametersIds,
			"values" : parametersValues
		}).then(function(result) {	
			var attributes = [];
			
			try{
				var objetResponse = jQuery.parseJSON(result);
				
				for (var i = 0; i < objetResponse.length; i++) {
					var key = Object.keys(objetResponse[i])[0];
					
					var appAttribute = App.Attribute.create({
						key : key,
						value : objetResponse[i][key]
					});
					
					attributes.push(appAttribute);
				}
			}
			catch(err)
			{	
			}
			
			return attributes;
		});
	},

	getAttributes: function(objetResponse, parameters){
		var attributes = [];
		
		for (var i = 0; i < objetResponse.page.attributes.length; i++) {
			var attribute = objetResponse.page.attributes[i];
			
			var value = parameters[attribute.key];
			
			if(!value){				
				value = attribute.defaultValue ? attribute.defaultValue : "";
			}

			var tooltip = attribute.tooltip ? attribute.tooltip : null;

			var help = attribute.help ? attribute.help : null;
			
			var appAttribute = App.Attribute.create({
				label : attribute.label,
				key : attribute.key,
				value : value,
				tooltip : tooltip,
				help : help
			});
			 
			if(help){
				help.attribute = appAttribute;
				help.page = this;
				help.fields = [];
				
				for (var j = 0; j < help.columns.length; j++) {
					var column = help.columns[j];
					
					if(column.filter){
						help.fields.push({
			            	 "description" : column.header,
			            	 "value" : column.value
			             });
					}
				}
			}
			
			attributes.push(appAttribute);
		}

		return  attributes;
	},
	
	getPreviousPages : function(objetResponse, previousPages){
		try {
			var pages = [];
			var pagesStrings = previousPages.split('#');
		
			
			for(var i = 0; i < pagesStrings.length; i++)
			{
				var pageString = pagesStrings[i];
				var data = pageString.split(':');
				
				var pageTitle = data[0];
		
				var attributes = [];
				for(var j = 1; j < data.length; j = j + 2)
				{
					var attribute = {
						key : data[j],
						value : data[j+1]
					}
					
					attributes.push(attribute);
				}
				
				var page = {
					title : pageTitle,
					attributes : attributes
				}
				
				pages.push(page);
			}
			
			return pages;
		}
		catch(err)
		{
			return [];
		}
	},

	getFrames : function(page, objetResponse){
		var frames = [];
		var frame = null;
		
		var hasMainFrame = false;
		
		for (var i = 0; i < objetResponse.page.frames.length; i++) {
			var frameJson = objetResponse.page.frames[i];
			
			if (!page._isFrameDisabled(frameJson.id, page.id))
			{
				var validFrame = true;
				
				if (frameJson.type == 'Grid') {			
					frame = App.GridFrame.create({page : page});
				} else if (frameJson.type == 'Form') {
					frame = App.FormFrame.create({page : page});
				} else if (frameJson.type == 'Images') {
					frame = App.ImagesFrame.create({page : page});
				} else if (frameJson.type == 'Grids') {
					frame = App.GridsFrame.create({page : page});
				} else if (frameJson.type == 'Files') {
					frame = App.FilesFrame.create({page : page});
				} else {
					validFrame = false;
					App.ErrorManager.create().setFrameTypeNotValidError(frameJson.id, frameJson.type, page);
				}
				
				if(validFrame){
					var isMainFrame = frameJson.mainFrame ? Boolean(frameJson.mainFrame) : false;
					if(isMainFrame){
						hasMainFrame = true;
					}
					
					frame.parseFrame(frameJson);
					frames.push(frame);	
				}
			}
		}
		
		if(!hasMainFrame){
			page.set("mainFrameLoaded", true);		
		}
		
		return frames;
	}, 

	_isFrameDisabled : function (frameId, pageId){
		for (var i = 0; i < disabledFrames.length; i++) {
			if(disabledFrames[i].page == pageId && disabledFrames[i].frameId == frameId){
				return true;
			}
		}

		return false;
	},
	
	getPreviousPagesAndCurrentData : function() {
		var prevPages = this.getPreviousPagesData();

		if (prevPages !== "") {
			prevPages += "#";
		}

		prevPages += this.id;

		for (var i = 0; i < this.attributes.length; i++) {
			prevPages += ":" + this.attributes[i].key + ':' + this.attributes[i].value;
		}

		return prevPages;
	},

	getPreviousPagesData : function() {
		var prevPages = "";

		for (var i = 0; i < this.previousPages.length; i++) {
			prevPages += this.previousPages[i].title;

			for (var j = 0; j < this.previousPages[i].attributes.length; j++) {
				prevPages += ":" + this.previousPages[i].attributes[j].key + ':' + this.previousPages[i].attributes[j].value;
			}

			prevPages += "#";
		}

		prevPages = prevPages.replace(/#$/, "");

		return prevPages;
	}
});