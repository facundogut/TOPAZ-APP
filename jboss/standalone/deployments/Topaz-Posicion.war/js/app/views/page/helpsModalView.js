App.HelpsModalView = Ember.View.extend({
	didInsertElement : function() {
		this._super();			
	},

	actions : {
		helpClose : function(){
			close_helpsModal();
			
			var parentView = this.get('parentView');

			var filterView = parentView.get('childViews').filter(function(v) {
				return v["class"] === "filterModal";
			})[0];

			filterView.set("currentHelp", null);
			filterView.set("selectedOperator", null);
			filterView.set("selectedField", null);
			filterView.set("selectedValue", null);
		}
	}
});

function close_helpsModal() {
	$('#mask').fadeOut(200);
	$('#helpsModalContainer').fadeOut(200);
	$('.modal_window').fadeOut(200);
	
	$("body").css({"overflow":"visible"});

	$('#addFilterBtn').css({'display' : 'none'});	
	$('#removeFilterBtn').css({'display' : 'none'});
}

function show_helpsModal() {	
	$("body").css({"overflow":"hidden"});
	
	$('#mask').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#helpsModalContainer').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#helpsModalContainer').fadeTo(200, 1);
	$('#mask').fadeTo(200, 0.8);
	$('#helpModal').fadeIn(200);

	$('#helpTableContainer').html("<table class=\"helpTable table table-hover dataTable no-footer \"></table>");

	$('#helpsModalContainer').animate({ scrollTop: 0, scrollLeft:0 }, 0);
}

function close_filterModal() {
	$('#filterMask').fadeOut(200);
	$('#filterModalContainer').fadeOut(200);
}

function show_filterModal() {	
	$("body").css({"overflow":"hidden"});
	
	$('#filterMask').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#filterModalContainer').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#filterModalContainer').fadeTo(200, 1);
	$('#filterMask').fadeTo(200, 0.8);
	$('#filterModal').fadeIn(200);

	$('#filterModalContainer').animate({ scrollTop: 0, scrollLeft:0 }, 0);
}