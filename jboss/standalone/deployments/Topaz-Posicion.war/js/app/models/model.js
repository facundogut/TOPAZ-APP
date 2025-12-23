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
