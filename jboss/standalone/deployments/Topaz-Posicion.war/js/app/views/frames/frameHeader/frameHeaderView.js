App.FrameHeaderView = Ember.View.extend({
	frameIconStyle : function() {
		var loading = this.get('context.loading');
		
		if(loading){
			return '-animation: spin .7s infinite linear; -webkit-animation: spin2 .7s infinite linear;';
		}
		else{
			return 'width:24px;height:24px;margin: 0px; background-image: url(\'images/icons/' + this.get('context.iconImage') + '\')';
		}
	}.property('context.iconImage', 'context.loading'),	
		
	click : function(evt) {
		var frame = this.get('context');
		frame.set('isCollapsed', !frame.isCollapsed);
	}
});