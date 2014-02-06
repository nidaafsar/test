<%@ include file="/WEB-INF/template/include.jsp" %>
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<c:set var="OPENMRS_DO_NOT_SHOW_PATIENT_SET" scope="request" value="true"/>
<c:set var="pageFragment" value="${param.pageFragment != null && param.pageFragment}"/>
<c:set var="inPopup" value="${pageFragment || (param.inPopup != null && param.inPopup)}"/>

<c:if test="${not pageFragment}">
    <c:set var="DO_NOT_INCLUDE_JQUERY" value="true"/>
	<c:choose>
		<c:when test="${inPopup}">
			<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
		</c:when>
		<c:otherwise>
			<%@ include file="/WEB-INF/template/header.jsp" %>
		</c:otherwise>
	</c:choose>

	<openmrs:htmlInclude file="/dwr/engine.js" />
	<openmrs:htmlInclude file="/dwr/util.js" />
	<openmrs:htmlInclude file="/dwr/interface/DWRHtmlFormEntryService.js" />
    <openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-ui-1.8.17.custom.css" />
    <openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-1.4.2.min.js" />
    <script type="text/javascript">
        $j = jQuery.noConflict();
    </script>
    <openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-ui-1.8.17.custom.min.js" />
    <openmrs:htmlInclude file="/moduleResources/htmlformentry/htmlFormEntry.js" />
	<openmrs:htmlInclude file="/moduleResources/htmlformentry/htmlFormEntry.css" />
    <openmrs:htmlInclude file="/moduleResources/htmlformentry/htmlForm.js" />
    <openmrs:htmlInclude file="/moduleResources/htmlformentry/handlebars.min.js" />
</c:if>

