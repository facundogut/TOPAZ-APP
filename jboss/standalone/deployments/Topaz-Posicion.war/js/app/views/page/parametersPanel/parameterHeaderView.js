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