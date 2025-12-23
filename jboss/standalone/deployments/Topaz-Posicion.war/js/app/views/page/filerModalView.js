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