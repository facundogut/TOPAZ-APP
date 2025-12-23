<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ page import="model.Navegacion"%>
<%@ page import="dataAccess.Config"%>
<%@ page import="org.eclipse.jdt.internal.compiler.ast.*"%>
<%@ page import="model.TopazMiddleWareSimpleResponse"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<title>Posición cliente</title>

<!--Bootstrap-->
<link href="css/globalStyles.min.css" rel="stylesheet" type="text/css" />
<link href='css/ionicons.min.css' rel='stylesheet' type='text/css'>
<link href="css/bootstrap.min.css" rel="stylesheet" type="text/css" />

<!--Context Menu-->
<link href="js/lib/contextMenu.js-master/contextMenu.css" rel="stylesheet" type="text/css" />

<!--Scripts-->
<script src="js/libs.min.js"></script>
<script type="text/javascript">
	window.App = Ember.Application.create();
		
	App.Constants = Ember.Object.extend({ 
		imagesFolderUrl: '<%= Config.getProperty("serverUrl") + Config.getProperty("imagesFolder") %>',
		filesFolderUrl: '<%= Config.getProperty("serverUrl")  + Config.getProperty("filesFolder") %>'
	});
</script>
<script src="js/scripts.min.js"></script>
<script src="js/templates.min.js"></script>

<script type="text/javascript">
	var pages =  <%= this.getHomePagesString((TopazMiddleWareSimpleResponse) request.getSession(true).getAttribute("userPages")) %>;
	var disabledFrames = <%= this.getPageDisabledFramesString((TopazMiddleWareSimpleResponse) request.getSession(true).getAttribute("userPages")) %>;
	var disabledPages = <%= this.getDisabledPagesString((TopazMiddleWareSimpleResponse) request.getSession(true).getAttribute("userPages")) %>;
	var userName = <%= "\"" + request.getSession(true).getAttribute("currentSessionUser") + "\"" %>;
</script>

</head>
<body>
	<script type="text/x-handlebars" data-template-name="index">
		{{view contentBinding="this" templateName="LoginView"}}
	</script>

	<script type="text/x-handlebars" data-template-name="page">
		{{view contentBinding="this" templateName="PageView" class="mainPage"}}
    </script>
</body>
</html>
	
<%!
	public String getDisabledPagesString(TopazMiddleWareSimpleResponse pages)
	{
		if(pages == null || pages.getNavegaciones().size() == 0)
		{
			return "[]";
		}
		else
		{	
			List<Navegacion> pagesDisabled = new ArrayList<Navegacion>();
			for(Navegacion n:pages.getNavegaciones())
			{
				if (n.getFrameCode() == 0 &&  n.getIsEnabled() == 0) 
				{
					pagesDisabled.add(n);
				}
			}
	
			String disabledJSArray = "[";
			for(int i = 0; i < pagesDisabled.size(); i++)		
			{
				Navegacion page = pagesDisabled.get(i);
				
				disabledJSArray += "\"" + page.getJson() + "\" ,";
			}
			
			if(disabledJSArray.length() > 1)
			{
				disabledJSArray = disabledJSArray.substring(0, disabledJSArray.length() - 1);
			}
						
			disabledJSArray += "]";
			
			
			return disabledJSArray;
		}
	}

	public String getPageDisabledFramesString(TopazMiddleWareSimpleResponse pages)
	{
		if(pages == null || pages.getNavegaciones().size() == 0)
		{
			return "null";
		}
		else
		{	
			List<Navegacion> framesDisabled = new ArrayList<Navegacion>();
			for(Navegacion n:pages.getNavegaciones())
			{
				if (n.getFrameCode() != 0 &&  n.getIsEnabled() == 0) 
				{
					framesDisabled.add(n);
				}
			}
	
			String disabledJSArray = "[";
			for(int i = 0; i < framesDisabled.size(); i++)		
			{
				Navegacion frame = framesDisabled.get(i);
				
				disabledJSArray += "{page:\"" + this.getFramePageId(pages, frame) + "\", frameId:\""+ frame.getJson() +"\"} ,";
			}
			
			if(disabledJSArray.length() > 1)
			{
				disabledJSArray = disabledJSArray.substring(0, disabledJSArray.length() - 1);
			}
						
			disabledJSArray += "]";
			
			
			return disabledJSArray;
		}
	}

	public String getFramePageId(TopazMiddleWareSimpleResponse pages, Navegacion page)
	{
		for(Navegacion n:pages.getNavegaciones())
		{
			if (n.getFrameCode() == 0 &&  n.getNavigationCode() == page.getNavigationCode()) 
			{
				return n.getJson();
			}
		}
		
		return "";
	}

	public String getHomePagesString(TopazMiddleWareSimpleResponse pages)
	{
		if(pages == null || pages.getNavegaciones().size() == 0)
		{
			return "null";
		}
		else
		{	
			List<Navegacion> navegaciones = new ArrayList<Navegacion>();
			for(Navegacion n:pages.getNavegaciones())
			{
				if (n.getFrameCode() == 0 &&  n.getIsHome() == 1) 
				{
					navegaciones.add(n);
				}
			}
	
			String pagesJSArray = "[";
			for(int i = 0; i < navegaciones.size(); i++)		
			{
				Navegacion navegacion = navegaciones.get(i);
				
				if(navegacion.getIsEnabled() == 1){
					pagesJSArray += "{description:\"" + navegacion.getDescription() + "\", value:\""+ navegacion.getJson() +"\"} ,";
				}
			}

			if(pagesJSArray.length() > 1)
			{
				pagesJSArray = pagesJSArray.substring(0, pagesJSArray.length() - 1);
			}
			
			pagesJSArray += "]";
			
			return pagesJSArray;
		}
	}
%>