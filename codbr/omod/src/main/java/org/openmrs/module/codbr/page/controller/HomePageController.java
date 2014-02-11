package org.openmrs.module.codbr.page.controller;

import org.openmrs.ui.framework.page.PageModel;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HomePageController {
	
	public void controller(@RequestParam(value = "redirect", required = false) String redirect, PageModel model) {
	}

}
