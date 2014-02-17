package org.openmrs.module.codbr.fragment.controller.content;

import java.io.File;
import java.sql.Array;
import java.text.ParseException;

import org.openmrs.api.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.ModuleMustStartException;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.ui.framework.fragment.FragmentUiUtils;
import org.openmrs.Form;
import org.openmrs.Patient;
import org.openmrs.Person;

import org.openmrs.ui.framework.annotation.FragmentParam;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.ui.framework.page.PageRequest;
import org.openmrs.ui.framework.*;
import org.openmrs.util.DatabaseUpdateException;
import org.openmrs.util.InputRequiredException;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;


public class SearchContentFragmentController {
	
	
	public SimpleObject[] getPatientListByForm(FragmentModel model,
			@FragmentParam(value="formName",required=false) String formName,UiUtils ui)
	{

		   Form form = Context.getFormService().getForm(formName);
		   
		   if (form == null) {
            throw new IllegalArgumentException("Cannot find form with uuid = " + formName);
            
		   }
		   else
		   {
			   System.out.print("Form selected is:"+form.getFormId());
			   AdministrationService admin = Context.getAdministrationService();
			   List<List<Object>> list =admin.executeSQL("select person.person_id,concat(given_name,' ',family_name),gender,birthdate,death_date,cause_of_death " +"from person,person_name"+"where person.person_id=person_name.person_id"+" and person.person_id in"+" (select distinct patient_id from encounter "+" where form_id='"+form.getFormId()+"')", true);
			   System.out.print("records found:"+list.size());
			   model.addAttribute("PatientList",list);
			   return ui.simplifyCollection(list);
		   }
	}
	
	public void controller(FragmentModel model,
			@FragmentParam(value="patientName",required=false) String givenName,
			@FragmentParam(value="formName",required=false) String formName,
			UiUtils ui
			){
		
		   if (givenName !=null)
		   {
			     List<Patient> patients = Context.getPatientService().getPatients(givenName);
			     for (Patient patient : patients) {
			     model.addAttribute("PatientsFoundViaName",patient.getGivenName()+" "+patient.getFamilyName() );
			     System.out.println("Found patient with name " + patient.getPersonName() + " and uuid: " + patient.getUuid());
			     }
		   }
		   else if(formName !=null)
		   {
			   model.addAttribute("PatientList",getPatientListByForm(model,formName,ui)); 
		   }
		   
	}
}
	


		   
