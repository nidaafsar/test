<% 
	ui.includeJavascript("codbr","controllers/searchHome.js")
	ui.decorateWith("codbr","standardPage")
 %>
${ui.includeFragment("codbr","content/searchContent")}
${ui.includeFragment("codbr","content/searchByFormResult")}
