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