<script type="text/javascript">
	var propertyAccessorInfo = new Array();
	
	// individual forms can define their own functions to execute before a form validation or submission by adding them to these lists
	// if any function returns false, no further functions are called and the validation or submission is cancelled
	var beforeValidation = new Array();     // a list of functions that will be executed before the validation of a form
	var beforeSubmit = new Array(); 		// a list of functions that will be executed before the submission of a form

	// boolean to track whether or not jquery document ready function fired
	var initInd = true;

   // booleans used to track whether we are in the process of submitted or discarding a formk
   var isSubmittingInd = false;
   var isDiscardingInd = false;

	$j(document).ready(function() {
		$j('#deleteButton').click(function() {
			// display a "deleting form" message
			$j('#confirmDeleteFormPopup').children("center").html('<spring:message code="htmlformentry.deletingForm"/>');
			
			// do the post that does the actual delete
			$j.post("<c:url value="/module/htmlformentry/deleteEncounter.form"/>", 
				{ 	encounterId: "${command.encounter.encounterId}", 
				    htmlFormId: "${command.htmlFormId}",
					returnUrl: "${command.returnUrlWithParameters}", 
					reason: $j('#deleteReason').val()
			 	}, 
			 	function(data) {
				 	var url = "${command.returnUrlWithParameters}";
				 	if (url == null || url == "") {
					 	url = "${pageContext.request.contextPath}/patientDashboard.form?patientId=${command.patient.patientId}";
				 	}
				 	window.parent.location.href = url;
			 	}
			 );
		});

		// triggered whenever any input with toggleDim attribute is changed.  Currently, only supports
		// checkbox style inputs.
		$j('input[toggleDim]').change(function () {
            var target = $j(this).attr("toggleDim");
            if ($j(this).is(":checked")) {
                $j("#" + target + " :input").removeAttr('disabled');
                $j("#" + target).animate({opacity:1.0}, 0);
                restoreContainerInputs($j("#" + target));
            } else {
                $j("#" + target + " :input").attr('disabled', true);
                $j("#" + target).animate({opacity:0.5}, 100);
                clearContainerInputs($j("#" + target));
            }
        })
        .change();

		// triggered whenever any input with toggleHide attribute is changed.  Currently, only supports
		// checkbox style inputs.
        $j('input[toggleHide]').change(function () {
            var target = $j(this).attr("toggleHide");
            if ($j(this).is(":checked")) {
                $j("#" + target).fadeIn();
                restoreContainerInputs($j("#" + target));
            } else {
                $j("#" + target).hide();
                clearContainerInputs($j("#" + target));
            }
        })
        .change();

        // triggered whenever any input widget on the page is changed
   	    $j(':input').change(function () {
			$j(':input.has-changed-ind').val('true');
		});

        // warn user that his/her changes will be lost if he/she leaves the page
		$j(window).bind('beforeunload', function(){
			var hasChangedInd = $j(':input.has-changed-ind').val();/* alert(hasChangedInd); */
			if (hasChangedInd == 'true' && !isSubmittingInd && !isDiscardingInd) {
				return '<spring:message code="htmlformentry.loseChangesWarning"/>';
			}
		});

	    // catch form submit button (not currently used)
        $j('form').submit(function() {
			isSubmittingInd = true;
			return true;
		});

		// catch when button with class submitButton is clicked (currently used)
		$j(':input.submitButton').click(function() {
			isSubmittingInd = true;
			return true;
		});

		// catch when discard link clicked
		$j('.html-form-entry-discard-changes').click(function() {
			isDiscardingInd = true;
			return true;
		});

		// indicates this function has completed
		initInd = false;
		
		//managing the id of the newly generated id's of dynamicAutocomplete widgets
		$j('div .dynamicAutocomplete').each(function(index) {
			var string=((this.id).split("_div",1))+"_hid";
			if(!$j('#'+string).attr('value'))
				$j('#'+this.id).data("count",0);
			else
				$j('#'+this.id).data("count",parseInt($j('#'+string).attr('value')));
			});
		//add button for dynamic autocomplete
		$j(':button.addConceptButton').click(function() {
			  	var string=(this.id).replace("_button","");
		        var conceptValue=$j('#'+string+'_hid').attr('value')
		        if($j('#'+string).css('color')=='green'){
		        	var	divId=string+"_div";
	        		 var spanid=string+'span_'+ $j('#'+divId).data("count");
	        		 var count= $j('#'+divId).data("count");
	        		 $j('#'+divId).data("count",++count);
	        		 $j('#'+string+'_hid').attr('value',$j('#'+divId).data("count"));
	        		 var hidId=spanid+'_hid';
	          		 var v='<span id="'+spanid+'"></br>'+$j('#'+string).val()+'<input id="'+hidId+'"  class="autoCompleteHidden" type="hidden" name="'+hidId+'" value="'+conceptValue+'">';
	                 var q='<input id="'+spanid+'_button" type="button" value="Remove" onClick="$j(\'#'+spanid+'\').remove();openmrs.htmlformentry.refresh(this.id)"></span>';
	                 $j('#'+divId).append(v+q);
	                 $j('#'+string).val('');
	        } 
	        });
	});

	// clear toggle container's inputs but saves the input values until form is submitted/validated in case the user
	// re-clicks the trigger checkbox.  Note: These "saved" input values will be lost if the form fails validation on submission.
	function clearContainerInputs($container) {
		if (!initInd) {
		    $container.find('input:text, input:password, input:file, select, textarea').each( function() {
		    	$j(this).data('origVal',this.value);
		    	$j(this).val("");
		    });
		    $container.find('input:radio, input:checkbox').each( function() {
				if ($j(this).is(":checked")) {
					$j(this).data('origState','checked');
					$j(this).removeAttr("checked");
				} else {
					$j(this).data('origState','unchecked');
				}
		    });
		}
	}
	
	// restores toggle container's inputs from the last time the trigger checkbox was unchecked
	function restoreContainerInputs($container) {
		if (!initInd) {
		    $container.find('input:text, input:password, input:file, select, textarea').each( function() {
		    	$j(this).val($j(this).data('origVal'));
		    });
		    $container.find('input:radio, input:checkbox').each( function() {
		    	if ($j(this).data('origState') == 'checked') {
		    		$j(this).attr("checked", "checked");
		    	} else {
		    		$j(this).removeAttr("checked");
		    	}
		    });
		}
	}

	var tryingToSubmit = false;
	
	function submitHtmlForm() {
	    if (!tryingToSubmit) {
	        tryingToSubmit = true;
	        DWRHtmlFormEntryService.checkIfLoggedIn(checkIfLoggedInAndErrorsCallback);
	    }
	}

	function findAndHighlightErrors(){
		/* see if there are error fields */
		var containError = false;
		var ary = $j(".autoCompleteHidden");
		$j.each(ary,function(index, value){
			if(value.value == "ERROR"){
				if(!containError){
					alert("<spring:message code='htmlformentry.error.autoCompleteAnswerNotValid'/>");
					var id = value.id;
					id = id.substring(0,id.length-4);
					$j("#"+id).focus(); 					
				}
				containError=true;
			}
		});
		return containError;
	}

    function findOptionAutoCompleteErrors() {
        /* see if there are  errors in option fields */
		var containError = false;
		var ary = $j(".optionAutoCompleteHidden");
		$j.each(ary,function(index, value){
			if(value.value == "ERROR"){
				if(!containError){
					alert("<spring:message code='htmlformentry.error.autoCompleteOptionNotValid'/>");
					var id = value.id;
					id = id.substring(0,id.length-4);
					$j("#"+id).focus();
				}
				containError=true;
			}
		});
		return containError;
    }

	/*
		It seems the logic of  showAuthenticateDialog and 
		findAndHighlightErrors should be in the same callback function.
		i.e. only authenticated user can see the error msg of
	*/
	function checkIfLoggedInAndErrorsCallback(isLoggedIn) {
		
		var state_beforeValidation=true;
		alert("Getting till here!!");
		if (!isLoggedIn) {
			showAuthenticateDialog();
		}else{
			
			// first call any beforeValidation functions that may have been defined by the html form
			if (beforeValidation.length > 0){
				for (var i=0, l = beforeValidation.length; i < l; i++){
					if (state_beforeValidation){
						var fncn=beforeValidation[i];						
						state_beforeValidation=fncn.call(undefined);
					}
					else{
						// forces the end of the loop
						i=l;
					}
				}
			}
			
			// only do the validation if all the beforeValidationk functions returned "true"
			if (state_beforeValidation) {
				var anyErrors = findAndHighlightErrors();
                var optionSelectErrors = findOptionAutoCompleteErrors();
			
        		if (anyErrors || optionSelectErrors) {
            		tryingToSubmit = false;
            		return;
        		} else {
        			doSubmitHtmlForm();
        		}
			}
            else {
                tryingToSubmit = false;
            }
		}
	}

	function showAuthenticateDialog() {
		$j('#passwordPopup').show();
		tryingToSubmit = false;
	}

	function loginThenSubmitHtmlForm() {
		
		$j('#passwordPopup').hide();
		var username = $j('#passwordPopupUsername').val();
		var password = $j('#passwordPopupPassword').val();
		$j('#passwordPopupUsername').val('');
		$j('#passwordPopupPassword').val('');
		DWRHtmlFormEntryService.authenticate(username, password, submitHtmlForm); 
	}
	
	function checkingEmptyFields()
	{
		if (!tryingToSubmit) {
	        tryingToSubmit = true;
	        DWRHtmlFormEntryService.checkIfLoggedIn(newCallback);
	    }
		
	}
	
	function newCallback(isLoggedIn) {
		
		var state_beforeValidation=true;
		
		if (!isLoggedIn) {
			showAuthenticateDialog();
		}else{
			
			// first call any beforeValidation functions that may have been defined by the html form
			if (beforeValidation.length > 0){
				for (var i=0, l = beforeValidation.length; i < l; i++){
					if (state_beforeValidation){
						var fncn=beforeValidation[i];						
						state_beforeValidation=fncn.call(undefined);
					}
					else{
						// forces the end of the loop
						i=l;
					}
				}
			}
			
			// only do the validation if all the beforeValidationk functions returned "true"
			if (state_beforeValidation) {
				var anyErrors = findMissingFields();
                
			
        		if (anyErrors) {
            		tryingToSubmit = false;
            		return;
        		} else {
        			doAddPatientSubmitHtmlForm();
        		}
			}
            else {
                tryingToSubmit = false;
            }
		}
	}
	
	function findMissingFields()
	{
		var givenName = $j('#gname').val();
		var familyName = $j('#fmyname').val();
		var id = $j('#id').val();
		var val = $j('input[name="gend"]:checked').val();
		var dob = $j('#dob').val();
		var dod = $j('#dod').val();
		
		var genderValue;
		if(val == "M")
			{
			genderValue = "checked";
			}
		else if(val=="F"){
			genderValue = "checked";
		}
		else{
			genderValue = "unchecked";
		}
		
			
		
		if(givenName == "" || familyName == "" || id == "" || genderValue == "unchecked" || dob == ""  ||dod == "")
			{
				alert("Please fill in fields marked with Red *");
				return true;
			}
		return false;
	}
	
	function doAddPatientSubmitHtmlForm() {
		
		// first call any beforeSubmit functions that may have been defined by the form
		var state_beforeSubmit=true;
		if (beforeSubmit.length > 0){
			for (var i=0, l = beforeSubmit.length; i < l; i++){
				if (state_beforeSubmit){
					var fncn=beforeSubmit[i];						
					state_beforeSubmit=fncn();					
				}
				else{
					// forces the end of the loop
					i=l;
				}
			}
		}
		
		// only do the submit if all the beforeSubmit functions returned "true"
		if (state_beforeSubmit){
			
			  var form = document.getElementById('addPatient');
			  form.submit();  			
		}
		tryingToSubmit = false;
	}

