<div id="featured-wrapper">
	<div id="featured" class="container">
	<table class="layouttable"><tr><td>	
	<div class="sidebar" id="accordion">

		<li><strong><a href="#">Form</a></strong>
			<ul>
				<li><g:createLink controller="SearchContentFragmentController" action="getPatientListByForm"
              params="[formName: 'Full Verbal Autopsy']"/><a href="">Verbal Autopsy</a></li>
				<li><a href="#">Birth Informant</a></li>
				<li><a href="#">Death Informant</a></li>
			</ul>
		</li>	
		<li><strong>Location
		<g:locationSelect name="location.country" value="${location.country}"
		 noSelection="['':'-Choose your country-']"/>
		<g:countrySelect name="location.country"  from="['npl', 'tls', 'idn' , 'bgd' ]"
                 value="${location?.country}"/>
		</strong></li>	
		<li><strong>Patient name</strong><input type ="text-box" id="patientName">
		<button type="submit" name="Search" value="search"><img src="/images/search.png" alt="Search"></button><br></br></li>
	</div>
	</td></tr>
	<tr><td>
	<div class="content-container" id="searchResDiv">result</div>
	</td></tr></table>
	</div>
</div>
