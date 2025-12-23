App.FormFieldView = Ember.View.extend({
	classNameBindings : [ 'columnSpan', 'defaultClass'],
	
	defaultClass : function() {
		return 'col-xs-6';
	}.property(),
	
	columnSpan : function() {
		return 'col-sm-' + this.get('context.columnSpan');
	}.property('context.columnSpan')
});