/* 	function doSubmitHtmlForm() {
		
		// first call any beforeSubmit functions that may have been defined by the form
		var state_beforeSubmit=true;
		if (beforeSubmit.length > 0){
			for (var i=0, l = beforeSubmit.length; i < l; i++){
				if (state_beforeSubmit){
					var fncn=beforeSubmit[i];						
					state_beforeSubmit=fncn();					
				}
				else{
					// forces the end of the loop
					i=l;
				}
			}
		}
		
		// only do the submit if all the beforeSubmit functions returned "true"
		if (state_beforeSubmit){
			
			  var form = document.getElementById('htmlform');
			  form.submit();  			
		}
		tryingToSubmit = false;
	} */

	function handleDeleteButton() {
		$j('#confirmDeleteFormPopup').show();
	}

	function cancelDeleteForm() {
		$j('#confirmDeleteFormPopup').hide();
	}
	
	function updateAge() {
		var birthdateBox = document.getElementById('dob');
		
		var ageBox = document.getElementById('age');
		//alert(ageBox.value);
		try {
			var birthdate = parseSimpleDate(birthdateBox.value, '<openmrs:datePattern />');
			
			var age = getAge(birthdate);
			
			if (age > 0)
				ageBox.innerHTML = "(" + age + ' <openmrs:message code="Person.age.years"/>)';
			else if (age == 1)
				ageBox.innerHTML = '(1 <openmrs:message code="Person.age.year"/>)';
			else if (age == 0)
				ageBox.innerHTML = '( < 1 <openmrs:message code="Person.age.year"/>)';
			else
				ageBox.innerHTML = '( ? )';
			ageBox.style.display = "";
		} catch (err) {
			ageBox.innerHTML = "";
			ageBox.style.display = "none";
		}
	}
	
	function getAge(d, now) {
		var age = -1;
		if (typeof(now) == 'undefined') now = new Date();
		while (now >= d) {
			age++;
			d.setFullYear(d.getFullYear() + 1);
		}
		return age;
	}
	
	
