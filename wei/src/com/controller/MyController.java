package com.controller;
import com.dao.Neo4jer;

import net.sf.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import scala.Int;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@org.springframework.stereotype.Controller
public class MyController{
    @RequestMapping("alp")
    public String all_points(Model model){
        Neo4jer nr=Neo4jer.getInstance();
        model.addAttribute("testres",nr.QueryAllPoints());
        return "test";
    }
    @RequestMapping("alrel")
    public String all_relationships(Model model){
        Neo4jer nr=Neo4jer.getInstance();
        model.addAttribute("testres",nr.QueryAllRelationships());
        return "test";
    }

    @RequestMapping("display")
    public String display(Model model){
        Neo4jer nr=Neo4jer.getInstance();
        JSONObject jo = nr.QueryRange(0,1);
        model.addAttribute("init_points",jo.get("pj"));
        model.addAttribute("init_relationships",jo.get("rj"));
        return "display";
    }

    @RequestMapping("point")
    public String point(Model model,
                        @RequestParam(value = "id") String id)
    {
        Neo4jer nr=Neo4jer.getInstance();
        model.addAttribute("result",nr.QueryPoint(Integer.valueOf(id)));
        return "cluster";
    }

    @RequestMapping(value ="display+", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String display_add(@RequestParam(value = "nowcnt") String nowcnt,
                              @RequestParam(value = "nexcnt") String nexcnt) {
        Neo4jer nr=Neo4jer.getInstance();
        JSONObject jo = nr.QueryRange(Integer.valueOf(nowcnt),Integer.valueOf(nexcnt));
        System.out.println(jo.toString());
        return jo.toString();
    }
}
