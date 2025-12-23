App.ErrorData = Ember.Object.extend({
	title : null,
	iconImage : "error.png",
	isCollapsed : false,
	errors : null
});

App.Attribute = Ember.Object.extend({
	label : null,
	key : null,
	value : null,
	tooltip: null,
	help: null
});

App.KeyValuePair = Ember.Object.extend({
	key : null,
	value : null
});

App.SingleValue = Ember.Object.extend({
	value : null
});

App.Cell = Ember.Object.extend({
	value : null,
	row : null,
	column : null,
	parentFrame : null
});

App.Column = Ember.Object.extend({
	key : null,
	header : null,
	columnSpan : 1,
	hidden : false,
	textAlign : null
});

App.Row = Ember.Object.extend({
	values : null
});

App.Link = Ember.Object.extend({
	name : null,
	to : null,
	parameters : null,
	enabledData : null
});

App.FormField = Ember.Object.extend({
	key : null,
	label : null,
	value : null,
	columnSpan : 1,
	hidden : false
});

App.GridsField = Ember.Object.extend({
	formData : null,
	gridData : null	
});

App.ErrorManager = Ember.Object.extend({
	
	setFrameTypeNotValidError: function(frameId, frameType, page){
		page.addError('El frame <strong>' + frameId + '</strong> es de tipo no válido: <strong>' + frameType + '</strong>');
	},
	
	setFrameNotFoundError : function(frameId,  page){
		page.addError('El frame anidado <strong>' + frameId + '</strong> no existe.');	
	},
	
	setLinkVisibilityError : function(linkName, frameId, linkCondition, page){
		page.addError('Hubo un error al evaluar la condición de visibilidad del link <strong>' + linkName + '</strong> del frame <strong>' + frameId + '</strong>' +
					  '<br/> <br/><strong>' + linkCondition + '</strong>');	
	},
	
	setPageParseError: function (page) {
		page.addError('Hubo un error en el parse del json de la página');
	},

	setFrameParseError: function (frameId, response, page) {
		page.addError('Hubo un error en el parse del json del frame <strong>' + frameId + '</strong>' +
					  '<br/> <br/><strong>' + response + '</strong>');
	},

	setFrameDataError: function (frameId, response, page) {
		page.addError('Hubo un error al interpretar los datos del frame <strong>' + frameId + '</strong>' +
					  '<br/> <br/><strong>' + response + '</strong>');
	},	

	setFilesParseError: function (index, frameId, response, page) {
		page.addError('Hubo un error al obtener el archivo  del frame <strong>' + frameId + '</strong>' +
				  '<br/> <br/><strong> indice: ' + index + '</strong>' +
				  '<br/> <br/><strong>' + response + '</strong>');
	}
});
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