</script>

<%-- 
  <c:if test="${command.context.mode != 'VIEW'}">
	<form id="htmlform" method="get" onSubmit="submitHtmlForm(); return false;">
		<input type="hidden" name="personId" value="${ command.patient.personId }"/>
		<input type="hidden" name="htmlFormId" value="${ command.htmlFormId }"/>
		<input type="hidden" name="formModifiedTimestamp" value="${ command.formModifiedTimestamp }"/>
		<input type="hidden" name="encounterModifiedTimestamp" value="${ command.encounterModifiedTimestamp }"/>
		<c:if test="${ not empty command.encounter }">
			<input type="hidden" name="encounterId" value="${ command.encounter.encounterId }"/>
		</c:if>
		<input type="hidden" name="closeAfterSubmission" value="${param.closeAfterSubmission}"/>
		<input type="hidden" name="hasChangedInd" class="has-changed-ind" value="${ command.hasChangedInd }" />
		</form>
</c:if>

<c:if test="${command.context.guessingInd == 'true'}">
	<div class="error">
		<spring:message code="htmlformentry.form.reconstruct.warning" />
	</div>
</c:if>   --%>
		<form id="addPatient" method="post" onSubmit="checkingEmptyFields(); return false;">
<div  align="left"><input type="hidden" name="certificateType" value="verbalautopsy"/>
<br>
<div style="margin-bottom: 5px;font-size: large;"><div style="width: 200px; float: left;">Identifier <span style ="color:red">*</span></div> <input name="id" style="width: 300px;border: 0px;" value="<%=request.getSession().getAttribute("patientIdentifier")%>"/></div>

