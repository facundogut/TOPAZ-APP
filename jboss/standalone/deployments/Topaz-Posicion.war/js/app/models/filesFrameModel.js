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