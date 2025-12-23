Ember.TEMPLATES["ErrorsView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n		");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("FrameHeaderView"),
    'class': ("header-frame col-sm-12")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING",'class': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0,'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n		\r\n		<div class=\"content-frame\">		\r\n	  		<div ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":table-responsive isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n				");
  stack1 = helpers.each.call(depth0, "errors", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(2, program2, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n			</div>\r\n		</div>\r\n	");
  return buffer;
  }
function program2(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n				<div class=\"row\">\r\n	                <div class=\"alert alert-danger\" role=\"alert\">\r\n					  <span class=\"glyphicon glyphicon-exclamation-sign\" aria-hidden=\"true\"></span>\r\n					  <span class=\"sr-only\">Error:</span>\r\n					  ");
  data.buffer.push(escapeExpression(helpers._triageMustache.call(depth0, "", {hash:{
    'unescaped': ("true")
  },hashTypes:{'unescaped': "STRING"},hashContexts:{'unescaped': depth0},contexts:[depth0],types:["ID"],data:data})));
  data.buffer.push("\r\n					</div>\r\n	            </div>\r\n	            ");
  return buffer;
  }

  data.buffer.push("<div class=\"frame row errorFrame\">\r\n	");
  stack1 = helpers['with'].call(depth0, "errorData", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n</div>  ");
  return buffer;
  
});

Ember.TEMPLATES["FilesFrameView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n		<div  ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":contextMenu isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n			<ul>\r\n				<li><a class=\"btnLinks ion-link\" alt=\"Links\" title=\"Links\" role=\"button\"></a></li>\r\n			</ul>\r\n		</div>\r\n		");
  return buffer;
  }

