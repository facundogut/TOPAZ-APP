App.DisabledPageModalView = Ember.View.extend({
	actions : {
		closeModal : function(){
			close_disabledPageModal();
		}
	}
});

function close_disabledPageModal() {
	$('#disabledPageMask').fadeOut(200);
	$('#disabledPageModalContainer').fadeOut(200);
}

function show_disabledPageModal() {	

	var body = document.body;
	var html = document.documentElement;
	var alturaDoc = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
	$('#disabledPageMask').css({'height' : alturaDoc + 'px'});	
	
	$('#disabledPageMask').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#disabledPageModalContainer').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#disabledPageModalContainer').fadeTo(200, 1);
	$('#disabledPageMask').fadeTo(200, 0.8);
	$('#disabledPageModal').fadeIn(200);
}