<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">First Name <span style ="color:red">*</span></div> <input type="text" name="gname" id="gname"/></div>

<!-- <div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">Middle </div><input type="text" name="midname" /></div> -->

<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">Last Name <span style ="color:red">*</span></div><input type="text" name="fmyname" id="fmyname"/></div>

</div>
<br>
<div  align="left">

<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">Gender <span style ="color:red">*</span></div> <input type="radio" name="gend" id="gend" value="M"/>Male<input type="radio" id="gend" name="gend" value="F"/>Female</div>
				
				
<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">Nationality</div>
<select name="citizenship">
  <option value="citizen_by_birth">Citizen by birth</option>
  <option value="naturalized_citizen">Naturalized citizen</option>
  <option value="alien">Foreign National</option>

</select></div>

</div>

<div  align="left">
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Ethnicity
</div>
<input type="text" name="ethnicity"/>
</div>
<div style="font-size : large;">Place of Birth</div><br>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Country
</div>
<input type="text" name="placebirth"/>
</div>
<!-- <div style="margin-bottom: 5px;"> NOT NEEDED - MAIMOONA
<div style="width: 200px; float: left;">
Province
</div>
<input type="text" name="provincebirth"/>
</div> -->

<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
City/Village
</div>
<input type="text" name="citybirth"/>
</div>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
County/District
</div>
<input type="text" name="countybirth"/>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Locality Type</div>
<select name="urbanruralbirth">
  <option value="Urban">Urban</option>
  <option value="Rural">Rural</option>
</select>
</div>
</div>
<div style="font-size : large;">Place of Death</div><br>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Country
</div>
<input type="text" name="placedeath"/>
</div>
<!-- <div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Province
</div>
<input type="text" name="provincedeath"/>
</div> -->
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
City/Village
</div>
<input type="text" name="citydeath"/>
</div>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
County/District
</div>
<input type="text" name="countydeath"/>
</div>
<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">
Locality Type</div>
<select name="urbanruraldeath">
  <option value="Urban">Urban</option>
  <option value="Rural">Rural</option>
</select>
</div>

</div>
<div style="font-size : large;">Place of Usual Residence</div><br>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Country
</div>
<input type="text" name="addressusual"/>
</div>
<!-- <div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Province
</div>
<input type="text" name="provinceusual"/>
</div> -->
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
City/Village
</div>
<input type="text" name="cityusual"/>
</div>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
County/District
</div>
<input type="text" name="countyusual"/>
</div>
<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">
Locality Type</div>
<select name="urbanrural">
  <option value="Urban">Urban</option>
  <option value="Rural">Rural</option>
  </select>
</div>
<div style="font-size : large;">Place of Previous Residence (1-5 years before death)</div><br>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Country
</div>
<input type="text" name="address2"/>
</div>
<!-- <div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Province
</div>
<input type="text" name="provincelast"/>
</div> -->
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
City/Village
</div>
<input type="text" name="citylast"/>
</div>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
County/District
</div>
<input type="text" name="countylast"/>
</div>
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Locality Type</div>
<select name="urbanrurallast">
  <option value="Urban">Urban</option>
  <option value="Rural">Rural</option>
</select></div>


<div  align="left">
<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Marriage Date
</div>
<input type="text" id="dom" name="dom" onfocus="showCalendar(this,60)"/>
</div>

<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Father Name
</div>
<input type="text" name="father"/>
</div>

<div style="margin-bottom: 5px;">
<div style="width: 200px; float: left;">
Mother Name
</div>
<input type="text" name="mother"/>
</div>



