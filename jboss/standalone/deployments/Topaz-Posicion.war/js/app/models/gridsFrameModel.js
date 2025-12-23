
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
