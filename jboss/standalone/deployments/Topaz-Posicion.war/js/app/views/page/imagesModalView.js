App.ImagesModalView = Ember.View.extend({
	didInsertElement : function() {
		this._super();
		
		$("#mask").unbind('click');
		$('#mask').click(function() {
			close_imagesModal();

			$("#mask").unbind('click');
		});		

		$(".imagesModal").unbind('click');
		$('.imagesModal').click(function() {
			close_imagesModal();
		});		

		$("#newWindowButton").unbind('click');
		$('#newWindowButton').click(function() {
			var url = $('#imageModal img').attr('src');
			window.open(url, '_blank');
		});			
	}
});

function close_imagesModal() {
	$('#mask').fadeOut(500);
	$('#imagesModalContainer').fadeOut(500);
	$('.modal_window').fadeOut(500);
	
	$("body").css({"overflow":"visible"});
}

function show_imagesModal(htmlContent) {	
	$("body").css({"overflow":"hidden"});
	
	$('#mask').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#imagesModalContainer').css({
		'display' : 'block',
		opacity : 0
	});
	
	$('#imagesModalContainer').fadeTo(200, 1);
	$('#mask').fadeTo(200, 0.8);
	$('#imageModal').fadeIn(200);

	$('#imageModal').html(htmlContent);

	$('#imagesModalContainer').animate({ scrollTop: 0, scrollLeft:0 }, 0);
}