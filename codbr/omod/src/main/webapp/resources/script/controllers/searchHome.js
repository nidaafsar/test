<link href="/${ contextPath }/scripts/jquery/jquery-1.3.2.min.js" />
<link href="/${ contextPath }/scripts/jquery-ui/js/jquery-ui-1.7.2.custom.min.js" />
<link href="/${ contextPath }/scripts/jquery-ui/css/redmond/jquery-ui-1.7.2.custom.css" />
 
<script type="text/javascript">

	jQuery(function() {
window.alert("You are on search page!");
jQuery( "#accordion" ).accordion();
});

	jQuery('#searchResDiv').onclick = <g:remoteFunction action="getPatientListByForm" formName="My Form" />

</script>