function program3(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n					");
  stack1 = helpers.view.call(depth0, "filesTable", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(4, program4, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n				  ");
  return buffer;
  }
function program4(depth0,data) {
  
  
  data.buffer.push("\r\n					");
  }

  data.buffer.push("<div class=\"frame row\">\r\n	");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("FrameHeaderView"),
    'class': ("header-frame col-sm-12")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING",'class': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0,'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n	\r\n	<div class=\"content-frame\">\r\n		");
  stack1 = helpers['if'].call(depth0, "links", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n	  	<div ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":table-responsive isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n			<div class=\"col-md-12\">\r\n                 <div class=\"well-none\">	\r\n				  ");
  stack1 = helpers['with'].call(depth0, "data", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(3, program3, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("                     \r\n                 </div>\r\n             </div>\r\n		</div>\r\n	</div>\r\n</div>");
  return buffer;
  
});

Ember.TEMPLATES["FormFrameView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n		");
  stack1 = helpers.view.call(depth0, "frameLinks", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(2, program2, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n		");
  return buffer;
  }
function program2(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n		<div ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":contextMenu isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n			<ul>\r\n				<li><a class=\"btnLinks ion-link\" alt=\"Links\" title=\"Links\"></a></li>\r\n			</ul>\r\n		</div>\r\n		");
  return buffer;
  }

function program4(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n			<div class=\"row\">\r\n				");
  stack1 = helpers.each.call(depth0, {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(5, program5, data),contexts:[],types:[],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n            </div>\r\n            ");
  return buffer;
  }
function program5(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n					");
  stack1 = helpers.unless.call(depth0, "hidden", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(6, program6, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n				");
  return buffer;
  }
function program6(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n						");
  stack1 = helpers.view.call(depth0, "formField", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(7, program7, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n					");
  return buffer;
  }
function program7(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n	                       <label class=\"label-color col-sm-12 col-xs-12\">");
  stack1 = helpers._triageMustache.call(depth0, "label", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</label>\r\n	                       <label class=\"label-normal col-sm-12 col-xs-12\">");
  stack1 = helpers._triageMustache.call(depth0, "value", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</label>\r\n						");
  return buffer;
  }

  data.buffer.push("<div class=\"frame row\">		\r\n	");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("FrameHeaderView"),
    'class': ("header-frame col-sm-12")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING",'class': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0,'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n	\r\n	<div class=\"content-frame\">\r\n		");
  stack1 = helpers['if'].call(depth0, "links", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n	  	<div ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":table-responsive isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n			");
  stack1 = helpers.each.call(depth0, "data", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(4, program4, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n		</div>\r\n	</div>\r\n</div>");
  return buffer;
  
});

Ember.TEMPLATES["FrameHeaderView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n	<div class=\"icon-frame\">\r\n		<span ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'style': ("view.frameIconStyle")
  },hashTypes:{'style': "ID"},hashContexts:{'style': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(" ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': ("loading:glyphicon loading:glyphicon-refresh")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("></span>\r\n	</div>\r\n	<div class=\"name-frame\">\r\n		<h2>");
  stack1 = helpers._triageMustache.call(depth0, "title", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</h2>\r\n	</div>\r\n	<div class=\"expand-frame\">\r\n		<span ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":glyphicon isCollapsed:glyphicon-chevron-down:glyphicon-chevron-up")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("></span>\r\n	</div>\r\n");
  return buffer;
  }

  stack1 = helpers.view.call(depth0, "frameHeader", {hash:{
    'class': ("header-background-title")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n\r\n<div class=\"line-header-frame\"></div>\r\n<div class=\"clear\"></div>\r\n		");
  return buffer;
  
});

Ember.TEMPLATES["GridFrameView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, self=this, escapeExpression=this.escapeExpression;

function program1(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n			");
  stack1 = helpers.view.call(depth0, "table", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(2, program2, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n		  ");
  return buffer;
  }
function program2(depth0,data) {
  
  
  data.buffer.push("\r\n			");
  }

  data.buffer.push("<div class=\"frame row\">		\r\n	");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("FrameHeaderView"),
    'class': ("header-frame col-sm-12")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING",'class': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0,'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n	\r\n	<div class=\"content-frame\">\r\n	  	<div ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":table-responsive isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n		  ");
  stack1 = helpers['with'].call(depth0, "data", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n		</div>\r\n	</div>\r\n</div>");
  return buffer;
  
});

Ember.TEMPLATES["GridsFrameView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, self=this, escapeExpression=this.escapeExpression;

function program1(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n			<div class=\"grids-row\">\r\n				");
  stack1 = helpers.each.call(depth0, "formData", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(2, program2, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n	            \r\n          		");
  stack1 = helpers['with'].call(depth0, "gridData", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(7, program7, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n		  </div>\r\n          ");
  return buffer;
  }
function program2(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n				<div class=\"row\">\r\n					");
  stack1 = helpers.each.call(depth0, {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(3, program3, data),contexts:[],types:[],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n	            </div>\r\n	            ");
  return buffer;
  }
function program3(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n						");
  stack1 = helpers.unless.call(depth0, "hidden", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(4, program4, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n					");
  return buffer;
  }
function program4(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n							");
  stack1 = helpers.view.call(depth0, "formField", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(5, program5, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n						");
  return buffer;
  }
function program5(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n		                       <label class=\"label-color col-sm-12 col-xs-12\">");
  stack1 = helpers._triageMustache.call(depth0, "label", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</label>\r\n		                       <label class=\"label-normal col-sm-12 col-xs-12\">");
  stack1 = helpers._triageMustache.call(depth0, "value", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</label>\r\n							");
  return buffer;
  }

function program7(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n			  		");
  stack1 = helpers.view.call(depth0, "table", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(8, program8, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n			  	");
  return buffer;
  }
function program8(depth0,data) {
  
  
  data.buffer.push("\r\n					");
  }

  data.buffer.push("<div class=\"frame row\">\r\n	");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("FrameHeaderView"),
    'class': ("header-frame col-sm-12")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING",'class': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0,'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n		\r\n  	<div ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":table-responsive isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n		");
  stack1 = helpers.each.call(depth0, "data", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n	</div>\r\n</div>");
  return buffer;
  
});

Ember.TEMPLATES["HeaderView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var stack1, escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n	<!--header-->\r\n	<div class=\"row-1-header col-sm-12\">\r\n		<div class=\"logo\"></div>\r\n		\r\n		");
  stack1 = helpers['if'].call(depth0, "model", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(2, program2, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n		<div class=\"clear\"></div>\r\n	</div>\r\n	<div class=\"row-2-header col-sm-12\">\r\n		<div class=\"name-app\">\r\n			<p>TOPAZ PERSPECTIVA 360</p>\r\n		</div>  \r\n		\r\n		");
  stack1 = helpers['if'].call(depth0, "model", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(4, program4, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n		\r\n		<div class=\"clear\"></div>\r\n	</div>\r\n");
  return buffer;
  }
function program2(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n		<div class=\"user-other-info\">\r\n			<ul>\r\n				<li><i class=\"ion-person\" title=\"Usuario\" style=\"float: left;\"></i><p style=\" float: right;margin: 0px;padding-top: 4px;\">");
  stack1 = helpers._triageMustache.call(depth0, "view.userName", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</p></li>\r\n				<!-- li class=\"white-line\"></li>\r\n				<li><i class=\"ion-monitor\" title=\"Máquina\"></i>11</li>\r\n				<li class=\"white-line\"></li>\r\n				<li><i class=\"ion-home\" title=\"Sucursal\"></i>1</li-->\r\n				<li class=\"white-line\"></li>\r\n				<li><i class=\"ion-calendar\" title=\"Fecha de Proceso\"></i>");
  stack1 = helpers._triageMustache.call(depth0, "view.today", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</li>\r\n				<li><a class=\"round-responsive-btn logout-btn\" title=\"Salir\" ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "logOutClick", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["STRING"],data:data})));
  data.buffer.push(" role=\"button\"><i class=\"glyphicon glyphicon-log-out\"></i></a></li>\r\n			</ul>\r\n			<div class=\"clear\"></div>\r\n		</div>\r\n		");
  return buffer;
  }

function program4(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n		<div class=\"actions-menu-header\">\r\n			<ul>\r\n				<li><a class=\"round-responsive-btn logout-btn\" title=\"Salir\" ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "logOutClick", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["STRING"],data:data})));
  data.buffer.push(" role=\"button\"><i class=\"glyphicon glyphicon-log-out\"></i></a></li>\r\n			</ul>	\r\n			<!--ul>\r\n				<li><a class=\"menu-btn\" title=\"Menú de Apps\"></a></li>\r\n				<li><a class=\"help-btn\" title=\"Ayuda\"></a></li>\r\n			</ul-->\r\n			<div class=\"clear\"></div>\r\n		</div>\r\n		");
  return buffer;
  }

  stack1 = helpers.view.call(depth0, "header", {hash:{
    'class': ("header row")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  else { data.buffer.push(''); }
  
});

Ember.TEMPLATES["ImagesFrameView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n		<div  ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":contextMenu isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n			<ul>\r\n				<li><a class=\"btnLinks ion-link\" alt=\"Links\" title=\"Links\"></a></li>\r\n			</ul>\r\n		</div>\r\n		");
  return buffer;
  }

function program3(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n                   	");
  stack1 = helpers.view.call(depth0, "gallery", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(4, program4, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("    \r\n					");
  return buffer;
  }
function program4(depth0,data) {
  
  
  data.buffer.push("     \r\n						<div class=\"carousel-inner\">\r\n                           </div>\r\n                           <a class=\"left carousel-control\" data-slide=\"prev\"><i class=\"glyphicon glyphicon-chevron-left\"></i></a>            \r\n                           <a class=\"right carousel-control\" data-slide=\"next\"><i class=\"glyphicon glyphicon-chevron-right\"></i></a>\r\n					");
  }

  data.buffer.push("<div class=\"frame row\">\r\n	");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("FrameHeaderView"),
    'class': ("header-frame col-sm-12")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING",'class': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0,'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n	\r\n	<div class=\"content-frame\">\r\n		");
  stack1 = helpers['if'].call(depth0, "links", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n	  	<div ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":table-responsive isCollapsed:collapse")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">\r\n			<div class=\"col-md-12\">\r\n                   <div class=\"well-none\">	\r\n					");
  stack1 = helpers['with'].call(depth0, "data", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(3, program3, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("                        \r\n                   </div>\r\n               </div>\r\n		</div>\r\n	</div>\r\n</div>");
  return buffer;
  
});

Ember.TEMPLATES["LoginView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, escapeExpression=this.escapeExpression, self=this;

function program1(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n					<div role=\"alert\" class=\"errorMessage form-group\">\r\n						 ");
  stack1 = helpers._triageMustache.call(depth0, "response", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n					</div>\r\n					");
  return buffer;
  }

  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("HeaderView")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n\r\n<div class=\"loginContainer\">\r\n   	<div class=\"row\">\r\n   	    <div class=\"col-xs-12\">\r\n       	    <div class=\"form-wrap\">\r\n       	    	<div class=\"loginHeader\">\r\n      	    			<div class=\"loginImg\">\r\n						<span><i class=\"glyphicon glyphicon-log-in\"></i></span>\r\n					</div>\r\n					<div><h2>LOGIN</h2></div>\r\n					<div style=\"clear: both;float:none;\"></div>\r\n                </div>\r\n				<form role=\"form\" action=\"LoginServlet\" method=\"post\" id=\"login-form\" autocomplete=\"on\">\r\n					<div class=\"form-group\">\r\n						<label for=\"user\" >USUARIO</label>\r\n					    <input type=\"user\" name=\"user\" id=\"user\" class=\"inputControl\" >\r\n					</div>\r\n					<div class=\"form-group\">\r\n				       <label for=\"key\" >CONTRASEÑA</label>\r\n				       <input type=\"password\" name=\"pw\" id=\"key\" class=\"inputControl\">\r\n					</div>\r\n					");
  stack1 = helpers['if'].call(depth0, "response", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n					<input type=\"submit\" id=\"btn-login\" class=\"btn btnLogin btn-lg btn-block\" value=\"ACEPTAR\">\r\n				</form>\r\n       	    </div>\r\n   		</div>\r\n   	</div>\r\n</div>\r\n<div class=\"loginWrapper\">\r\n</div>");
  return buffer;
  
});

Ember.TEMPLATES["PageView"] = Ember.Handlebars.template(function anonymous(Handlebars,depth0,helpers,partials,data) {
this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Ember.Handlebars.helpers); data = data || {};
  var buffer = '', stack1, escapeExpression=this.escapeExpression, helperMissing=helpers.helperMissing, self=this;

function program1(depth0,data) {
  
  
  data.buffer.push("\r\n<div id=\"imagesModalContainer\" class=\"imagesModal\">\r\n	<div id=\"newWindowButton\">\r\n		<a class=\"downloadFile-btn\"><i class=\"glyphicon glyphicon-new-window\"></i></a>\r\n	</div> \r\n	<div id=\"imageModal\" class=\"modal_window imagesModal\"></div>\r\n</div>\r\n");
  }

function program3(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n<div id=\"helpsModalContainer\" class=\"helpsModal\">\r\n	<div id=\"helpModal\" class=\"modal_window helpsModal\">\r\n		<div class=\"helpContainer\">\r\n			<h2 id=\"helpTitle\"></h2>\r\n			   \r\n			<a id=\"addFilterBtn\" class=\"filterBtn glyphicon glyphicon-filter\" alt=\"Filtros\" title=\"Filtros\" style=\"display:none;\"></a>\r\n			<a id=\"removeFilterBtn\" class=\"removeFilterBtn filterBtn glyphicon glyphicon-filter\" alt=\"Filtros\" title=\"Filtros\" style=\"display:none;\"></a>\r\n			\r\n			<a class=\"close-btn\" ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "helpClose", {hash:{
    'target': ("view")
  },hashTypes:{'target': "ID"},hashContexts:{'target': depth0},contexts:[depth0],types:["STRING"],data:data})));
  data.buffer.push("><i class=\"glyphicon glyphicon-remove\"></i></a>\r\n			<div id=\"helpTableContainer\"></div>\r\n		</div>\r\n	</div> \r\n</div> \r\n");
  return buffer;
  }

function program5(depth0,data) {
  
  var buffer = '', stack1, helper, options;
  data.buffer.push("\r\n	<div id=\"filterModal\" class=\"modal_window helpsModal\">\r\n		<div class=\"helpContainer\">\r\n			<h2>FILTRADO DE REGISTROS</h2>\r\n			\r\n			<a class=\"close-btn\" ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "closeModal", {hash:{
    'target': ("view")
  },hashTypes:{'target': "ID"},hashContexts:{'target': depth0},contexts:[depth0],types:["STRING"],data:data})));
  data.buffer.push(" role=\"button\"><i class=\"glyphicon glyphicon-remove\"></i></a>\r\n			\r\n			<div class=\"row\">\r\n				<label class=\"label-color col-sm-12 col-xs-12\" style=\"text-transform: uppercase; text-align: left; margin-bottom: 5px; margin-top: 35px;\">CAMPO</label>\r\n			   	");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, "Ember.Select", {hash:{
    'content': ("view.fields"),
    'value': ("view.selectedField"),
    'optionValuePath': ("content.value"),
    'optionLabelPath': ("content.description"),
    'class': ("form-control"),
    'prompt': ("Seleccione un campo...")
  },hashTypes:{'content': "ID",'value': "ID",'optionValuePath': "STRING",'optionLabelPath': "STRING",'class': "STRING",'prompt': "STRING"},hashContexts:{'content': depth0,'value': depth0,'optionValuePath': depth0,'optionLabelPath': depth0,'class': depth0,'prompt': depth0},contexts:[depth0],types:["ID"],data:data})));
  data.buffer.push("\r\n			</div>  \r\n			<div class=\"row\">\r\n				<label class=\"label-color col-sm-12 col-xs-12\" style=\"text-transform: uppercase; text-align: left; margin-bottom: 5px;\">OPERADOR</label>\r\n			   	");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, "Ember.Select", {hash:{
    'content': ("view.operators"),
    'value': ("view.selectedOperator"),
    'optionValuePath': ("content.value"),
    'optionLabelPath': ("content.description"),
    'class': ("form-control"),
    'prompt': ("Seleccione un operador...")
  },hashTypes:{'content': "ID",'value': "ID",'optionValuePath': "STRING",'optionLabelPath': "STRING",'class': "STRING",'prompt': "STRING"},hashContexts:{'content': depth0,'value': depth0,'optionValuePath': depth0,'optionLabelPath': depth0,'class': depth0,'prompt': depth0},contexts:[depth0],types:["ID"],data:data})));
  data.buffer.push("\r\n			</div>  \r\n			<div class=\"row\">\r\n				<label class=\"label-color col-sm-12 col-xs-12\" style=\"text-transform: uppercase; text-align: left; margin-bottom: 5px;\">VALOR</label>\r\n                ");
  data.buffer.push(escapeExpression((helper = helpers.input || (depth0 && depth0.input),options={hash:{
    'type': ("text"),
    'value': ("view.selectedValue"),
    'action': ("onFilterChange"),
    'targetObject': ("view"),
    'class': ("form-control")
  },hashTypes:{'type': "STRING",'value': "ID",'action': "STRING",'targetObject': "ID",'class': "STRING"},hashContexts:{'type': depth0,'value': depth0,'action': depth0,'targetObject': depth0,'class': depth0},contexts:[],types:[],data:data},helper ? helper.call(depth0, options) : helperMissing.call(depth0, "input", options))));
  data.buffer.push("\r\n			</div>    \r\n			");
  stack1 = helpers['if'].call(depth0, "view.error", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(6, program6, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n			<div class=\"row\">\r\n				<a  ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":round-btn :send-btn ")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(" title=\"Enviar\" ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "onFilterChange", {hash:{
    'target': ("view")
  },hashTypes:{'target': "ID"},hashContexts:{'target': depth0},contexts:[depth0],types:["STRING"],data:data})));
  data.buffer.push(" role=\"button\"><i class=\"glyphicon glyphicon-ok\" ></i></a>\r\n			</div> \r\n		</div>\r\n	</div>\r\n");
  return buffer;
  }
