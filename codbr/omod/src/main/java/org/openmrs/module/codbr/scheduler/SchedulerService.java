package org.openmrs.module.codbr.scheduler;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.openmrs.Encounter;
import org.openmrs.Form;
import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.api.PatientService;
import org.openmrs.api.PersonService;
import org.openmrs.api.context.Context;
import org.openmrs.api.context.ServiceContext;

public class SchedulerService {
	
	
	
	public List<Patient> getIRISPatients()
	{
		//get the list of all patients having cause of death null and encounter form id = Id of HTMLForm
		List<Patient> patients = Context.getPatientService().getAllPatients();
		List<Encounter> encounters;  
		List<Patient> irisPatients = new ArrayList<Patient>();
		int formId;
		String formName = null;
		int size;
		Iterator i;
		
		//Loop through and add null cause of death people to another List
		for (Patient patient : patients) {
			encounters = Context.getEncounterService().getEncountersByPatient(patient);
			i = encounters.iterator();
			size = encounters.size();
    		while(i.hasNext())
    		{
				if(patient.getCauseOfDeath() == null)
				{
			        		
			        		
			        			Encounter e = (Encounter)i.next();
			        			Form htmlForm = e.getForm();
			        			formId = htmlForm.getFormId();
			        			formName = htmlForm.getName();
			        					        			
			     }
				if(formName.equals("Inter VA"))
				{
					if(irisPatients.contains(patient)!=true)
					{
						irisPatients.add(patient);
					
					int irisSize = irisPatients.size();
					int sop = irisSize;
					}
					
				}
		        		
			}
    		
		}
		
		return irisPatients;
	}

}
