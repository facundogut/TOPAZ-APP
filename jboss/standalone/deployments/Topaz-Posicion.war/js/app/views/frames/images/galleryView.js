App.GalleryView = Em.View.extend({
	classNames : [ 'carousel', 'slide' ],
	imageUrl : function() {
		return this.get('context').toString();
	}.property(),
	didInsertElement : function(evt) {

		var controller = this.get('controller');
		var page = controller.get('model');
		var imagesData = this.get('context');

		var serverFolder = controller.const.imagesFolderUrl;	
				
		var element = this.get('element');

		var carouselId = element.id;
		if(imagesData.length > 1){
			$(element).find(".carousel-control").prop("href", "#" + carouselId);
		}else{
			$(element).find(".carousel-control").css({
				'display' : 'none'
			});
		}

		var e = "";
		var firstItemClass = "active";
		for (var i = 0; i < imagesData.length; i++) {
			e += "<div class=\"item " + firstItemClass + "\"><div class=\"row\">";
			firstItemClass = "";
			
			for (var j = 0; j < imagesData[i].length; j++) {

				e += "<div class=\"col-sm-2 col-xs-4\">";
				e += "<a class=\"activate_modal thumbnail\"><img src=\"" + serverFolder + imagesData[i][j] + "\" alt=\"Image\" class=\"img-responsive\"></a>";
				e += "</div>";
			}

			e += "</div></div>";
		}
				
		$(element).find(".carousel-inner").append(e);
		
		$(element).find('.activate_modal').click(function() {
			var src_img = $(this).children('img').attr('src');
			var htmlContent = '<img src="' + src_img + '">';
			show_imagesModal(htmlContent);
		});
		
	
		var body = document.body;
		var html = document.documentElement;
	
		var alturaDoc = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
		$('#mask').css({
			'height' : alturaDoc + 'px'
		});	
		
		$(element).carousel({
			interval : 0
		})
	}
});