function program6(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n			<div role=\"alert\" class=\"errorMessage form-group\">\r\n				 ");
  stack1 = helpers._triageMustache.call(depth0, "view.error", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n			</div>\r\n			");
  return buffer;
  }

function program8(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n<div id=\"disabledPageModalContainer\" class=\"helpsModal\">\r\n	<div id=\"disabledPageModal\" class=\"modal_window helpsModal\">\r\n		<div class=\"helpContainer\" style=\"width: 410px; text-align: left;\">\r\n			<h2>Seguridad</h2>\r\n			\r\n			<a class=\"close-btn\" ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "closeModal", {hash:{
    'target': ("view")
  },hashTypes:{'target': "ID"},hashContexts:{'target': depth0},contexts:[depth0],types:["STRING"],data:data})));
  data.buffer.push(" role=\"button\"><i class=\"glyphicon glyphicon-remove\"></i></a>\r\n			\r\n			<div id=\"helpTableContainer\">\r\n				Usted no tiene los permisos necesarios para acceder a la pagina solicitada.\r\n			</div>\r\n		</div>\r\n	</div> \r\n</div> \r\n");
  return buffer;
  }

function program10(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n		");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("errorData"),
    'templateName': ("ErrorsView")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n	");
  return buffer;
  }

function program12(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n		");
  stack1 = helpers.each.call(depth0, "frames", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(13, program13, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n	");
  return buffer;
  }
function program13(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n			");
  stack1 = helpers['if'].call(depth0, "isEnabled", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(14, program14, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n		");
  return buffer;
  }
function program14(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n				");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("templateName")
  },hashTypes:{'contentBinding': "STRING",'templateName': "ID"},hashContexts:{'contentBinding': depth0,'templateName': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n			");
  return buffer;
  }

function program16(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n	\r\n   		<div ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":parametersContainer showParametersPanel:show:hide")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(">    	\r\n	 \r\n	       	<div class=\"parametersComboBox\"> \r\n	       		");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, "Ember.Select", {hash:{
    'content': ("view.homePages"),
    'value': ("view.selectedPage"),
    'optionValuePath': ("content.value"),
    'optionLabelPath': ("content.description"),
    'class': ("form-control"),
    'prompt': ("Navegar a...")
  },hashTypes:{'content': "ID",'value': "ID",'optionValuePath': "STRING",'optionLabelPath': "STRING",'class': "STRING",'prompt': "STRING"},hashContexts:{'content': depth0,'value': depth0,'optionValuePath': depth0,'optionLabelPath': depth0,'class': depth0,'prompt': depth0},contexts:[depth0],types:["ID"],data:data})));
  data.buffer.push("\r\n			</div>\r\n			\r\n			<div class=\"parametersGroup\">\r\n				");
  stack1 = helpers.each.call(depth0, "previousPages", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(17, program17, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("         \r\n			\r\n				<div class=\"parameter row\">\r\n					<div class=\"parameterHeader col-sm-12\">\r\n						");
  stack1 = helpers.view.call(depth0, "parameterHeader", {hash:{
    'class': ("parameter-background-title")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},inverse:self.noop,fn:self.program(22, program22, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n						<div class=\"line-parameterHeader\"></div>\r\n						<div class=\"clear\"></div>\r\n					</div>\r\n					<div class=\"parameterContent\">     \r\n						");
  stack1 = helpers.each.call(depth0, "attributes", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(24, program24, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n						\r\n						<a  ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":round-btn :send-btn view.loading:disabled-btn")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(" title=\"Enviar\" ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "onParameterChange", {hash:{
    'target': ("view")
  },hashTypes:{'target': "ID"},hashContexts:{'target': depth0},contexts:[depth0],types:["STRING"],data:data})));
  data.buffer.push(" role=\"button\"><i class=\"glyphicon glyphicon-ok\" ></i></a>\r\n												\r\n						");
  stack1 = helpers['if'].call(depth0, "parametersError", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(27, program27, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n					</div>\r\n				</div>   \r\n			</div> \r\n    	</div>  	\r\n    	\r\n	   	<div class=\"showParametersPanelButton\"> \r\n			<a ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "parametersPanelButtonClick", {hash:{
    'target': ("view")
  },hashTypes:{'target': "ID"},hashContexts:{'target': depth0},contexts:[depth0],types:["STRING"],data:data})));
  data.buffer.push(" ");
  data.buffer.push(escapeExpression(helpers['bind-attr'].call(depth0, {hash:{
    'class': (":arrow-menu-btn showParametersPanel:closeArrow:openArrow")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},contexts:[],types:[],data:data})));
  data.buffer.push(" role=\"button\"></a>\r\n	    </div>\r\n	   	<div class=\"clear\"></div>\r\n");
  return buffer;
  }
