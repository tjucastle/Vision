<%--
  Created by IntelliJ IDEA.
  User: dell-pc
  Date: 2019/7/25
  Time: 21:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>可视化系统</title>
    <link href="http://cdn.static.runoob.com/libs/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" />
    <link href="http://cdn.static.runoob.com/libs/bootstrap/3.3.7/css/bootstrap-theme.min.css" rel="stylesheet" />
    <style>
        /* 悬浮窗 */
        div.tooltip {
            position: absolute;
            text-align: center;
            padding: 5px;
            font: 12px sans-serif;
            background: lightsteelblue;
            border: 0px;
            border-radius: 8px;
            pointer-events: none;
        }
        div.tooltip:after {
            border-style: solid;
            border-width: 5px 0 5px 5px;
            border-color: transparent transparent transparent lightsteelblue;
            content: "";
            position: absolute;
            top: 50%;
            right: -4px;
            margin-top: -4px;
            display: block;
            width: 0px;
            height: 0px;
            z-index: -1;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row">
            <!--添加结点-->
            <div class="col-lg-3">
                <div class="panel panel-success">
                    <div class="panel-heading">
                        <h3 class="panel-title">Add Node</h3>
                    </div>
                    <div id="form-add-node" class="panel-body">
                        <div class="checkbox">
                            <label>
                                <input type="checkbox">自动添加
                            </label>
                        </div>
                        <button type="submit" class="btn btn-default btn-save">添加一个结点</button>
                    </div>
                </div>
            </div>
            <!-- 数据框图-->
            <div class="col-lg-9">
                <div class="panel panel-success">
                    <div class="panel-heading">
                        <h3 class="panel-title">Force Graph</h3>
                    </div>
                    <div class="panel-body">
                        <div id="chart"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!--展开图-->
    <div class="modal fade bs-example-modal-lg" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">Detail</h4>
                </div>
                <!--选择框-->
                <div class="modal-body" style="position:relative">
                    <div style="position:absolute;right:10px;bottom:0">
                        <div class="checkbox">
                            <div><input id="Address" type="checkbox" checked>Address</div>
                            <div><input id="CoMobile" type="checkbox">CoMobile</div>
                            <div><input id="CoName" type="checkbox">CoName</div>
                            <div><input id="ComAddress" type="checkbox">ComAddress</div>
                            <div><input id="ComName" type="checkbox" checked>ComName</div>
                            <div><input id="ComPhone" type="checkbox">ComPhone</div>
                            <div><input id="IDNO" type="checkbox" checked>IDNO</div>
                            <div><input id="LrMobile" type="checkbox">LrMobile</div>
                            <div><input id="LrName" type="checkbox">LrName</div>
                            <div><input id="Mobile" type="checkbox">Mobile</div>
                            <div><input id="Name" type="checkbox" checked>Name</div>
                            <div><input id="Phone" type="checkbox">Phone</div>
                            <div><input id="index" type="checkbox">index</div>
                            <div><input id="label" type="checkbox" checked>label</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!--脚本-->
    <script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/js/bootstrap.min.js"></script>
    <script src="https://d3js.org/d3.v5.min.js"></script>
    <script>
        //进行拖动
        var drag = simulation => {
            function dragstarted(d) {
                if (!d3.event.active) simulation.alphaTarget(0.3).restart();
                d.fx = d.x;
                d.fy = d.y;
            }
            function dragged(d) {
                d.fx = d3.event.x;
                d.fy = d3.event.y;
            }
            function dragended(d) {
                if (!d3.event.active) simulation.alphaTarget(0);
                d.fx = null;
                d.fy = null;
            }
            return d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended);
        };
        //添加结点
        function AddNode() {
            var maxId =
                d3.max(window.dataset.nodes, function (d) {
                    return d.id;
                }) || 0;
            //发起请求
            $.ajax({
                url: "display+",
                type: "POST",
                dataType: 'json',
                data: {
                    nowcnt: (maxId + 1).toString(),
                    nexcnt: (maxId + 2).toString(),
                },
                success: function (data) {
                    console.log("New Node", data);
                    //做标记，将背景显示为黄色
                    data.pj[0].n.newNode = true;
                    window.dataset.nodes.push(data.pj[0].n);
                    DrawForce(window.dataset, mainForce);
                    //闪烁两次
                    $("#" + (maxId + 1)).animate({ opacity: 0 }, 400, function () {
                        $("#" + (maxId + 1)).animate({ opacity: 1 }, 400, function () {
                            $("#" + (maxId + 1)).animate({ opacity: 0 }, 400, function () {
                                $("#" + (maxId + 1)).animate({ opacity: 1 }, 400)
                            })
                        })
                    });
                    $("#text" + (maxId + 1)).animate({ opacity: 0 }, 400, function () {
                        $("#text" + (maxId + 1)).animate({ opacity: 1 }, 400, function () {
                            $("#text" + (maxId + 1)).animate({ opacity: 0 }, 400, function () {
                                $("#text" + (maxId + 1)).animate({ opacity: 1 }, 400)
                            })
                        })
                    });
                    //连入图中（加入边）
                    setTimeout(function () {
                        if (data.rj.length) {
                            for (var rj of data.rj) {
                                window.dataset.links.push({
                                    source: rj.r.start,
                                    target: rj.r.end,
                                    value: 20,
                                    type: rj.r.type,
                                    connection: rj.r.properties.CONNECTION.val
                                })
                            }
                        }
                        DrawForce(window.dataset, mainForce);
                        $("#" + (maxId + 1)).attr("fill", "yellow");
                    }, 1800)
                    //连入完成，恢复原来的颜色
                    setTimeout(function () {
                        var color;
                        if (data.pj[0].n.properties.label.val == 0) color = "#3f51b5";
                        else if (data.pj[0].n.properties.label.val == 1) color = "#e51c23";
                        else color = "#e3e8e1";
                        var textColor;
                        if (data.pj[0].n.properties.label.val == 2) textColor = "#000";
                        else textColor = "#fff";
                        $("#" + (maxId + 1)).attr("fill", color);
                        console.log($("#text" + (maxId + 1)),textColor);
                        $("#text" + (maxId + 1)).attr("fill",textColor);
                        $("#text" + (maxId + 1)).css("fill",textColor);
                        delete window.dataset.nodes.find(t => t.id === data.pj[0].n.id).newNode;
                    }, 3000)
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.log(errorThrown);
                }
            })
        }
        //主框架
        var mainForce = (function () {
            var margin = {
                top: 0,
                left: 0,
                right: 0,
                bottom: 0
            };
            var outWidth = $("#chart").width(),
                outHeight =
                    (window.innerHeight || document.documentElement.innerHeight) - 100;
            var zoom = d3
                .zoom()
                .scaleExtent([0.01, 8])
                .on("zoom", function () {
                    svg.attr("transform", d3.event.transform);
                });
            var svg = d3
                .select("#chart")
                .append("svg")
                .attr("width", outWidth)
                .attr("height", outHeight)
                .call(zoom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
            var Glink = svg
                .append("g")
                .attr("stroke", "#999") //颜色
                .attr("stroke-opacity", 0.6); //不透明度
            var Glinktext = svg.append("g");
            var Gnode = svg
                .append("g")
                .attr("stroke", "#fff")
                .attr("stroke-width", 1.5);
            var Gtext = svg.append("g");
            $("#chart").bind("contextmenu", function () {
                return false;
            });
            $("#chart").attr(
                "style",
                "position:relative;" +
                "-moz-user-select: none;-webkit-user-select: none;" +
                "-ms-user-select: none;-khtml-user-select: none;user-select: none;"
            );
            return {
                svg: svg,
                Glink: Glink,
                Glinktext: Glinktext,
                Gnode: Gnode,
                Gtext: Gtext,
                outWidth: outWidth,
                outHeight: outHeight,
                strength: -500,
                dotR: 30,
                distance: 100,
                margin: margin,
                type: "main"
            };
        })();
        //展开图的框架
        var detailForce = (function () {
            var margin = {
                top: 0,
                left: 0,
                right: 0,
                bottom: 0
            };
            var outWidth = 820,
                outHeight = 500;
            var zoom = d3
                .zoom()
                .scaleExtent([0.01, 8])
                .on("zoom", function () {
                    svg.attr("transform", d3.event.transform);
                });
            var svg = d3
                .select("#myModal .modal-body")
                .append("svg")
                .attr("width", outWidth)
                .attr("height", outHeight)
                .call(zoom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
            var Glink = svg
                .append("g")
                .attr("stroke", "#999")
                .attr("stroke-opacity", 0.6);
            var Gnode = svg
                .append("g")
                .attr("stroke", "#fff")
                .attr("stroke-width", 1.5);
            var Gtext = svg.append("g");
            $("#myModal").attr(
                "style",
                "-moz-user-select: none;-webkit-user-select: none;" +
                "-ms-user-select: none;-khtml-user-select: none;user-select: none;"
            );
            return {
                svg: svg,
                Glink: Glink,
                Gnode: Gnode,
                Gtext: Gtext,
                outWidth: outWidth,
                outHeight: outHeight,
                strength: -500,
                distance: 100,
                dotR: 30,
                margin: margin,
                type: "detail"
            };
        })();
        //获取要展开的结点
        function getSelected(node) {
            var obj = { nodes: [], links: [] };
            if (node) sNode = window.dataset.nodes.find(t => t.id === node.id);
            // loanID
            var model = {
                id: sNode.id,
                properties: {
                    label: { val: sNode.properties.label.val },
                    loanID: { val: sNode.properties.loanID.val || "none" }
                }
            };
            obj.nodes.push(model);
            // Address
            if ($("#Address").is(":checked")) {
                var model = {
                    id: sNode.id + 1,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.Address ? sNode.properties.Address.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // CoMobile
            if ($("#CoMobile").is(":checked")) {
                var model = {
                    id: sNode.id + 2,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.CoMobile ? sNode.properties.CoMobile.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // CoName
            if ($("#CoName").is(":checked")) {
                var model = {
                    id: sNode.id + 3,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.CoName ? sNode.properties.CoName.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // ComAddress
            if ($("#ComAddress").is(":checked")) {
                var model = {
                    id: sNode.id + 4,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.ComAddress ? sNode.properties.ComAddress.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // ComName
            if ($("#ComName").is(":checked")) {
                var model = {
                    id: sNode.id + 5,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.ComName ? sNode.properties.ComName.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // ComPhone
            if ($("#ComPhone").is(":checked")) {
                var model = {
                    id: sNode.id + 6,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.ComPhone ? sNode.properties.ComPhone.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            //IDNO
            if ($("#IDNO").is(":checked")) {
                var model = {
                    "id": sNode.id + 7,
                    "properties": {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.IDNO ? sNode.properties.IDNO.val : "none" },
                    }
                }
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            //LrMobile
            if ($("#LrMobile").is(":checked")) {
                var model = {
                    "id": sNode.id + 8,
                    "properties": {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.LrMobile ? sNode.properties.LrMobile.val : "none" },
                    }
                }
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            //LrName
            if ($("#LrName").is(":checked")) {
                var model = {
                    "id": sNode.id + 9,
                    "properties": {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.LrName ? sNode.properties.LrName.val : "none" },
                    }
                }
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            //Mobile
            if ($("#Mobile").is(":checked")) {
                var model = {
                    "id": sNode.id + 10,
                    "properties": {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.Mobile ? sNode.properties.Mobile.val : "none" },
                    }
                }
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // Name
            if ($("#Name").is(":checked")) {
                var model = {
                    id: sNode.id + 11,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.Name ? sNode.properties.Name.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // Phone
            if ($("#Phone").is(":checked")) {
                var model = {
                    id: sNode.id + 12,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.Phone ? sNode.properties.Phone.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // index
            if ($("#index").is(":checked")) {
                var model = {
                    id: sNode.id + 13,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.index ? sNode.properties.index.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    "source": sNode.id, "target": model.id, "value": 20
                });
            }
            // label
            if ($("#label").is(":checked")) {
                var model = {
                    id: sNode.id + 14,
                    properties: {
                        label: { val: sNode.properties.label.val },
                        loanID: { val: sNode.properties.label ? sNode.properties.label.val : "none" }
                    }
                };
                obj.nodes.push(model);
                obj.links.push({
                    source: sNode.id,
                    target: model.id,
                    value: 20
                });
            }
            return obj;
        }
        //进行绘制
        function DrawForce(data, force) {
            var margin = force.margin;
            var width = force.outWidth - margin.left - margin.right;
            var height = force.outHeight - margin.top - margin.bottom;
            var dotR = force.dotR;
            var main = (force == mainForce ? "#chart" : ".modal-body");
            $(main + " .tooltip").remove();
            var sNode;
            //悬浮窗
            var tooltip = d3
                .select(main)
                .append("div")
                .attr("class", "tooltip")
                .style("opacity", 0);
            //绘制图表
            function chart(data) {
                var links = data.links.map(d => Object.create(d));
                var nodes = data.nodes.map(d => Object.create(d));
                var simulation = d3
                    .forceSimulation(nodes)
                    .force(
                        "link",
                        d3
                            .forceLink(links)
                            .distance(force.distance)
                            .id(d => d.id)
                    ) //连线长度
                    .force("charge", d3.forceManyBody().strength(force.strength)) //点作用力
                    .force("center", d3.forceCenter(width / 2, height / 2)) //重心
                    .force("x", d3.forceX(width / 2))
                    .force("y", d3.forceY(height / 2)); //加入后两句后可以将新生成的点均匀分布
                //边
                force.Glink.selectAll("line")
                    .data(links)
                    .join("line")
                    .style("stroke-width", 1)
                    .attr("stroke-width", d => Math.sqrt(d.value))
                    .on("mouseover", function (d, i) {
                        if (force == mainForce) {
                            tooltip
                                .transition()
                                .duration(200)
                                .style("opacity", 0.9);
                            tooltip
                                .html(d.__proto__.connection)
                                .style("position", "absolute")
                                .style("left", (d.source.x + d.target.x) / 2 - $(".panel-body .tooltip").width() - 20 + "px")
                                .style("top", (d.source.y + d.target.y) / 2 - $(".panel-body .tooltip").height() + "px")
                        }
                    })
                    .on("mouseout", function (d) {
                        tooltip
                            .transition()
                            .duration(200)
                            .style("opacity", 0);
                    });
                //边上的标注
                if (force.Glinktext) {
                    force.Glinktext.selectAll("text")
                        .data(links)
                        .join("text")
                        .attr("font-size", 12)
                        .attr("dx", "6em") //////////改文字位置的时候改这个，硬编码
                        .attr("dy", "0em") //////////改文字位置的时候改这个，硬编码
                        .attr("text-anchor", "middle")
                        .style("cursor", "default")
                        .attr("class", "id-text")
                        .text(function (d) {
                            return d.__proto__.type;
                        })
                        .on("mouseover", function (d, i) {
                            if (force == mainForce) {
                                tooltip
                                    .transition()
                                    .duration(200)
                                    .style("opacity", 0.9);
                                tooltip
                                    .html(d.__proto__.connection)
                                    .style("position", "absolute")
                                    .style("left", (d.source.x + d.target.x) / 2 - $(".panel-body .tooltip").width() - 20 + "px")
                                    .style("top", (d.source.y + d.target.y) / 2 - $(".panel-body .tooltip").height() + "px")
                            }
                        })
                        .on("mouseout", function (d) {
                            tooltip
                                .transition()
                                .duration(200)
                                .style("opacity", 0);
                        })
                }
                //结点
                force.Gnode.selectAll("circle")
                    .data(nodes)
                    .join("circle")
                    .attr("class", "node")
                    .attr("r", dotR)
                    .attr("id", function (d) {
                        return d.id;
                    })
                    .attr("fill", function (d) {
                        if (d.newNode) return "yellow";
                        else if (d.properties.label.val == 0) return "#3f51b5";
                        else if (d.properties.label.val == 1) return "#e51c23";
                        else return "#e3e8e1";
                    })
                    .call(drag(simulation))
                    .on("mouseover", function (d, i) {
                        var tip = (force == mainForce ? $(".panel-body .tooltip") : $(".modal-body .tooltip"));
                        tooltip
                            .transition()
                            .duration(200)
                            .style("opacity", 0.9);
                        tooltip
                            .html(d.properties.loanID.val)
                            .style("position", "absolute")
                            .style("left", d.x - tip.width() - 45 + "px")
                            .style("top", d.y - tip.height() + "px")
                    })
                    .on("mouseout", function (d) {
                        tooltip
                            .transition()
                            .duration(200)
                            .style("opacity", 0);
                    })
                    .on("click", function (d) {
                        if(force==mainForce) {
                            d3.event.stopPropagation();
                            DrawForce(getSelected(d), detailForce);
                            $("#myModal").modal("show");
                        }
                    });
                //结点上的标注
                force.Gtext.selectAll("text")
                    .data(nodes)
                    .join("text")
                    .style("fill", function (d) {
                        if(d.__proto__.newNode) return "#000"
                        else if (d.__proto__.properties.label.val == "2") return "#000"
                        else return "#fff"
                    })
                    .attr("id", function (d) {
                        return ("text" + d.id);
                    })
                    .attr("font-size", 12)
                    .attr("dx", "6em") //改文字位置的时候改这个，硬编码
                    .attr("dy", "0em") //改文字位置的时候改这个，硬编码
                    .attr("text-anchor", "middle")
                    .style("cursor", "default")
                    .attr("class", "id-text")
                    .text(function (d) {
                        if (d.properties.loanID.val.length > 6)
                            return d.properties.loanID.val.substring(0, 6) + "..";
                        else return d.properties.loanID.val;
                    })
                    .on("click", function (d) {
                        d3.event.stopPropagation();
                    });
                //绘制
                simulation.on("tick", () => {
                    force.Glink.selectAll("line")
                        .attr("x1", d => d.source.x)
                        .attr("y1", d => d.source.y)
                        .attr("x2", d => d.target.x)
                        .attr("y2", d => d.target.y);
                    if (force.Glinktext) {
                        force.Glinktext.selectAll("text")
                            .attr("x", d => (d.source.x + d.target.x) / 2 - 60)
                            .attr("y", d => (d.source.y + d.target.y) / 2);
                    }
                    force.Gnode.selectAll("circle")
                        .attr("cx", d => d.x)
                        .attr("cy", d => d.y);
                    force.Gtext.selectAll("text")
                        .attr("x", d => d.x - 72)
                        .attr("y", d => d.y + (dotR - 20) / 2);
                });
            }
            chart(data);
        }
    </script>
    <script>
        //获取初始数据
        $.ajax({
            url: "display+",
            type: "POST",
            dataType: 'json',
            data: {
                nowcnt: "0",
                nexcnt: "10",
            },
            success: function (data) {
                console.log("Init Data",data);
                window.dataset = {};
                var nodes = [];
                for (var pj of data.pj) {
                    nodes.push(pj.n);
                }
                window.dataset.nodes = nodes;
                var links = [];
                for (var rj of data.rj) {
                    links.push({
                        source: rj.r.start,
                        target: rj.r.end,
                        value: 20,
                        type: rj.r.type,
                        connection: rj.r.properties.CONNECTION.val
                    })
                }
                window.dataset.links = links;
                DrawForce(window.dataset, mainForce);
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.log(errorThrown);
            }
        })
        //添加一个结点
        $("#form-add-node .btn-save").click(function (d) {
            //修改这里将新增结点的值从输入更换到读入
            AddNode();
        });
        //连续添加结点
        var Interval;
        $("#form-add-node .checkbox input").change(function () {
            if (this.checked) {
                AddNode();
                Interval = setInterval(function () {
                    AddNode();
                }, 4000);
            }
            else {
                clearInterval(Interval);
            }
        });
        //选择显示的属性
        $(".modal-body input").each(function () {
            $(this).change(function () {
                DrawForce(getSelected(), detailForce);
            })
        })
    </script>
</body>
</html>