App.FilesFrame = App.Frame.extend({
	columns : null,
	data : null,
	pageLength : 0,
	fileInput : null,

	updateOnDataSelectionCleared : function() {
		this.set("data", null);
		this.checkFrameEnabled();
	},
	
	parseFrame : function (frameJson){
		this.parseFrameGenericData(frameJson);
		
		this.fileInput = frameJson.filesProperties.fileInput;

		var totalColumnsSize = 0;
		var columnsWithoutColumnSpan = frameJson.filesProperties.columns.length;
		var columns = [];
		for (var j = 0; j < frameJson.filesProperties.columns.length; j++) {
			var column = frameJson.filesProperties.columns[j];
			var textAlign = column.textAlign ? column.textAlign : null;
			
			var columnSpan = 0;

			var hiddenColumn = column.hidden ? Boolean(column.hidden) : false;
			
			if(column.columnSpan && !hiddenColumn){
				columnSpan = Number(column.columnSpan);
				columnsWithoutColumnSpan--;
				totalColumnsSize += columnSpan;
			}else if(hiddenColumn){
				columnsWithoutColumnSpan--;		
			}
			
			columns.push(App.Column.create({
				key : column.value,
				header : column.header,
				columnSpan : columnSpan,
				hidden : hiddenColumn,
				textAlign : textAlign
			}));
		}
		
		if(columnsWithoutColumnSpan > 0){
			this._calculateDefaultColumnSpan(columns, totalColumnsSize, columnsWithoutColumnSpan);	
		}	
		
		this.set("columns", columns);		
		
		var pageLength = frameJson.filesProperties.pageLength ? Number(frameJson.filesProperties.pageLength) : 0;
		this.set("pageLength", pageLength);
		
		this.resolveFrameDataInput();
	},
	
	_calculateDefaultColumnSpan : function(columns, totalColumnsSize, columnsWithoutColumnSpan){
		var maxColumns = 11;
		var sizeAvailable = maxColumns - totalColumnsSize;
		
		var defaultColumnSpan = Math.floor(sizeAvailable / columnsWithoutColumnSpan);
		//var extraColumnSpan = sizeAvailable % columnsWithoutColumnSpan;
		
		//Por desicion de diseño el tamaño por defecto de la columna nunca es mayor de 2
		//En caso de tener mas de 11 columnas le asignamos tamaño 1
		if(defaultColumnSpan == 0)
		{
			defaultColumnSpan =  1;
			
			extraColumnSpan = 0;
		}else if(defaultColumnSpan > 2){
			defaultColumnSpan = columnsWithoutColumnSpan * 2 > sizeAvailable ? 1 : 2;
		}

		var extraColumnSpan = sizeAvailable - (defaultColumnSpan * columnsWithoutColumnSpan);
		var lastVisibleColumn = null;		
		
		for (var i = 0; i < columns.length; i++) {
			var column = columns[i];

			if(!column.hidden){
				lastVisibleColumn = column;
				
				if(column.columnSpan == 0){
					column.columnSpan = defaultColumnSpan;
				}
			}
		}
		
		//Tenemos que asignar el espacio extra a la ultima columna no oculta		
		if(extraColumnSpan > 0){
			lastVisibleColumn.columnSpan += extraColumnSpan;
		}
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
					var rows = [];
		
					for (j = 0; j < data.length; j++) {
		
						var dataValues = []
		
						for (k = 0; k < frame.columns.length; k++) {
							dataValues.push(App.Cell.create({
								value : eval("data[" + j + "]." + frame.columns[k].key),
								row : j,
								column : k,
								parentFrame : frame
							}));
						}
		
						rows.push(App.Row.create({
							values : dataValues,
						}));
					}
		
					frame.set('data', rows);
				}
				catch(e)
				{
					App.ErrorManager.create().setFrameDataError(frame.id, response, frame.page);
				}
				
				frame.set('loading', false);
			});
		}
	},

	getParameterValue : function(parameter, rowIndex){

		if (rowIndex >= 0) {
			var row = this.data[rowIndex];

			var columnIndex = -1;
			for (var i = 0; i < this.columns.length; i++) {
				if (this.columns[i].key === parameter) {
					columnIndex = i;
					break;
				}
			}

			if (columnIndex != -1) {
				return row.values[columnIndex].value;
			}
		}
		
		return null;
	}
});
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
App.GridFrame = App.Frame.extend({
	columns : null,
	data : null,
	pageLength : 0,
	selectedIndex : -1,
	dataSelectionObservers : null,

	updateOnDataSelectionCleared : function() {
		this.set("data", null);
		this.checkFrameEnabled();
	},

	addDataSelectionObserver : function(frame) {
		if (this.dataSelectionObservers == null) {
			this.dataSelectionObservers = [];
		}

		this.dataSelectionObservers.push(frame);
	},
	
	onDataChanged : function() {
		this.set("selectedIndex",-1);
	}.observes('data'),
	
	onSelectionChanged : function() {
		if (this.dataSelectionObservers != null) {
			for (var i = 0; i < this.dataSelectionObservers.length; i++) {
				if(this.selectedIndex == -1)
				{
					this.dataSelectionObservers[i].updateOnDataSelectionCleared();
				}else{
					this.dataSelectionObservers[i].updateOnDataSelectionChanged();
				}
			}
		}
	}.observes('selectedIndex'),

	parseFrame : function(frameJson) {
		this.parseFrameGenericData(frameJson);

		var totalColumnsSize = 0;
		var columnsWithoutColumnSpan = frameJson.gridProperties.columns.length;
		var columns = [];
		for (var j = 0; j < frameJson.gridProperties.columns.length; j++) {
			var column = frameJson.gridProperties.columns[j];
			
			var textAlign = column.textAlign ? column.textAlign : null;
			
			var columnSpan = 0;

			var hiddenColumn = column.hidden ? Boolean(column.hidden) : false;
						
			if(column.columnSpan && !hiddenColumn){
				columnSpan = Number(column.columnSpan);
				columnsWithoutColumnSpan--;
				totalColumnsSize += columnSpan;
			}else if(hiddenColumn){
				columnsWithoutColumnSpan--;				
			}
						
			columns.push(App.Column.create({
				key : column.value,
				header : column.header,
				columnSpan : columnSpan,
				hidden : hiddenColumn,
				textAlign : textAlign
			}));
		}
		
		if(columnsWithoutColumnSpan > 0){
			this._calculateDefaultColumnSpan(columns, totalColumnsSize, columnsWithoutColumnSpan);	
		}	
		
		this.set("columns", columns);		
		
		var pageLength = frameJson.gridProperties.pageLength ? Number(frameJson.gridProperties.pageLength) : 0;
		this.set("pageLength", pageLength);
		
		this.resolveFrameDataInput();
	},
	
	_calculateDefaultColumnSpan : function(columns, totalColumnsSize, columnsWithoutColumnSpan){
		var maxColumns = 12;
		var sizeAvailable = maxColumns - totalColumnsSize;
		
		var defaultColumnSpan = Math.floor(sizeAvailable / columnsWithoutColumnSpan);
		//var extraColumnSpan = sizeAvailable % columnsWithoutColumnSpan;
		
		//Por desicion de diseño el tamaño por defecto de la columna nunca es mayor de 2
		//En caso de tener mas de 12 columnas le asignamos tamaño 1
		if(defaultColumnSpan == 0)
		{
			defaultColumnSpan =  1;
			
			extraColumnSpan = 0;
		}else if(defaultColumnSpan > 2){
			defaultColumnSpan = columnsWithoutColumnSpan * 2 > sizeAvailable ? 1 : 2;
		}

		var extraColumnSpan = sizeAvailable - (defaultColumnSpan * columnsWithoutColumnSpan);
		var lastVisibleColumn = null;		
		
		for (var i = 0; i < columns.length; i++) {
			var column = columns[i];
			
			if(!column.hidden){
				lastVisibleColumn = column;
			
				if(column.columnSpan == 0){
					column.columnSpan = defaultColumnSpan;
				}
			}
		}
		
		//Tenemos que asignar el espacio extra a la ultima columna no oculta		
		if(extraColumnSpan > 0){
			lastVisibleColumn.columnSpan += extraColumnSpan;
		}
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
					var rows = [];
					if(data.length > 0) {
						if(frame.isMainFrame){
							frame.page.set("mainFrameLoaded", true);							
						}
						
						for (j = 0; j < data.length; j++) {
			
							var dataValues = []
			
							for (k = 0; k < frame.columns.length; k++) {
								dataValues.push(App.Cell.create({
									value : eval("data[" + j + "]." + frame.columns[k].key),
									row : j,
									column : k,
									parentFrame : frame
								}));
							}
			
							rows.push(App.Row.create({
								values : dataValues,
							}));
						}
			
						frame.set('data', rows);
					}
					else {
						if(frame.isMainFrame){
							frame.page.set("parametersError", "No hay información para los datos ingresados.");								
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
	
	getParameterValue : function(parameter, rowIndex){

		if (!rowIndex && rowIndex != 0) {
			rowIndex = this.selectedIndex;
		}

		if (rowIndex != -1) {
			var row = this.data[rowIndex];

			var columnIndex = -1;
			for (var i = 0; i < this.columns.length; i++) {
				if (this.columns[i].key === parameter) {
					columnIndex = i;
					break;
				}
			}

			if (columnIndex != -1) {
				return row.values[columnIndex].value;
			}
		}
		
		return null;
	}
});

App.GridsFrame = App.Frame.extend({
	columns : null,
	headerForm : null,
	data : null,
	pageLength : 0,

	updateOnDataSelectionCleared : function() {
		this.set("data", null);
		this.checkFrameEnabled();
	},
	
	parseFrame : function (frameJson){
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
		this.set("headerForm", dataRows);

		var totalColumnsSize = 0;
		var columnsWithoutColumnSpan = frameJson.gridProperties.columns.length;
		var columns = [];
		for (var j = 0; j < frameJson.gridProperties.columns.length; j++) {
			var column = frameJson.gridProperties.columns[j];
			var textAlign = column.textAlign ? column.textAlign : null;
			
			var columnSpan = 0;

			var hiddenColumn = column.hidden ? Boolean(column.hidden) : false;
			
			if(column.columnSpan && !hiddenColumn){
				columnSpan = Number(column.columnSpan);
				columnsWithoutColumnSpan--;
				totalColumnsSize += columnSpan;
			}else if(hiddenColumn){
				columnsWithoutColumnSpan--;		
			}
			
			columns.push(App.Column.create({
				key : column.value,
				header : column.header,
				columnSpan : columnSpan,
				hidden : hiddenColumn,
				textAlign : textAlign
			}));
		}

		if(columnsWithoutColumnSpan > 0){
			this._calculateDefaultColumnSpan(columns, totalColumnsSize, columnsWithoutColumnSpan);	
		}	
		
		this.set("columns", columns);
		
		var pageLength = frameJson.gridProperties.pageLength ? Number(frameJson.gridProperties.pageLength) : 0;
		this.set("pageLength", pageLength);
		
		this.resolveFrameDataInput();
	},
	
	_calculateDefaultColumnSpan : function(columns, totalColumnsSize, columnsWithoutColumnSpan){
		var maxColumns = 12;
		var sizeAvailable = maxColumns - totalColumnsSize;
		
		var defaultColumnSpan = Math.floor(sizeAvailable / columnsWithoutColumnSpan);
		//var extraColumnSpan = sizeAvailable % columnsWithoutColumnSpan;
		
		//Por desicion de diseño el tamaño por defecto de la columna nunca es mayor de 2
		//En caso de tener mas de 12 columnas le asignamos tamaño 1
		if(defaultColumnSpan == 0)
		{
			defaultColumnSpan =  1;
			
			extraColumnSpan = 0;
		}else if(defaultColumnSpan > 2){
			defaultColumnSpan = columnsWithoutColumnSpan * 2 > sizeAvailable ? 1 : 2;
		}

		var extraColumnSpan = sizeAvailable - (defaultColumnSpan * columnsWithoutColumnSpan);
		var lastVisibleColumn = null;		
		
		for (var i = 0; i < columns.length; i++) {
			var column = columns[i];

			if(!column.hidden){
				lastVisibleColumn = column;
			
				if(column.columnSpan == 0){
					column.columnSpan = defaultColumnSpan;
				}
			}
		}
		
		//Tenemos que asignar el espacio extra a la ultima columna no oculta		
		if(extraColumnSpan > 0){
			lastVisibleColumn.columnSpan += extraColumnSpan;
		}
	},
	
	getFrameData : function() {
		this.checkFrameEnabled();

		if(this.isEnabled){
			var frame = this;
			
			frame.set('loading', true);
			
			var parameters = this.getInputParameters();		

			Ember.$.post(this.page.dataServiceUrl, {
				"service" : frame.input.service,
				"parameters" : parameters.ids,
				"values" : parameters.values
			}).then(function(response) {
				try{
					var dataGroups = jQuery.parseJSON(response);	
				}
				catch(e)
				{
					App.ErrorManager.create().setFrameParseError(frame.id, response, frame.page);
					frame.set('loading', false);
					return;
				}

				try{	
					if(dataGroups.length > 0) {
						if(frame.isMainFrame){
							frame.page.set("mainFrameLoaded", true);							
						}
						
						var data = [];
						for(var z = 0; z < dataGroups.length; z++){	
							var group = dataGroups[z];
							
							var formRows = [];
							for (var i = 0; i < frame.headerForm.length; i++) {
								var dataRow = frame.headerForm[i];
								var fields = [];
								
								for(var j = 0; j < dataRow.length; j++) {
			
									if(group.DataValues[dataRow[j].key])
									{
										fields.push(App.FormField.create({
											key : dataRow[j].key,
											label : dataRow[j].label,
											value : group.DataValues[dataRow[j].key],
											columnSpan : dataRow[j].columnSpan,
											hidden : dataRow[j].hidden
										}));
									}
								}
								
								formRows.push(fields);
							}	
			
							var gridRows = [];
				
							for (j = 0; j < group.Entity2s.Entity2.length; j++) {
								var dataValues = []
				
								for (k = 0; k < frame.columns.length; k++) {
									dataValues.push(App.Cell.create({
										value : eval("group.Entity2s.Entity2[" + j + "]." + frame.columns[k].key),
										row : j,
										column : k,
										parentFrame : frame
									}));
								}
				
								gridRows.push(App.Row.create({
									values : dataValues,
								}));
							} 
			
							data.push(App.GridsField.create({
								formData : formRows,
								gridData : gridRows
							}));
						}
						
						frame.set("data", data);
					}
					else {
						if(frame.isMainFrame){
							frame.page.set("parametersError", "No hay información para los datos ingresados.");								
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

	getParameterValue : function(parameter, rowIndex, groupIndex){
		var group = this.data[groupIndex];
		
		//Primero buscamos el dato en la grilla
		var gridData = group.gridData[rowIndex];

		var columnIndex = -1;
		for (var i = 0; i < this.columns.length; i++) {
			if (this.columns[i].key === parameter) {
				columnIndex = i;
				break;
			}
		}

		if (columnIndex != -1) {
			return gridData.values[columnIndex].value;
		}		
		
		//Si no encontramos el dato en la grilla buscamos en el formulario
		var formData = group.formData;
		for (var i = 0; i < formData.length; i++) {
			var attribute = formData[i].filter(function(v) {
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
})


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
App.IndexController = Ember.ObjectController.extend({
	queryParams : ["response"],
	response : null
});
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
App.FilesTableView = Em.View.extend({
	classNames : [ 'table' ],
	tagName : 'table',
	didInsertElement : function() {

		var controller = this.get('controller');
		var page = controller.get('model');
		var frameData = this.get('context');

		if (frameData && frameData.length > 0) {
			var frame = frameData[0].values[0].parentFrame;

			var columns = [];
			var data = [];
			
			columns.push({
				"sTitle" : "Link",
				"mData" : "link"
			});

			for (var i = 0; i < frame.columns.length; i++) {
				if(!frame.columns[i].hidden){
					columns.push({
						"sTitle" : frame.columns[i].header,
						"mData" : frame.columns[i].key
					});
				}
			}

			for (var i = 0; i < frameData.length; i++) {
				var jsonData = {};
				jsonData['link'] = '<a class=\"downloadFile-btn\"><i class="glyphicon glyphicon-download-alt"></i></a>';
				
				for (var j = 0; j < frameData[i].values.length; j++) {
					jsonData[frame.columns[frameData[i].values[j].column].key] = frameData[i].values[j].value;
				}

				data.push(jsonData);
			}

			var framePageLength = frame.pageLength;
			var columnsDefs = [];
			
			columnsDefs.push({ "aTargets":[0], "sClass":"col-sm-1"});	

			var j = 1;
			for(var i = 0; i < frame.columns.length; i++) {
				if(!frame.columns[i].hidden){
					if(frame.columns[i].textAlign){
						columnsDefs.push({ "aTargets":[j++], "sClass": "text-"+  frame.columns[i].textAlign + " col-sm-" +  frame.columns[i].columnSpan});	
					}
					else{
						columnsDefs.push({ "aTargets":[j++], "sClass": "col-sm-" +  frame.columns[i].columnSpan});	
					}
				}
			}
         
			var dataTable = this.$().dataTable({
				paging : framePageLength != 0 && frameData.length > framePageLength,
				pageLength : framePageLength,
				info : false,
				ordering : false,
				deferRender : true,
				searching : false,
				lengthChange : false,
				responsive : true,
				bProcessing : true,
				aaData : data,
				aoColumns : columns,
				bLengthChange : false,
				dom : 't<"bottom"p><"clear">',
				aoColumnDefs : columnsDefs,
				language : {
					"lengthMenu" : "Mostrando _MENU_registros por página",
					"zeroRecords" : "No hay registros",
					"info" : "Mostrando página _PAGE_ de _PAGES_",
					"infoEmpty" : "No hay registros disponibles",
					"infoFiltered" : "(filtrados de _MAX_ registros)",
					"search" : "Buscar:",
					"loadingRecords" : "Cargando...",
					"processing" : "Procesando...",
					"thousands" : ".",
					"paginate" : {
						"first" : "Primera",
						"last" : "Última",
						"previous" : "Anterior",
						"next" : "Siguiente"
					}
				},
				createdRow : function(row, data, index) {
											
						$('td a', row).on('click', {
							frame : frame,
							index : index
						}, function() {
							var elem = $(this).find('i');
							elem.removeClass('glyphicon-download-alt');
							elem.addClass('glyphicon-refresh glyphicon-refresh-animate');
							
							
							var parameters  = "";
							var values = "";
							for (var j = 0; j < frame.fileInput.parameters.length; j++) {
								var parameter = frame.fileInput.parameters[j];
								parameters += parameter + ',';

								var value = page.getParameterValue(parameter, frame.id, index);
								values += value + ',';
							}

							Ember.$.post(frame.page.dataServiceUrl, {
								"service" : frame.fileInput.service,
								"parameters" : parameters,
								"values" : values
							}).then(function(response) {
								try{	
									var data = jQuery.parseJSON(response);
								}
								catch(e)
								{
									App.ErrorManager.create().setFilesParseError(index, frame.id, response, frame.page);
									
									elem.addClass('glyphicon-download-alt');
									elem.removeClass('glyphicon-refresh glyphicon-refresh-animate');
									return;
								}

								try{
									data = data[0].DataValues;

									var serverFolder = controller.const.filesFolderUrl;	
									
									var file = data.ReportFileName;
									window.open(serverFolder +file, '_blank');
								}
								catch(e)
								{
									App.ErrorManager.create().setFrameDataError(frame.id, response, frame.page);
								}
								
								elem.addClass('glyphicon-download-alt');
								elem.removeClass('glyphicon-refresh glyphicon-refresh-animate');
							});
						});
				}
			});
		}
	}
});

App.FormFieldView = Ember.View.extend({
	classNameBindings : [ 'columnSpan', 'defaultClass' ],
	
	defaultClass : function() {
		return 'col-xs-6';
	}.property(),
	
	columnSpan : function() {
		return 'col-sm-' + this.get('context.columnSpan');
	}.property('context.columnSpan')
});

App.FrameHeaderView = Ember.View.extend({
	frameIconStyle : function() {
		var loading = this.get('context.loading');
		
		if(loading){
			return '-animation: spin .7s infinite linear; -webkit-animation: spin2 .7s infinite linear;';
		}
		else{
			return 'width:24px;height:24px;margin: 0px; background-image: url(\'images/icons/' + this.get('context.iconImage') + '\')';
		}
	}.property('context.iconImage', 'context.loading'),	
		
	click : function(evt) {
		var frame = this.get('context');
		frame.set('isCollapsed', !frame.isCollapsed);
	}
});
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
App.TableView = Em.View.extend({
	classNames : [ 'table', 'table-hover' ],
	tagName : 'table',
	didInsertElement : function() {

		var controller = this.get('controller');
		var page = controller.get('model');
		var frameData = this.get('context');
		var view = this;
		
		if (frameData && frameData.length > 0) {
			var frame = frameData[0].values[0].parentFrame;

			var columns = [];
			var data = [];

			for (var i = 0; i < frame.columns.length; i++) {
				if(!frame.columns[i].hidden){
					columns.push({
						"sTitle" : frame.columns[i].header,
						"mData" : frame.columns[i].key
					});
				}
			}

			for (var i = 0; i < frameData.length; i++) {
				var jsonData = {};
				for (var j = 0; j < frameData[i].values.length; j++) {
					jsonData[frame.columns[frameData[i].values[j].column].key] = frameData[i].values[j].value;
				}

				data.push(jsonData);
			}

			var framePageLength = frame.pageLength;
			var columnsDefs = [];
			
			var j = 0;
			for(var i = 0; i < frame.columns.length; i++) {
				if(!frame.columns[i].hidden){
					if(frame.columns[i].textAlign){
						columnsDefs.push({ "aTargets":[j++], "sClass": "text-"+  frame.columns[i].textAlign + " col-sm-" +  frame.columns[i].columnSpan});	
					}
					else{
						columnsDefs.push({ "aTargets":[j++], "sClass": "col-sm-" +  frame.columns[i].columnSpan});	
					}
				}
			}
         
			var dataTable = this.$().dataTable({
				paging : framePageLength != 0 && frameData.length > framePageLength,
				pageLength : framePageLength,
				info : false,
				ordering : false,
				deferRender : true,
				searching : false,
				lengthChange : false,
				responsive : true,
				bProcessing : true,
				aaData : data,
				aoColumns : columns,
				bLengthChange : false,
				dom : 't<"bottom"p><"clear">',
				aoColumnDefs : columnsDefs,
				language : {
					"lengthMenu" : "Mostrando _MENU_registros por página",
					"zeroRecords" : "No hay registros",
					"info" : "Mostrando página _PAGE_ de _PAGES_",
					"infoEmpty" : "No hay registros disponibles",
					"infoFiltered" : "(filtrados de _MAX_ registros)",
					"search" : "Buscar:",
					"loadingRecords" : "Cargando...",
					"processing" : "Procesando...",
					"thousands" : ".",
					"paginate" : {
						"first" : "Primera",
						"last" : "Última",
						"previous" : "Anterior",
						"next" : "Siguiente"
					}
				},
				createdRow : function(row, data, index) {
					if (frame.links) {
						var tds = $('td', row);

						var group = $(this).parents(".grids-row");
						var groupIndex = -1;
						if (group) {
							var groups = group.parent();
							groupIndex = groups.find(".grids-row").index(group);
						}

						for (var td = 0; td < tds.length; td++) {
							var menuLinks = [];

							for (var i = 0; i < frame.links.length; i++) {
								var linkEnabled = view.linkEnabled(frame.links[i], frame.id, index, groupIndex,  frame.page);				
								
								if(linkEnabled){
									menuLinks.push({
										title : frame.links[i].name,
										name : frame.links[i].name,
										linkTo : frame.links[i].to,
										group : groupIndex,
										frameId : frame.id,
										row : index,
										parameters : frame.links[i].parameters,
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
		
													var value = page.getParameterValue(parameter, link.frameId, link.row, link.group);
													values.push('\"' + value + '\"');
												}
		
												var prevPages = "\"" + page.getPreviousPagesAndCurrentData() + "\"";
		
												controller.transitionToRoute("/" + link.linkTo + "?params=[" + parameters.toString() + "]&values=[" + values.toString() + "]&prev=" + prevPages);
											}
										}
									});
								}
							}

							if(menuLinks.length > 0){
								$(tds[td]).contextMenu(menuLinks);
							}
						}
					}

					$(row).on('click', {
						frame : frame
					}, function() {
						var elem = $(this);

						if ($(this).hasClass('selectedTR')) {
							if (!frame.links) {
								$(this).removeClass('selectedTR');

								if (frame.constructor.toString() === "App.GridFrame") {
									frame.set("selectedIndex", -1);
								}
							}
						} else {
							dataTable.$('tr.selectedTR').removeClass('selectedTR');
							$(this).addClass('selectedTR');

							if (frame.constructor.toString() === "App.GridFrame") {
								frame.set("selectedIndex", Number(index));
							}
						}
					});

					$(row).on("contextmenu", {
						frame : frame
					}, function(event) {
						if ($(this).hasClass('selectedTR')) {
							$(this).removeClass('selectedTR');

							if (frame.constructor.toString() === "App.GridFrame") {
								frame.set("selectedIndex", -1);
							}
						}
					});
				}
			});
		}
	},
	
	linkEnabled : function(link, frameId, index, groupIndex, page){
		try{
			if(link.enabledData){
				var condition = link.enabledData.condition;
				for(var j=0; j < link.enabledData.parameters.length; j++)
				{
					var enabledParameter = link.enabledData.parameters[j];
					var value = page.getParameterValue(enabledParameter, frameId, index, groupIndex);
					
					condition = condition.replace('#' + enabledParameter, "'" + value + "'");
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

App.GalleryView = Em.View.extend({
	classNames : [ 'carousel', 'slide' ],
	imageUrl : function() {
		return this.get('context').toString();
	}.property(),
	didInsertElement : function(evt) {

		var controller = this.get('controller');
		var page = controller.get('model');
		var imagesData = this.get('context');

		var serverFolder = controller.const.imagesFolderUrl;	
				
		var element = this.get('element');

		var carouselId = element.id;
		if(imagesData.length > 1){
			$(element).find(".carousel-control").prop("href", "#" + carouselId);
		}else{
			$(element).find(".carousel-control").css({
				'display' : 'none'
			});
		}

		var e = "";
		var firstItemClass = "active";
		for (var i = 0; i < imagesData.length; i++) {
			e += "<div class=\"item " + firstItemClass + "\"><div class=\"row\">";
			firstItemClass = "";
			
			for (var j = 0; j < imagesData[i].length; j++) {

				e += "<div class=\"col-sm-2 col-xs-4\">";
				e += "<a class=\"activate_modal thumbnail\"><img src=\"" + serverFolder + imagesData[i][j] + "\" alt=\"Image\" class=\"img-responsive\"></a>";
				e += "</div>";
			}

			e += "</div></div>";
		}
				
		$(element).find(".carousel-inner").append(e);
		
		$(element).find('.activate_modal').click(function() {
			var src_img = $(this).children('img').attr('src');
			var htmlContent = '<img src="' + src_img + '">';
			show_imagesModal(htmlContent);
		});
		
	
		var body = document.body;
		var html = document.documentElement;
	
		var alturaDoc = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
		$('#mask').css({
			'height' : alturaDoc + 'px'
		});	
		
		$(element).carousel({
			interval : 0
		})
	}
});

App.DisabledPageModalView = Ember.View.extend({
	actions : {
		closeModal : function(){
			close_disabledPageModal();
		}
	}
});

function close_disabledPageModal() {
	$('#disabledPageMask').fadeOut(200);
	$('#disabledPageModalContainer').fadeOut(200);
}

function show_disabledPageModal() {	

	var body = document.body;
	var html = document.documentElement;
	var alturaDoc = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
	$('#disabledPageMask').css({'height' : alturaDoc + 'px'});	
	
	$('#disabledPageMask').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#disabledPageModalContainer').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#disabledPageModalContainer').fadeTo(200, 1);
	$('#disabledPageMask').fadeTo(200, 0.8);
	$('#disabledPageModal').fadeIn(200);
}
App.FilterModalView = Ember.View.extend({
	currentHelp : null,
	selectedOperator : null,
	selectedField : null,	
	selectedValue : null,	
	error : null,
	fields : function(){
		if(this.currentHelp == null)
			return [];
		else
			return this.currentHelp.fields;
	}.property("currentHelp"),
	
	operators : [
	             {
	            	 "description" : "Comienza por",
	            	 "value" : "1"
	             },
	             {
	            	 "description" : "Contiene a",
	            	 "value" : "2"
	             },
	             {
	            	 "description" : "No contiene a",
	            	 "value" : "3"
	             },
	             {
	            	 "description" : "Igual",
	            	 "value" : "4"
	             },
	             {
	            	 "description" : "Distinto",
	            	 "value" : "5"
	             },
	             {
	            	 "description" : "Mayor",
	            	 "value" : "6"
	             },
	             {
	            	 "description" : "Mayor o igual",
	            	 "value" : "7"
	             },
	             {
	            	 "description" : "Menor",
	            	 "value" : "8"
	             },
	             {
	            	 "description" : "Menor o igual",
	            	 "value" : "9"
	             }
	            ],
	            
	actions : {
		onFilterChange : function() {
			var view = this;
			var parentView = this.get('parentView');

			var parametersPanelView = parentView.get('childViews').filter(function(v) {
				return v["class"] === "parametersPanel";
			})[0];
						
			if(this.selectedValue && this.selectedOperator && this.selectedField){
				
				var result = parametersPanelView.getHelpParameters(this.currentHelp);
				
				var parametersIds = result.parametersIds;
				var parametersValues = result.parametersValues;
				
				parametersIds += "TIENEFILTRO,CAMPO,OPERADOR,VALOR";
				parametersValues += "1,";
				parametersValues += this.selectedField + ",";
				parametersValues += this.selectedOperator + ",";
				parametersValues += $.trim(this.selectedValue.toUpperCase()) + ",";
				
				Ember.$.post(this.currentHelp.page.dataServiceUrl, {
					"service" : this.currentHelp.input.service,
					"serviceType" : "help",
					"parameters" : parametersIds,
					"values" : parametersValues
				}).then(function(response) {					
					try{					
						var values = jQuery.parseJSON(response)[0].Entity2s.Entity2;
						if(values.length == 0) {
							view.set("error", "El filtro no encontró ningún valor.");
						}
						else{
							view.set("error", null);
							view.currentHelp.values = values;
		
							$('#helpTableContainer').html("<table class=\"helpTable table table-hover dataTable no-footer \"></table>");
							
							parametersPanelView.drawHelp(view.currentHelp);				
							
							$('#addFilterBtn').css({'display' : 'none'});	
							$('#removeFilterBtn').css({'display' : 'block'});
							
							view.send('closeModal');
						}
					}
					catch(e){
						view.set("error", "El filtro no encontró ningún valor.");
					}
				});
			}else {
				if(!this.selectedField) {
					this.set("error", "Debe seleccionar un campo.");
				}
				else if(!this.selectedOperator) {
					this.set("error", "Debe seleccionar un operador.");
				}
				else if(!this.selectedValue){
					this.set("error", "Debe ingresar un valor.");
				}
			}
		},
		
		closeModal :function(){
			this.set("error", null);
			close_filterModal();
		}
	}
});
App.HeaderView = Ember.View.extend({
	userName: function(){
		return userName;
	}.property(),
	today: function() {
		var today = new Date();
		var dd = today.getDate();
		var mm = today.getMonth()+1; 
		var yyyy = today.getFullYear();
	
		if(dd<10) {
		    dd='0'+dd;
		} 
	
		if(mm<10) {
		    mm='0'+mm;
		} 
	
	    return dd + '/'+ mm + '/' + yyyy;
	}.property(),
});
App.HelpsModalView = Ember.View.extend({
	didInsertElement : function() {
		this._super();			
	},

	actions : {
		helpClose : function(){
			close_helpsModal();
			
			var parentView = this.get('parentView');

			var filterView = parentView.get('childViews').filter(function(v) {
				return v["class"] === "filterModal";
			})[0];

			filterView.set("currentHelp", null);
			filterView.set("selectedOperator", null);
			filterView.set("selectedField", null);
			filterView.set("selectedValue", null);
		}
	}
});

function close_helpsModal() {
	$('#mask').fadeOut(200);
	$('#helpsModalContainer').fadeOut(200);
	$('.modal_window').fadeOut(200);
	
	$("body").css({"overflow":"visible"});

	$('#addFilterBtn').css({'display' : 'none'});	
	$('#removeFilterBtn').css({'display' : 'none'});
}

function show_helpsModal() {	
	$("body").css({"overflow":"hidden"});
	
	$('#mask').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#helpsModalContainer').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#helpsModalContainer').fadeTo(200, 1);
	$('#mask').fadeTo(200, 0.8);
	$('#helpModal').fadeIn(200);

	$('#helpTableContainer').html("<table class=\"helpTable table table-hover dataTable no-footer \"></table>");

	$('#helpsModalContainer').animate({ scrollTop: 0, scrollLeft:0 }, 0);
}

function close_filterModal() {
	$('#filterMask').fadeOut(200);
	$('#filterModalContainer').fadeOut(200);
}

function show_filterModal() {	
	$("body").css({"overflow":"hidden"});
	
	$('#filterMask').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#filterModalContainer').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#filterModalContainer').fadeTo(200, 1);
	$('#filterMask').fadeTo(200, 0.8);
	$('#filterModal').fadeIn(200);

	$('#filterModalContainer').animate({ scrollTop: 0, scrollLeft:0 }, 0);
}
App.ImagesModalView = Ember.View.extend({
	didInsertElement : function() {
		this._super();
		
		$("#mask").unbind('click');
		$('#mask').click(function() {
			close_imagesModal();

			$("#mask").unbind('click');
		});		

		$(".imagesModal").unbind('click');
		$('.imagesModal').click(function() {
			close_imagesModal();
		});		

		$("#newWindowButton").unbind('click');
		$('#newWindowButton').click(function() {
			var url = $('#imageModal img').attr('src');
			window.open(url, '_blank');
		});			
	}
});

function close_imagesModal() {
	$('#mask').fadeOut(500);
	$('#imagesModalContainer').fadeOut(500);
	$('.modal_window').fadeOut(500);
	
	$("body").css({"overflow":"visible"});
}

function show_imagesModal(htmlContent) {	
	$("body").css({"overflow":"hidden"});
	
	$('#mask').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#imagesModalContainer').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#imagesModalContainer').fadeTo(200, 1);
	$('#mask').fadeTo(200, 0.8);
	$('#imageModal').fadeIn(200);

	$('#imageModal').html(htmlContent);

	$('#imagesModalContainer').animate({ scrollTop: 0, scrollLeft:0 }, 0);
}
App.ParameterHeaderView = Ember.View.extend({
	click : function(evt) {
		var elem = $(evt.currentTarget);
		var frame = elem.parents('.parameter');
		var parameterConent = frame.children('.parameterContent');
		var arrowIconDiv = elem.children('.parameterExpand');
		var arrowIcon = arrowIconDiv.children('.glyphicon');

		if (parameterConent.is(':visible')) {
			parameterConent.css('display', "none");
			arrowIcon.addClass("glyphicon-chevron-down");
			arrowIcon.removeClass("glyphicon-chevron-up");
		} else {
			parameterConent.css('display', "block");
			arrowIcon.addClass("glyphicon-chevron-up");
			arrowIcon.removeClass("glyphicon-chevron-down");
		}
	}
});
App.ParametersPanelView = Ember.View.extend({
	selectedPage : null,
	homePages : null,	
	loading : false,

	actions : {
		onParameterChange : function() {
			if(!this.get('loading')){
				this.set('loading', true);			
				
				var parameters = [];
				var values = [];
				
				var controller = this.get('controller');
				var page = controller.get('model');
	
				for (var j = 0; j < page.attributes.length; j++) {
					var parameter = page.attributes[j].key;
					parameters.push('\"' + parameter + '\"');
	
					var value = $.trim(page.attributes[j].value.toUpperCase());
					values.push('\"' + value + '\"');
					
					if((!value && value != 0) || (value == '')){
						this.set('loading', false);	
						return;
					}
				}
	
				var prevPages = "\"" + page.getPreviousPagesData() + "\"";
				
				if(this.isNewNavigation(parameters, values)){	
					page.set("parametersError", null);
					page.set("mainFrameLoaded", false);	
					
					controller.transitionToRoute("/" + page.id + "?params=[" + parameters.toString() + "]&values=[" + values.toString() + "]&prev=" + prevPages);
				}
				else{
					this.set('loading', false);
				}
			}
		},
				
		parametersPanelButtonClick : function() {
			var btnPanel = 'arrow-menu-btn';
			var contenidoPanel = 'parametersContainer';

			if ($('.' + contenidoPanel).is(':visible')) {
				$('.' + contenidoPanel).removeClass("show");
				$('.' + btnPanel).removeClass("closeArrow");

				$('.' + contenidoPanel).addClass("hide");
				$('.' + btnPanel).addClass("openArrow");
			} else {
				$('.' + contenidoPanel).removeClass("hide");
				$('.' + btnPanel).removeClass("openArrow");

				$('.' + contenidoPanel).addClass("show");
				$('.' + btnPanel).addClass("closeArrow");
			}
		},
		
		helpClick : function(help){		
			var view = this;
			var parentView = this.get('parentView');

			var filterView = parentView.get('childViews').filter(function(v) {
				return v["class"] === "filterModal";
			})[0];
						
			filterView.set("currentHelp", help);
			
			var body = document.body;
			var html = document.documentElement;
		
			var alturaDoc = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
			$('#mask').css({'height' : alturaDoc + 'px'});	
			$('#filterMask').css({'height' : alturaDoc + 'px'});	
			
			$('#helpTitle').text("AYUDA DE " + help.attribute.label);

			if(help.input)
			{
				$('#addFilterBtn').css({'display' : 'block'});	
				
				var menuLinks1 = [];

				menuLinks1.push({
					title : "Agregar filtro",
					name : "Agregar filtro",
					fun : function(event) {
						show_filterModal();					
					}
				});

				$('#addFilterBtn').contextMenu(menuLinks1);

				var menuLinks2 = [];
				
				menuLinks2.push({
					title : "Modificar filtro",
					name : "Modificar filtro",
					fun : function(event) {
						show_filterModal();
					}
				});
				menuLinks2.push({
					title : "Quitar filtro",
					name : "Quitar filtro",
					fun : function(event) {
						filterView.set("selectedOperator", null);
						filterView.set("selectedValue", null);
						filterView.set("selectedField", null);
						
						$('#addFilterBtn').css({'display' : 'block'});	
						$('#removeFilterBtn').css({'display' : 'none'});
						
						$('#helpTableContainer').html("<table class=\"helpTable table table-hover dataTable no-footer \"></table>");
						view.getHelpData(help);
					}
				});
				
				$('#removeFilterBtn').contextMenu(menuLinks2);
			}
			
			show_helpsModal();
			
			if(help.input) {
				this.getHelpData(help);
			}
			else{
				this.drawHelp(help);
			}
		}
	},
	
	getHelpData : function(help){
		var view = this;
		
		var result = this.getHelpParameters(help);
		
		var parametersIds = result.parametersIds;
		var parametersValues = result.parametersValues;
		
		parametersIds += "TIENEFILTRO,CAMPO,OPERADOR,VALOR";
		parametersValues += "0, , , ,";				
		
		Ember.$.post(help.page.dataServiceUrl, {
			"service" : help.input.service,
			"serviceType" : "help",
			"parameters" : parametersIds,
			"values" : parametersValues
		}).then(function(response) {
			try{
				var values = jQuery.parseJSON(response)[0].Entity2s.Entity2;	
				help.values = values;
	
				view.drawHelp(help);	
			}
			catch(e){}
		});
	},
	
	getHelpParameters : function(help){
		var parametersIds = "";
		var parametersValues = "";

		for (var i = 0; i < help.input.parameters.length; i++) {
			var pageAttribute = help.page.getAttribute(help.input.parameters[i]);
			
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
		
		return {
			"parametersIds" : parametersIds,
			"parametersValues" : parametersValues
		}
	},

	drawHelp : function(help){
		
		var view = this;

		var columns = [];
		var data = [];
		
		for (var i = 0; i < help.columns.length; i++) {
			if(!help.columns[i].hidden){
				columns.push({
					"sTitle" : help.columns[i].header,
					"mData" : help.columns[i].value
				});
			}
		}

		for (var i = 0; i < help.values.length; i++) {
			var jsonData = {};
			for (var j = 0; j < columns.length; j++) {
				jsonData[columns[j].mData] = help.values[i][columns[j].mData];
			}

			data.push(jsonData);
		}

		var columnsDefs = [];
		
		var j = 0;
		for(var i = 0; i < help.columns.length; i++) {
			if(!help.columns[i].hidden){			
				var columnSpan = help.columns[i].columnSpan ? Number(help.columns[i].columnSpan) : 2;
				columnsDefs.push({ "aTargets":[j++], "sClass":"col-sm-" +  columnSpan});	
			}
		}
	 
		var dataTable = $(".helpTable").dataTable({
			paging : false,
			pageLength : 0,
			info : false,
			ordering : false,
			deferRender : true,
			searching : false,
			lengthChange : false,
			responsive : true,
			bProcessing : true,
			aaData : data,
			aoColumns : columns,
			bLengthChange : false,
			dom : 't<"bottom"p><"clear">',
			aoColumnDefs : columnsDefs,
			language : {
				"lengthMenu" : "Mostrando _MENU_registros por página",
				"zeroRecords" : "No hay registros",
				"info" : "Mostrando página _PAGE_ de _PAGES_",
				"infoEmpty" : "No hay registros disponibles",
				"infoFiltered" : "(filtrados de _MAX_ registros)",
				"search" : "Buscar:",
				"loadingRecords" : "Cargando...",
				"processing" : "Procesando...",
				"thousands" : ".",
				"paginate" : {
					"first" : "Primera",
					"last" : "Última",
					"previous" : "Anterior",
					"next" : "Siguiente"
				}
			},
			createdRow : function(row, data, index) {		
				$(row).on('click', {
					help : help
				}, function() { 
					
					for (var i = 0; i < help.valueColumns.length; i++) {
						var column = help.valueColumns[i];						
						var value = help.values[index][column];
						
						var attribute = help.page.getAttribute(column);
						
						attribute.set("value", value);
					}

					var parentView = view.get('parentView');
					
					var filterView = parentView.get('childViews').filter(function(v) {
						return v["class"] === "filterModal";
					})[0];

					filterView.set("currentHelp", null);
					filterView.set("selectedOperator", null);
					filterView.set("selectedField", null);
					filterView.set("selectedValue", null);
					
					close_helpsModal();
				});
			}
		});
	},

	isNewNavigation : function(parameters, values){
		var controller = this.get('controller');
		
		for(i=0; i < parameters.length; i++){
			var valueIndex = controller.params.indexOf(parameters[i].substring(1, parameters[i].length - 1));					
				
			if("\"" + controller.values[valueIndex] + "\"" != values[i]){
				return true;
			}
		}
		
		return false;
	},
	
	watchSelectedPage : function() {
		if(this.selectedPage != null){
			this.get('controller').transitionToRoute("/" + this.selectedPage);
		}
	}.observes('selectedPage'),

	didInsertElement : function() {
		this._super();

		var bodyHeight = $('body').height();
		var winHeight = $(window).height();
		var headerSize = $('.header').height();
		var footerSize = $('.footer').height();

		this.setFrameContainerMinHeight();

		this.alturaPanel(headerSize, headerSize + footerSize);
		$('.user-other-info').css('width', 'auto');

		var page = this;
		$('.frame-container').resize(function() {
			var headerSize = $('.header').height();
			page.setFrameContainerMinHeight();

			page.alturaPanel(headerSize, headerSize + footerSize);
			$('.user-other-info').css('width', 'auto');
		});

		this._populateHomePages();
	},

	setFrameContainerMinHeight : function() {
		var bodyHeight = $('body').height();
		var winHeight = $(window).height();
		var headerSize = $('.header').height();
		var footerSize = $('.footer').height();
		var paddingTop = parseInt($('.frame-container').css('padding-top'));

		if (bodyHeight < winHeight) {
			$('.frame-container').css('min-height', winHeight - (headerSize + footerSize));
		}
	},

	alturaPanel : function(margenHeader, restarAltrura) {
		var winHeight = $('body').height();
		var heightNuevo = winHeight - restarAltrura;

		$('.parametersContainer').css({
			'height' : heightNuevo
		});
		$('.parametersPanel').css({
			'top' : margenHeader,
			'height' : heightNuevo
		});
	},

	_populateHomePages : function() {
		var sel = document.getElementById('homePages')

		if (sel && pages != null) {
			for (var i = 0; i < pages.length; i++) {
				var opt = document.createElement("option");
				opt.value = pages[i];
				opt.text = pages[i];

				sel.appendChild(opt);
			}
		}

		this.set("homePages", pages);
	}
});
App.LoginView = Ember.View.extend({});

App.PageView = Ember.View.extend({});

App.FrameView = Ember.View.extend({});

App.GridFrameView = App.FrameView.extend({});

App.GridsFrameView = App.FrameView.extend({});

App.FormFrameView = App.FrameView.extend({});

App.ImagesFrameView = App.FrameView.extend({});
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