function program17(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n					<div class=\"parameter row\" >\r\n						<div class=\"parameterHeader col-sm-12\">\r\n							");
  stack1 = helpers.view.call(depth0, "parameterHeader", {hash:{
    'class': ("parameter-background-title")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},inverse:self.noop,fn:self.program(18, program18, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n							<div class=\"line-parameterHeader\"></div>\r\n							<div class=\"clear\"></div>\r\n						</div> \r\n						<div class=\"parameterContent\" style=\"display: none;\">     \r\n						");
  stack1 = helpers.each.call(depth0, "attributes", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(20, program20, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n						</div>\r\n					</div>\r\n				");
  return buffer;
  }
function program18(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n								<div class=\"parameterName\">\r\n									<h2>");
  stack1 = helpers._triageMustache.call(depth0, "title", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</h2>\r\n								</div>\r\n								<div class=\"parameterExpand\">\r\n									<span class=\"glyphicon glyphicon-chevron-down\"></span>\r\n								</div>\r\n							");
  return buffer;
  }

function program20(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("  \r\n							  <div class=\"row\">\r\n								<label class=\"label-color col-sm-12 col-xs-12\" style=\"text-transform: uppercase;\">");
  stack1 = helpers._triageMustache.call(depth0, "key", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</label>\r\n								<label class=\"label-normal col-sm-12 col-xs-12\">");
  stack1 = helpers._triageMustache.call(depth0, "value", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</label>\r\n							  </div>    \r\n						");
  return buffer;
  }

function program22(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n							<div class=\"parameterName\">\r\n									<h2>");
  stack1 = helpers._triageMustache.call(depth0, "id", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</h2>\r\n							</div>\r\n							<div class=\"parameterExpand\">\r\n								<span class=\"glyphicon glyphicon-chevron-up\"></span>\r\n							</div>\r\n						");
  return buffer;
  }

function program24(depth0,data) {
  
  var buffer = '', stack1, helper, options;
  data.buffer.push("  \r\n						   <div class=\"row\">\r\n								<label class=\"label-color col-sm-12 col-xs-12\" style=\"text-transform: uppercase;\">");
  stack1 = helpers._triageMustache.call(depth0, "label", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("</label>\r\n								\r\n								<div class=\"has-feedback\">\r\n                                  	");
  data.buffer.push(escapeExpression((helper = helpers.input || (depth0 && depth0.input),options={hash:{
    'type': ("text"),
    'value': ("value"),
    'action': ("onParameterChange"),
    'targetObject': ("view"),
    'title': ("tooltip"),
    'class': ("form-control")
  },hashTypes:{'type': "STRING",'value': "ID",'action': "STRING",'targetObject': "ID",'title': "ID",'class': "STRING"},hashContexts:{'type': depth0,'value': depth0,'action': depth0,'targetObject': depth0,'title': depth0,'class': depth0},contexts:[],types:[],data:data},helper ? helper.call(depth0, options) : helperMissing.call(depth0, "input", options))));
  data.buffer.push("\r\n                                  	\r\n									");
  stack1 = helpers['if'].call(depth0, "help", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(25, program25, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n								</div>\r\n						   </div>    \r\n						");
  return buffer;
  }
function program25(depth0,data) {
  
  var buffer = '';
  data.buffer.push("\r\n  										<a ");
  data.buffer.push(escapeExpression(helpers.action.call(depth0, "helpClick", "help", {hash:{
    'target': ("view")
  },hashTypes:{'target': "ID"},hashContexts:{'target': depth0},contexts:[depth0,depth0],types:["STRING","ID"],data:data})));
  data.buffer.push(" role=\"button\" class=\"round-btn form-control-feedback\"><p style=\"line-height: normal;\">?</p></a>\r\n									");
  return buffer;
  }

function program27(depth0,data) {
  
  var buffer = '', stack1;
  data.buffer.push("\r\n						<div role=\"alert\" class=\"errorMessage form-group\">\r\n							 ");
  stack1 = helpers._triageMustache.call(depth0, "parametersError", {hash:{},hashTypes:{},hashContexts:{},contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n						</div>\r\n						");
  return buffer;
  }

  data.buffer.push("<!--Modal-->   	\r\n<div id=\"mask\" ></div>     \r\n");
  stack1 = helpers.view.call(depth0, "imagesModal", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(1, program1, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n");
  stack1 = helpers.view.call(depth0, "helpsModal", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(3, program3, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n\r\n<div id=\"filterMask\" ></div>   \r\n");
  stack1 = helpers.view.call(depth0, "filterModal", {hash:{
    'class': ("filterModal"),
    'id': ("filterModalContainer")
  },hashTypes:{'class': "STRING",'id': "STRING"},hashContexts:{'class': depth0,'id': depth0},inverse:self.noop,fn:self.program(5, program5, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n\r\n<div id=\"disabledPageMask\" ></div>\r\n");
  stack1 = helpers.view.call(depth0, "disabledPageModal", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(8, program8, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n\r\n");
  data.buffer.push(escapeExpression(helpers.view.call(depth0, {hash:{
    'contentBinding': ("this"),
    'templateName': ("HeaderView")
  },hashTypes:{'contentBinding': "STRING",'templateName': "STRING"},hashContexts:{'contentBinding': depth0,'templateName': depth0},contexts:[],types:[],data:data})));
  data.buffer.push("\r\n \r\n<div class=\"frame-container\">    \r\n	");
  stack1 = helpers['if'].call(depth0, "hasErrors", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(10, program10, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n	  \r\n	");
  stack1 = helpers['if'].call(depth0, "showFrames", {hash:{},hashTypes:{},hashContexts:{},inverse:self.noop,fn:self.program(12, program12, data),contexts:[depth0],types:["ID"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n</div>\r\n");
  stack1 = helpers.view.call(depth0, "parametersPanel", {hash:{
    'class': ("parametersPanel")
  },hashTypes:{'class': "STRING"},hashContexts:{'class': depth0},inverse:self.noop,fn:self.program(16, program16, data),contexts:[depth0],types:["STRING"],data:data});
  if(stack1 || stack1 === 0) { data.buffer.push(stack1); }
  data.buffer.push("\r\n   \r\n   	<!--Footer-->\r\n	<div class=\"footer row\"></div> \r\n	\r\n");
  return buffer;
  
});