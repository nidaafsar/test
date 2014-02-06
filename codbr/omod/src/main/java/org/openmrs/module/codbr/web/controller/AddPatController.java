/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.codbr.web.controller;


import org.springframework.ui.ModelMap;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Encounter;
import org.openmrs.Form;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;
import org.openmrs.PatientIdentifierType;
import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonAttributeType;
import org.openmrs.PersonName;
import org.openmrs.User;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.PatientService;
import org.openmrs.api.PersonService;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformentry.BadFormDesignException; // <------- these imports will be taken after you update the maven dependencies in POM
import org.openmrs.module.htmlformentry.FormEntryContext.Mode;
import org.openmrs.module.htmlformentry.FormEntrySession;
import org.openmrs.module.htmlformentry.FormSubmissionError;
import org.openmrs.module.htmlformentry.HtmlForm;
import org.openmrs.module.htmlformentry.HtmlFormEntryUtil;
import org.openmrs.module.htmlformentry.ValidationException;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;


/**
 * The main controller.
 */
@Controller
public class  AddPatController {
	
	protected final Log log = LogFactory.getLog(getClass());
	    public final static String FORM_IN_PROGRESS_KEY = "HTML_FORM_IN_PROGRESS_KEY";
	    public final static String FORM_IN_PROGRESS_VALUE = "HTML_FORM_IN_PROGRESS_VALUE";
	    public final static String FORM_PATH = "/module/codbr/manage.form";
	    public final static String RETURN_PATH_URL = "/module/codbr/htmlFormEntry.form";
	    public static Patient newlyCreated = null;
	    
