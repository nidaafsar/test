<%
    def id = config.id ?: ui.randomId("formNames")
%>

<script>
    function refreshSearchResTable(divId, formName) {
        jq('#' + divId + '_table > tbody').empty();
        jq.getJSON('${ ui.actionLink("getPatientList", [returnFormat: "json"]) }', { formName: formName },
        function(data) {
            publish(divId + "_table.show-data", data);
        });
    }
</script>
 
<div id="${searchResDiv}">
<a href="javascript:refreshSearchResTable('searchResDiv', '')">test the refresh</a>
 
    ${ ui.includeFragment("widgets/table", [
            columns: [
                [ property: "givenName", userEntered:true, heading: ui.message("Name") ],
                [ property: "gender", heading: ui.message("Gender") ],
                [ property: "birthdate", heading: ui.message("Birth date") ],
                [ property: "death_date", heading: ui.message("Death date") ]
            ],
            rows: patient.activeIdentifiers,
            ifNoRowsMessage: ui.message("general.none")
        ]) }
</div>