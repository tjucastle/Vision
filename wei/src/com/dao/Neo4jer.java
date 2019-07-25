package com.dao;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import org.neo4j.driver.v1.*;
import scala.Console;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.neo4j.driver.v1.Values.parameters;

public class Neo4jer {
    static String HOST="localhost";//本机IP地址
    //static String HOST="10.22.217.84";//远程IP地址
    static String USER="neo4j";//登录数据库的用户名
    static String PASS="admin";//登录数据库的密码
    static Driver myDriver=null;//全局驱动
    //构造函数
    private Neo4jer(){
        myDriver=GraphDatabase.driver("bolt://" + HOST + ":7687", AuthTokens.basic( USER, PASS ) );
    }
    //析构函数
    @Override
    protected void finalize(){
        myDriver.close();
    }
    //工厂化实例
    private static volatile Neo4jer instance = null;
    public static Neo4jer getInstance() {
        if (instance == null) {
            synchronized(Neo4jer.class) {
                if (instance == null) {
                    instance = new Neo4jer();
                }
            }
        }
        return instance;
    }
    //使用cypher查询语句查询数据库，返回为结果的JSON数组
    private JSONArray query(String cypher){
        JSONArray ja = new JSONArray();
        Session mySession = myDriver.session();
        StatementResult result = mySession.run(cypher);
        Gson gson = new GsonBuilder().disableHtmlEscaping().create();
        while (result.hasNext()) {
            Record record = result.next();
            ja.add(gson.toJson(record.asMap()));
        }
        mySession.close();
        return ja;
    }
    //测试用，查询所有节点
    public String QueryAllPoints(){
        String querystr="match (n:Loan) return n";
        JSONArray ja=query(querystr);
        return ja.toString();
    }
    //测试用，查询所有关系
    public String QueryAllRelationships() {
        String querystr="match (a:Loan)-[r]-(b:Loan) return r";
        JSONArray ja=query(querystr);
        return ja.toString();
    }
    //根据起始index(nowcnt)和结尾index(nexcnt)，返回一个字符串数组，[0]为点的JSON串，包含nowcnt<=x<nexcnt的点，[1]为边的字符串，包含边的端点的index为<nexcnt的所有边
    public JSONObject QueryRange(int nowcnt, int nexcnt){
        JSONObject jo = new JSONObject();
        String querystr0="match (n:Loan) where id(n) >= "+nowcnt+" and id(n) < "+nexcnt+" return n";
        String str0=query(querystr0).toString();
        jo.put("pj",str0);
        String querystr1="match (a:Loan)-[r]-(b:Loan) where id(a) < "+ nexcnt + " and id(b) < "+nexcnt + " and (id(a) >= "+nowcnt+ " or id(b) >= "+nowcnt+" ) return distinct r";
        String str1=query(querystr1).toString();
        jo.put("rj",str1);
        return jo;
    }
    //返回指定点的所有属性
    public String QueryPoint(int id){
        String querystr="match (a:Loan) where id(a)= "+id+ " return a";
        JSONArray ja=query(querystr);
        return ja.toString();
    }
}
