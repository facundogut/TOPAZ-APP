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