	public static Patient createPatient(HttpServletRequest request){
		String givenName = request.getParameter("gname");
		String middleName = request.getParameter("midname");
		String familyName = request.getParameter("fmyname");
		String patientID = request.getParameter("id");
		String gender = request.getParameter("gend");
		String dateofbirth = request.getParameter("dob");
		String dateofdeath = request.getParameter("dod");
		String citizenship = request.getParameter("citizenship");
		String ethnicity = request.getParameter("ethnicity");
		String placeofBirth = request.getParameter("placebirth");//country
		String birthCityVillage = request.getParameter("citybirth");
		String birthProvince = request.getParameter("provincebirth");
		String birthCounty = request.getParameter("countybirth");
		String birthUrbanRural = request.getParameter("urbanruralbirth"); 
		
		String placeofDeath = request.getParameter("placedeath");
		
		String deathCityVillage = request.getParameter("citydeath");
		String deathProvince = request.getParameter("provincedeath");
		String deathCounty = request.getParameter("countydeath");
		String deathUrbanRural = request.getParameter("urbanruraldeath"); 
		
		String usualResidence = request.getParameter("addressusual");
		String usualCityVillage = request.getParameter("cityusual");
		String usualProvince = request.getParameter("provinceusual");
		String usualCounty = request.getParameter("countyusual");
		String usualUrbanRural = request.getParameter("urbanrural");
		String lastResidence = request.getParameter("address2");
		String lastCityVillage = request.getParameter("citylast");
		String lastProvince = request.getParameter("provincelast");
		String lastCounty = request.getParameter("countylast");
		String lastUrbanRural = request.getParameter("urbanrurallast"); 
		String dateofMarriage = request.getParameter("dom");
		String father = request.getParameter("father");
		String mother = request.getParameter("mother");
		String certificateType = request.getParameter("certificateType");
		
		//String returnUrl = request.getContextPath() + "/module/codbr/htmlFormEntry.form";
		Date date = null;
		Date datedeath = null;
		
		PatientIdentifier patientIdentifier = null;
		PatientService ps  = null;
		Patient p = new Patient();
		PersonName pername = new PersonName(givenName, middleName, familyName);
		
		/*Set<PersonName> set = new 
		set.add(pername);
*/		p.addName(pername);
		try {
			if(dateofbirth!=null && dateofbirth!=""){
			SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
			date = formatter.parse(dateofbirth);
			//System.out.println(date);
			//System.out.println(formatter.format(date));
			}
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		try {
			if(dateofdeath!=null && dateofdeath!=""){
			SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
			datedeath = formatter.parse(dateofdeath);
			//System.out.println(date);
			//System.out.println(formatter.format(date));
			}
		} catch (ParseException e) {
			e.printStackTrace();
		}
		p.setBirthdate(date);
		p.setGender(gender);
		patientIdentifier = new PatientIdentifier(patientID, Context.getPatientService().getPatientIdentifierType(2), Context.getLocationService().getDefaultLocation());
		p.addIdentifier(patientIdentifier);
		//p.setDead(true);
		
		p.setDeathDate(datedeath);
		PersonAttributeType paatrtypeCitizen = null;
		PersonAttribute pattri = new PersonAttribute();
		PersonService pso = Context.getPersonService();
		paatrtypeCitizen = pso.getPersonAttributeType(3);
		
		pattri.setAttributeType(paatrtypeCitizen);
		pattri.setValue(citizenship);
		pattri.setPerson(p);
		p.addAttribute(pattri);
		
		
		
		PersonAttributeType paatrtypeEthnicity = null;
		PersonAttribute pattriEthnicity = new PersonAttribute();
		PersonService psoEthnicity = Context.getPersonService();
		paatrtypeEthnicity = psoEthnicity.getPersonAttributeType(1);
		
		pattriEthnicity.setAttributeType(paatrtypeEthnicity);
		pattriEthnicity.setValue(ethnicity);
		pattriEthnicity.setPerson(p);
		p.addAttribute(pattriEthnicity);
		
		
/*		PersonAttributeType paatrtypeBirthPlace = null;
		PersonAttribute pattriBirthPlace = new PersonAttribute();
		PersonService psoBirthPlace = Context.getPersonService();
		paatrtypeBirthPlace = psoBirthPlace.getPersonAttributeType(2);
		
		pattriBirthPlace.setAttributeType(paatrtypeBirthPlace);
		pattriBirthPlace.setValue(placeofBirth);
		pattriBirthPlace.setPerson(p);
		p.addAttribute(pattriBirthPlace);
		
		PersonAttributeType paatrtypeDeathPlace = null;
		PersonAttribute pattriDeathPlace = new PersonAttribute();
		PersonService psoDeathPlace = Context.getPersonService();
		paatrtypeDeathPlace = psoDeathPlace.getPersonAttributeType(10);//on local machine this is 9
		
		pattriDeathPlace.setAttributeType(paatrtypeDeathPlace);
		pattriDeathPlace.setValue(placeofDeath);
		pattriDeathPlace.setPerson(p);
		p.addAttribute(pattriDeathPlace);*/
		
		PersonAttributeType attributedateofMarriage = null;
		PersonAttribute pattridateofMarriage = new PersonAttribute();
		PersonService psodateMarriage = Context.getPersonService();
		attributedateofMarriage = psodateMarriage.getPersonAttributeType(9);//on local this is 11
		
		pattridateofMarriage.setAttributeType(attributedateofMarriage);
		pattridateofMarriage.setValue(dateofMarriage);
		pattridateofMarriage.setPerson(p);
		p.addAttribute(pattridateofMarriage);
		
		PersonAttributeType attributeFather = null;
		PersonAttribute pattriFather = new PersonAttribute();
		PersonService psoFather = Context.getPersonService();
		attributeFather = psoFather.getPersonAttributeType(8); //on local this is 10
		
		pattriFather.setAttributeType(attributeFather);
		pattriFather.setValue(father);
		pattriFather.setPerson(p);
		p.addAttribute(pattriFather);
		
		PersonAttributeType attributeMother = null;
		PersonAttribute pattriMother = new PersonAttribute();
		PersonService psoMother = Context.getPersonService();
		attributeMother = psoMother.getPersonAttributeType(4);
		
		pattriMother.setAttributeType(attributeMother);
		pattriMother.setValue(mother);
		pattriMother.setPerson(p);
		p.addAttribute(pattriMother);
		
		if(certificateType.equals("verbalautopsy"))
		{
		PersonAddress paddress = new PersonAddress();
		
		paddress.setCountry(usualResidence);
		paddress.setAddress3("USUAL RESIDENCE");
		paddress.setCityVillage(usualCityVillage);
		paddress.setStateProvince(usualProvince);
		paddress.setCountyDistrict(usualCounty);
		paddress.setAddress4(usualUrbanRural);
		paddress.setPerson(p);
		p.addAddress(paddress);
		
		PersonAddress paddress2 = new PersonAddress();
		paddress2.setCountry(lastResidence);
		paddress2.setAddress3("PREVIOUS RESIDENCE");
		paddress2.setCityVillage(lastCityVillage);
		paddress2.setStateProvince(lastProvince);
		paddress2.setCountyDistrict(lastCounty);
		paddress2.setAddress4(lastUrbanRural);
		paddress2.setPerson(p);
		p.addAddress(paddress2);
		
		
		PersonAddress paddress4 = new PersonAddress();
		paddress4.setCountry(placeofDeath);
		paddress4.setAddress3("DEATHPLACE");
		paddress4.setCityVillage(deathCityVillage);
		paddress4.setStateProvince(deathProvince);
		paddress4.setCountyDistrict(deathCounty);
		paddress4.setAddress4(deathUrbanRural);
		paddress4.setPerson(p);
		p.addAddress(paddress4);
		
		}
		
		PersonAddress paddress3 = new PersonAddress();
		paddress3.setCountry(placeofBirth);
		paddress3.setAddress3("BIRTHPLACE");
		paddress3.setCityVillage(birthCityVillage);
		paddress3.setStateProvince(birthProvince);
		paddress3.setCountyDistrict(birthCounty);
		paddress3.setAddress4(birthUrbanRural);
		paddress3.setPerson(p);
		p.addAddress(paddress3);
		
		ps = Context.getPatientService();
		
		return ps.savePatient(p);
	}
	
	public static String createSystemID()
	{
		User user = Context.getAuthenticatedUser();
		Person p  = user.getPerson();
		Integer personId = p.getPersonId();
		String formattedId =  String.format("%05d",personId);
		String patientID;
		
		SimpleDateFormat formatter =new SimpleDateFormat("yyMMddHHmmss");
		Date d = new Date();
		String formattedDate = formatter.format(d);
		
		//get the patient count for the current user for this date then increment it by one
		AdministrationService admin = Context.getAdministrationService();
		List<List<Object>> list =admin.executeSQL("SELECT * FROM openmrs.patient where creator = '"+personId+"' and date(date_created) = curdate()", true);
		int patientCurrentCount = list.size();
		patientCurrentCount++;
		int incrementCountByOne = patientCurrentCount;
		String formattedSerial =  String.format("%03d",incrementCountByOne);
		
		
		patientID = formattedId+formattedDate+formattedSerial;
		return patientID;
        		
	}
		public static Patient storingPatient()
		{
			
			return newlyCreated;
		}    
	    protected String getQueryPrameters(HttpServletRequest request, FormEntrySession formEntrySession) {
	    	
	        return "?patientId=" + formEntrySession.getPatient().getPersonId();
	    }
}
