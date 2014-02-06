package org.openmrs.module.codbr.web.controller;

import javax.servlet.http.HttpServletRequest;

import org.openmrs.Patient;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

@Controller
@RequestMapping(value = "/module/codbr/vaform/")
public class CodbrFormController {

    private final static String RETURN_PATH_URL = "/module/codbr/htmlFormEntry.form";

	@RequestMapping(method=RequestMethod.GET , value="verbalAutopsy.form")
	public String verbalAutopsy(HttpServletRequest request) {
		System.out.println("..................................................HERE");
		String patIdentifier = AddPatController.createSystemID();
		request.getSession().setAttribute("patientIdentifier", patIdentifier); //removing getSession() method, setting it in request scope
		return "/module/codbr/verbalAutopsyPerson";
	}
	
	@RequestMapping(method=RequestMethod.POST , value = "/verbalAutopsy.form")
	public ModelAndView verbalAutopsypost(HttpServletRequest request) {
		System.out.println("***********************************************.HERE");
		Patient p = AddPatController.createPatient(request);

		return new ModelAndView(new RedirectView(request.getContextPath()+RETURN_PATH_URL+"?patientId="+p.getPatientId()+"&formId=20"));
	}
	
	@RequestMapping(method=RequestMethod.GET , value="birthCertificate.form")
	public String birthCertificate(HttpServletRequest request) {
		System.out.println("..................................................HERE");
		String patIdentifier = AddPatController.createSystemID();
		request.getSession().setAttribute("patientIdentifier", patIdentifier);
		return "/module/codbr/birthCertificatePerson";
	}
	
	@RequestMapping(method=RequestMethod.POST , value = "/birthCertificate.form")
	public ModelAndView birthCertificatepost(HttpServletRequest request) {
		System.out.println("***********************************************.HERE");
		Patient p = AddPatController.createPatient(request);

		return new ModelAndView(new RedirectView(request.getContextPath()+RETURN_PATH_URL+"?patientId="+p.getPatientId()+"&formId=4"));
	}
	
	@RequestMapping(method=RequestMethod.GET , value="foetalDeathCertificate.form")
	public String foetalDeathCertificate(HttpServletRequest request) {
		System.out.println("..................................................HERE");
		String patIdentifier = AddPatController.createSystemID();
		request.getSession().setAttribute("patientIdentifier", patIdentifier);
		return "/module/codbr/foetalDeathCertificatePerson";
	}
	
	@RequestMapping(method=RequestMethod.POST , value = "/foetalDeathCertificate.form")
	public ModelAndView foetalDeathCertificatepost(HttpServletRequest request) {
		System.out.println("***********************************************.HERE");
		Patient p = AddPatController.createPatient(request);

		return new ModelAndView(new RedirectView(request.getContextPath()+RETURN_PATH_URL+"?patientId="+p.getPatientId()+"&formId=10"));
	}
}