<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">Is Date of Birth Known ?<span style ="color:red">*</span></div>

						
							
				<%-- <input type="hidden" name="_${status.expression}"/> --%>
				<input type="checkbox" <%-- name="${status.expression}"  --%>
				
					 <%--   <c:if test="${status.value == true}">checked</c:if> --%>
					   onclick="personBirthClicked(this)" id="personBirth"
				/>
				


			<script type="text/javascript">
				function personBirthClicked(input) {
					
					if (input.checked) {
						document.getElementById("birthInformation").style.display = "";
					}
					else {
						document.getElementById("birthInformation").style.display = "none";
						document.getElementById("deathDate").value = "";
						var cause = document.getElementById("causeOfDeath");
						if (cause != null)
							cause.value = "";
					}
				}
			</script>

							
</div> 


<div id="birthInformation">
<input type="text" id="dob" name="dob" onchange="updateAge();" onfocus="showCalendar(this,60)"/>
	<%-- <input type="hidden" name="_${status.expression}"> 
                    <input type="checkbox" name="${status.expression}" value="true"
						<c:if test="${status.value == true}">checked</c:if> 
						   id="deathdateEstimatedInput" 
					 /> --%>
 <script type="text/javascript">				
					//here setting DOB Fields
					personBirthClicked(document.getElementById("personBirth"));
				</script> 
				<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">Age:<span id="age"></span></div></div><br>
	</div>			
<br>
<div style="margin-bottom: 5px;"><div style="width: 200px; float: left;">Is Date of Death Known ?<span style ="color:red">*</span></div>
						
							
				<%-- <input type="hidden" name="_${status.expression}"/> --%>
				<input type="checkbox" <%-- name="${status.expression}"  --%>
				
					 <%--   <c:if test="${status.value == true}">checked</c:if> --%>
					   onclick="personDeadClicked(this)" id="personDead"
				/>

			<script type="text/javascript">
				function personDeadClicked(input) {
					
					if (input.checked) {
						document.getElementById("deathInformation").style.display = "";
					}
					else {
						document.getElementById("deathInformation").style.display = "none";
						document.getElementById("deathDate").value = "";
						var cause = document.getElementById("causeOfDeath");
						if (cause != null)
							cause.value = "";
					}
				}
			</script>

							
</div> 
<div id="deathInformation">
<input type="text" id="dod" name="dod" onfocus="showCalendar(this,60)"/>
	<%-- <input type="hidden" name="_${status.expression}"> 
                    <input type="checkbox" name="${status.expression}" value="true"
						<c:if test="${status.value == true}">checked</c:if> 
						   id="deathdateEstimatedInput" 
					 /> --%>
 <script type="text/javascript">				
					//here setting DOB Fields
					personDeadClicked(document.getElementById("personDead"));
				</script> 
				
	</div>
	
	</div>
	<br/>	
<input type="submit" value="Save Patient"/></form>
 	<%-- ${command.htmlToDisplay} 
 --%>

<c:if test="${not empty command.fieldAccessorJavascript}">
	<script type="text/javascript">
		${command.fieldAccessorJavascript}
	</script>
</c:if>
<c:if test="${not empty command.setLastSubmissionFieldsJavascript || not empty command.lastSubmissionErrorJavascript}"> 
	<script type="text/javascript">
		$j(document).ready( function() {
			${command.setLastSubmissionFieldsJavascript}
			${command.lastSubmissionErrorJavascript}

			$j('input[toggleDim]:not(:checked)').each(function () {
				var target = $j(this).attr("toggleDim");
				$j("#" + target + " :input").attr('disabled', true);
				$j("#" + target).animate({opacity:0.5}, 100);
			});

			$j('input[toggleDim]:checked').each(function () {
				var target = $j(this).attr("toggleDim");
				$j("#" + target + " :input").removeAttr('disabled');
				$j("#" + target).animate({opacity:1.0}, 0);
			});

			$j('input[toggleHide]:not(:checked)').each(function () {
				var target = $j(this).attr("toggleHide");
				$j("#" + target).hide();
			});

			$j('input[toggleHide]:checked').each(function () {
				var target = $j(this).attr("toggleHide");
				$j("#" + target).fadeIn();
			});

		});
	</script>
</c:if>

<c:if test="${!pageFragment}">
	<c:choose>
		<c:when test="${inPopup}">
			<%@ include file="/WEB-INF/template/footerMinimal.jsp" %>
		</c:when>
		<c:otherwise>
			<%@ include file="/WEB-INF/template/footer.jsp" %>
		</c:otherwise>
	</c:choose>
</c:if>