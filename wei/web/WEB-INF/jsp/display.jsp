<%--
  Created by IntelliJ IDEA.
  User: lenovo
  Date: 2019/7/17
  Time: 23:56
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Display</title>
    <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
</head>
    相关点JSON串<br>
    <input id="show_points" type="text" size="128" readonly="true" value="返回点的JSON串"/>
    <br>
    相关边JSON串<br>
    <input id="show_relationships" type="text" size="128" readonly="true" value="返回边的JSON串"/>
    <br>
    <input id="cnt" type="hidden" value="0">
    <button id="ad1btn" type="button">逐个递增ID</button>
</body>
<script type="text/javascript">
    $("#show_points").val('${init_points}');
    $("#show_relationships").val('${init_relationships}');
    $("#cnt").val(1);
    $(function() {
        $("#ad1btn").click(function () {
            var nowcnt=parseInt($("#cnt").val());
            var nexcnt=parseInt($("#cnt").val())+1;
            console.log(nowcnt);
            console.log(nexcnt);
            $.ajax({
                url: "display+",
                type: "POST",
                dataType:'json',
                data: {
                    nowcnt : nowcnt.toString(),
                    nexcnt: nexcnt.toString(),
               },
                success: function (data) {
                    console.log(3);
                    $("#cnt").val(nexcnt);
                    var njs=JSON.stringify(data);
                    console.log(njs);
                    var pjs=data["pj"];
                    var rjs=data["rj"];
                    console.log(pjs);
                    console.log(rjs);
                    $("#show_points").val(JSON.stringify(pjs));
                    $("#show_relationships").val(JSON.stringify(rjs));
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.log(errorThrown);
                }
            })
        })
    })
</script>
</html>
