package com.example.careerpaths.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MainController {

    @GetMapping("/")
    public String index() {
        return "index";
    }

    @GetMapping("/ml")
    public String ml() {
        return "ml";
    }

    @GetMapping("/devops")
    public String devops() {
        return "devops";
    }
}
