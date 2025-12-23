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
