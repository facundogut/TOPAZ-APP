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
