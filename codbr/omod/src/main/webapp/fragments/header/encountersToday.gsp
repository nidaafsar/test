<%
    def props = config.properties ?: ["encounterType", "encounterDatetime", "location", "provider"]
%>
<table>
    <tr>
        <% props.each { %>
            <th>${ ui.message("Encounter." + it) }</th>
        <% } %>
    </tr>
    <% if (encounters) { %>
        <% encounters.each { enc -> %>
            <tr>
                <% props.each { prop -> %>
                    <td><%= ui.format(enc."${prop}") %></td>
                <% } %>
            </tr>
        <% } %>
    <% } else { %>
        <tr>
            <td colspan="4">${ ui.message("general.none") }</td>
        </tr>
    <% } %>
</table>