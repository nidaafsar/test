package org.openmrs.module.codbr.fragment.controller.content;

import org.openmrs.Form;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.context.Context;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.FragmentParam;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

public class SearchByFormResultFragmentController {

	public SimpleObject[] controller(
			PageModel sharedPageModel,
			FragmentConfiguration config,
			FragmentModel model,
			@FragmentParam(value = "formName", required = false) String formName,
			UiUtils ui) {

		Form form = Context.getFormService().getForm(formName);

		if (form == null) {
			throw new IllegalArgumentException("Cannot find form with uuid = "
					+ formName);

		} else {
			System.out.print("Form selected is:" + form.getFormId());
			AdministrationService admin = Context.getAdministrationService();
			List<List<Object>> list = admin
					.executeSQL(
							"select person.person_id,concat(given_name,' ',family_name),gender,birthdate,death_date,cause_of_death "
									+ "from person,person_name"
									+ "where person.person_id=person_name.person_id"
									+ " and person.person_id in"
									+ " (select distinct patient_id from encounter "
									+ " where form_id='"
									+ form.getFormId()
									+ "')", true);
			System.out.print("records found:" + list.size());
			model.addAttribute("PatientList", list);
			sharedPageModel.addAttribute("searchResDev", list);
			return ui.simplifyCollection(list);
		}
	}

	public Object getPatientList(UiUtils ui,
			@RequestParam("formName") String formName) {
		Form form = Context.getFormService().getForm(formName);
		AdministrationService admin = Context.getAdministrationService();
		List<List<Object>> list = admin
				.executeSQL(
						"select person.person_id,concat(given_name,' ',family_name),gender,birthdate,death_date,cause_of_death "
								+ "from person,person_name"
								+ "where person.person_id=person_name.person_id"
								+ " and person.person_id in"
								+ " (select distinct patient_id from encounter "
								+ " where form_id='"
								+ form.getFormId()
								+ "')", true);
		
		return SimpleObject.fromCollection(list, ui,
				"person_id", "gender", "birthdate",
				"death_date");
	}
}