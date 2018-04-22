<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
        <meta HTTP-EQUIV="Expires" CONTENT="-1"/>
        <link rel="shortcut icon" href="images/favicon.png"/>
        <link rel="icon" href="images/favicon.png"/>
        <title>软件中心 - V2ray 设置</title>
        <link rel="stylesheet" type="text/css" href="index_style.css"/>
        <link rel="stylesheet" type="text/css" href="form_style.css"/>
        <link rel="stylesheet" type="text/css" href="usp_style.css"/>
        <link rel="stylesheet" type="text/css" href="ParentalControl.css">
        <link rel="stylesheet" type="text/css" href="css/icon.css">
        <link rel="stylesheet" type="text/css" href="css/element.css">
        <link rel="stylesheet" type="text/css" href="/res/shadowsocks.css">
        <link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
        <script type="text/javascript" src="/state.js"></script>
        <script type="text/javascript" src="/popup.js"></script>
        <script type="text/javascript" src="/help.js"></script>
        <script type="text/javascript" src="/validator.js"></script>
        <script type="text/javascript" src="/js/jquery.js"></script>
        <script type="text/javascript" src="/general.js"></script>
        <script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
        <script type="text/javascript" src="/res/v2ray.js"></script>
        <script type="text/javascript" src="/dbconf?p=v2ray&v=<% uptime(); %>"></script>
        <script type="text/javascript">

        var _responseLen;
        var noChange = 0;
        var checkss = 0;
        var ss_enable = 0;
        var v2ray_version;

        var params_input = ["v2ray_host", "v2ray_update_proxy"];
        var params_check = ["v2ray_enable"];
        var params_base64 = ["v2ray_config"];
        var current_page = 'Module_v2ray.asp';

        function init() {
            show_menu();
            check_ss_status();
            update_ss_ui(db_v2ray);
            buildswitch();
            version_show();
            v2ray_version_show();
            setTimeout("get_ss_status_data()", 500);
        }

        function check_ss_status() {
            ss_enable = E('ss_basic_enable').value;
            if(ss_enable == 1) {
                E('ss_status').innerHTML = "<a href='Main_Ss_Content.asp'>ss 状态:&nbsp;<i>运行中</i></a>";
            } else {
                E('ss_status').innerHTML = "<a href='Main_Ss_Content.asp'>ss 状态:&nbsp;<span style='color:red;'>关闭中</span></a>";
            }
        }

        function version_show() {
            var local_version = db_v2ray["v2ray_module_version"];
            $.ajax({
                url: 'https://raw.githubusercontent.com/wd/koolshare_plugin_v2ray/master/Version',
                type: 'GET',
                dataType: 'text',
                success: function(version) {
                    if (typeof(version) != "undefined" && version.length > 0) {
                        version = version.split('\n')[0];
                        if (version != local_version) {
                            $("#updateBtn").html("<i>升级到：" + version + "</i>");
                        }
                    }
                }
            });
        }

        function v2ray_version_show() {
            $.ajax({
                url: 'apply.cgi?current_page=' + current_page + '&next_page=' + current_page + '&group_id=&modified=0&action_mode=+Refresh+&action_script=&action_wait=&first_time=&preferred_lang=CN&SystemCmd=v2ray_version.sh&firmver=3.0.0.4&timestamp='+ new Date(),
                dataType: 'html',
                success: function(version) {
                    setTimeout("check_v2ray_version();", 1000);
                }
            });
        }

        function check_v2ray_version(){
            get_realtime_output('', function(res){
                eval(res);
                if (typeof(v2ray_version) == "object") {
                    var version = v2ray_version['new_version'];
                    var local_version = v2ray_version['cur_version'];
                    var update = v2ray_version['update'];
                    if (update == 1) {
                        $("#updateV2rayBtn").html("<i>升级到：" + version + "</i>");
                    }
                    $('#v2ray_version_show').html("<i>当前版本: " + local_version + "</i>");
                }

            });
        }


        function get_v2ray_status() {
            $.ajax({
                url: 'apply.cgi?current_page=' + current_page + '&next_page=' + current_page + '&group_id=&modified=1&action_mode=+Refresh+&action_script=&action_wait=&first_time=&preferred_lang=CN&SystemCmd=v2ray_status.sh&firmver=3.0.0.4',
                dataType: 'html',
                success: function(response) {
                    showLoadingBar('', 1);
                }

            });
        }

        function update_ss_ui(obj) {
            // All base64 values
            for (var i = 0; i < params_base64.length; i++) {
                var key = params_base64[i];
                if(E(key)) {
                    E(key).value = Base64.decode(obj[key] || "");
                }
            }

            // All check values
            for (var i = 0; i < params_check.length; i++) {
                var key = params_check[i];
                if(E(key)) {
                    if(obj[key] == 1){
                        E(key).checked = true;
                    } else {
                        E(key).checked = false;
                    }
                }
            }

            // All input values
            for (var i = 0; i < params_input.length; i++) {
                var key = params_input[i];
                if(E(key)) {
                    E(key).value = obj[key] || "";
                }
            }
        }

        function get_ss_status_data() {
            if (checkss < 10000) {
                checkss++;
                refreshRate = 5; //5s
                $.ajax({
                    type: "get",
                    url: "/dbconf?p=ss_basic_enable",
                    dataType: "script",
                    success: function() {
                        if (refreshRate != 0) {
                            if (ss_enable == "1") {
                                $.ajax({
                                    url: '/ss_status',
                                    dataType: "html",
                                    success: function(response) {
                                        var arr = JSON.parse(response);
                                        if (arr[0] == "" || arr[1] == "") {
                                            E("ss_state2").innerHTML = "国外连接 - " + "Waiting for first refresh...";
                                            E("ss_state3").innerHTML = "国内连接 - " + "Waiting for first refresh...";
                                        } else {
                                            E("ss_state2").innerHTML = arr[0];
                                            E("ss_state3").innerHTML = arr[1];
                                        }
                                    }
                                });
                            } else {
                                E("ss_state2").innerHTML = "国外连接 - " + "Waiting...";
                                E("ss_state3").innerHTML = "国内连接 - " + "Waiting...";
                            }
                        }
                        if (refreshRate > 0) {
                            setTimeout("get_ss_status_data();", refreshRate * 1000);
                        }
                    }

                });
            }
        }


        function save() {
            var dbus = {};
            checkss = 10001; //stop check status
            // collect data from input
            for (var i = 0; i < params_input.length; i++) {
                if (E(params_input[i])) {
                    dbus[params_input[i]] = E(params_input[i]).value;
                }
            }
            // collect data from checkbox
            for (var i = 0; i < params_check.length; i++) {
                dbus[params_check[i]] = E(params_check[i]).checked ? '1' : '0';
            }
            // data need base64 encode
            for (var i = 0; i < params_base64.length; i++) {
                if (!E(params_base64[i]).value) {
                    dbus[params_base64[i]] = "";
                } else {
                    if (E(params_base64[i]).value.indexOf(".") != -1) {
                        dbus[params_base64[i]] = Base64.encode(E(params_base64[i]).value);
                    } else {
                        //乱码了
                        dbus[params_base64[i]] = "";
                    }
                }
            }
            dbus["SystemCmd"] = "ss_config.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = current_page;
            //push_data(dbus, '/res/ss_proc_status.htm');
            push_data(dbus, '/cmdRet_check.htm');
        }

        function showLoadingBar(check_url, action) {
            if(typeof(action) == 'undefined') {
                action = 0;
            }
            showSSLoadingBar(action);
            setTimeout("get_realtime_log('" + check_url + "');", 500);
        }

        function push_data(obj, check_url) {
            $.ajax({
                type: "POST",
                url: '/applydb.cgi?p=v2ray',
                contentType: "application/x-www-form-urlencoded",
                dataType: 'text',
                data: $.param(obj),
                success: function(response) {
                    showLoadingBar(check_url);
                }
            });
        }

        function get_realtime_log(url) {
            if (url == 'undefined' || typeof(url) == "undefined" || url.length == 0) {
                url = '/res/v2ray_status.htm';
            }

            $.ajax({
                url: url,
                dataType: 'html',
                success: function(response) {
                    var retArea = E("log_content3");
                    if (response.search("XU6J03M6") != -1) {
                        retArea.value = response.replace("XU6J03M6", " ");
                        E("ok_button").style.display = "";
                        retArea.scrollTop = retArea.scrollHeight;
                        x = 8;
                        count_down_close();
                        return true;
                    } else {
                        E("ok_button").style.display = "none";
                    }
                    if (_responseLen == response.length) {
                        noChange++;
                    } else {
                        noChange = 0;
                    }
                    if (noChange > 1000) {
                        return false;
                    } else {
                        setTimeout(function(){get_realtime_log(url)}, 250);
                    }
                    retArea.value = response.replace("XU6J03M6", " ");
                    retArea.scrollTop = retArea.scrollHeight;
                    _responseLen = response.length;
                },
                error: function() {
                    setTimeout(function(){get_realtime_log(url)}, 500);
                }
            });
        }

        function get_realtime_output(url, callback) {
            if (url == 'undefined' || typeof(url) == "undefined" || url.length == 0) {
                url = '/res/v2ray_status.htm';
            }

            $.ajax({
                url: url,
                dataType: 'html',
                success: function(response) {
                    if (response.search("XU6J03M6") != -1) {
                        var res = response.replace("XU6J03M6", " ");
                        callback(res);
                        return;
                    }
                    if (_responseLen == response.length) {
                        noChange++;
                    } else {
                        noChange = 0;
                    }
                    if (noChange > 1000) {
                        return false;
                    } else {
                        setTimeout(function(){get_realtime_output(url, callback)}, 250);
                    }
                    _responseLen = response.length;
                },
                error: function(e) {
                    setTimeout(function(){get_realtime_output(url, callback)}, 500);
                }
            });
        }


        function count_down_close() {
            if (x == "0") {
                hideSSLoadingBar();
            }
            if (x < 0) {
                E("ok_button1").value = "手动关闭";
                return false;
            }
            E("ok_button1").value = "自动关闭（" + x + "）";
             --x;
            setTimeout("count_down_close();", 1000);
        }

        function onSubmit() {
            save();
        }

        function pass_checked(obj){
            switchType(obj, document.form.show_pass.checked, true);
        }

        function buildswitch(){
            var rrt = E("v2ray_enable");
            if (db_v2ray['v2ray_enable'] != "1") {
                rrt.checked = false;
                E('v2ray_detail_table').style.display = "none";
            } else {
                rrt.checked = true;
                E('v2ray_detail_table').style.display = "";
            }

            $("#v2ray_enable").click(
            function(){
                if(E('v2ray_enable').checked){
                    E('v2ray_detail_table').style.display = "";
                }else{
                    E('v2ray_detail_table').style.display = "none";
                }
            });
        }

        function update_v2ray_plugin() {
            var dbus = {};
            dbus["SystemCmd"] = "v2ray_plugin_update.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = current_page;
            push_data(dbus);
        }

        function update_v2ray() {
            var dbus = {};
            dbus["SystemCmd"] = "v2ray_update.sh";
            dbus["action_mode"] = " Refresh ";
            dbus["current_page"] = current_page;
            push_data(dbus);
        }

        function pop_111() {
            require(['/res/layer/layer.js'], function(layer) {
                layer.open({
                    type: 2,
                    shade: .7,
                    scrollbar: 0,
                    title: '国内外分流信息:ip111.cn',
                    area: ['750px', '480px'],
                    //offset: ['355px', '368px'],
                    fixed: false, //不固定
                    maxmin: true,
                    shadeClose: 1,
                    id: 'LAY_layuipro',
                    btnAlign: 'c',
                    content: ['http://ip111.cn/', 'no']
                });
            });
        }

        function reload_Soft_Center() {
            location.href = "/Main_Soft_center.asp";
        }
        </script>
    </head>
    <body onload="init();">
        <div id="TopBanner"></div>
        <div id="Loading" class="popup_bg"></div>
        <div id="LoadingBar" class="popup_bar_bg">
        <table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock"  align="center">
            <tr>
                <td height="100">
                <div id="loading_block3" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
                <div id="loading_block2" style="margin:10px auto;width:95%;"></div>
                <div id="log_content2" style="margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
                    <textarea cols="63" rows="21" wrap="on" readonly="readonly" id="log_content3" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:#000;color:#FFFFFF;outline: none;padding-left:3px;padding-right:22px;overflow-x:hidden"></textarea>
                </div>
                <div id="ok_button" class="apply_gen" style="background: #000;display: none;">
                    <input id="ok_button1" class="button_gen" type="button" onclick="hideSSLoadingBar()" value="确定">
                </div>
                </td>
            </tr>
        </table>
        </div>

        <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
        <form method="post" name="form" action="/applydb.cgi?p=v2ray" target="hidden_frame">
            <input type="hidden" name="current_page" value="Module_v2ray.asp"/>
            <input type="hidden" name="next_page" value="Module_v2ray.asp"/>
            <input type="hidden" name="group_id" value=""/>
            <input type="hidden" name="modified" value="0"/>
            <input type="hidden" name="action_mode" value=""/>
            <input type="hidden" name="action_script" value=""/>
            <input type="hidden" name="action_wait" value="5"/>
            <input type="hidden" name="first_time" value=""/>
            <input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>"/>
            <input type="hidden" name="SystemCmd" value=""/>
            <input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>"/>
            <input type="hidden" id="ss_basic_enable" name="ss_basic_enable" value="<% dbus_get_def("ss_basic_enable", ""); %>"/>
            <table class="content" align="center" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="17">&nbsp;</td>
                    <td valign="top" width="202">
                        <div id="mainMenu"></div>
                        <div id="subMenu"></div>
                    </td>
                    <td valign="top">
                        <div id="tabMenu" class="submenuBlock"></div>
                        <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                            <tr>
                                <td align="left" valign="top">
                                    <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
                                        <tr>
                                            <td bgcolor="#4D595D" colspan="3" valign="top">
                                                <div>&nbsp;</div>
                                                <div style="float:left;" class="formfonttitle">V2ray</div>
                                                <div style="float:right; width:15px; height:25px;margin-top:10px"><img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img></div>
                                                <div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
                                                <div class="formfontdesc" style="padding-top:5px;margin-top:0px;float: left;" id="cmdDesc">
                                                <div style="float:left">通过 v2ray 科学上网，需要和 ss 科学上网插件配合使用。</div><div id="ss_status" style="float:left"></div>
                                                </div>
                                                <!--<div class="formfontdesc" id="cmdDesc"></div>-->
                                                <table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="routing_table">
                                                    <thead>
                                                    <tr>
                                                        <td colspan="2">开关设置</td>
                                                    </tr>
                                                    </thead>
                                                    <tr>
                                                    <th>开启 V2ray</th>
                                                        <td colspan="2">
                                                            <div class="switch_field" style="display:table-cell;float: left;">
                                                                <label for="v2ray_enable">
                                                                    <input id="v2ray_enable" class="switch" type="checkbox" style="display: none;">
                                                                    <div class="switch_container" >
                                                                        <div class="switch_bar"></div>
                                                                        <div class="switch_circle transition_style">
                                                                            <div></div>
                                                                        </div>
                                                                    </div>
                                                                </label>
                                                            </div>
                                                            <div id="update_button" style="display:table-cell;float: left;position: absolute;margin-left:70px;padding: 5.5px 0px;">
                                                                <a id="updateBtn" type="button" class="ss_btn" style="cursor:pointer" onclick="update_v2ray_plugin()">检查并更新</a>
                                                            </div>
                                                            <div id="v2ray_plugin_version_show" style="display:table-cell;float: left;position: absolute;margin-left:170px;padding: 5.5px 0px;"> 
                                                                <i>当前版本：<% dbus_get_def("v2ray_module_version", "未知"); %></i>
                                                            </div>
                                                            <div style="display:table-cell;float: left;margin-left:270px;position: absolute;padding: 5.5px 0px;">
                                                                <a type="button" class="ss_btn" target="_blank" href="https://github.com/wd/koolshare_plugin_v2ray/blob/master/Changelog.md">更新日志</a>
                                                            </div>

                                                        </td>
                                                    </tr>
                                                    <tr id="ss_state">
                                                        <th>v2ray 版本</th>
                                                        <td colspan="2">
                                                            <div id="update_button" style="display:table-cell;float: left;padding: 5.5px 0px;">
                                                                <a id="updateV2rayBtn" type="button" class="ss_btn" style="cursor:pointer" onclick="update_v2ray()">检查并更新</a>
                                                            </div>
                                                            <div id="v2ray_version_show" style="display:table-cell;float: left;position: absolute;margin-left:100px;padding: 5.5px 0px;"> 
                                                                <i>当前版本：Waiting...</i>
                                                            </div>
                                                            <div style="display:table-cell;float: left;margin-left:220px;position: absolute;padding: 5.5px 0px;">
                                                                <a type="button" class="ss_btn" target="_blank" href="https://www.v2ray.com/chapter_00/01_versions.html">更新日志</a>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr id="ss_state">
                                                    <th id="mode_state" width="35%">运行状态</th>
                                                        <td>
                                                            <div style="display:table-cell;float: left;margin-left:0px;">
                                                                <span id="ss_state2">国外连接 - Waiting...</span>
                                                                <br/>
                                                                <span id="ss_state3">国内连接 - Waiting...</span>
                                                            </div>
                                                            <div style="display:table-cell;float: left;margin-left:270px;position: absolute;padding: 10.5px 0px;">
                                                                <a type="button" class="ss_btn" style="cursor:pointer" onclick="pop_111(3)" href="javascript:void(0);">分流检测</a>
                                                            </div>
                                                            <div style="display:table-cell;float: left;margin-left:350px;position: absolute;padding: 10.5px 0px;">
                                                            <a type="button" class="ss_btn" style="cursor:pointer" onclick="get_v2ray_status()" href="javascript:void(0);">详细状态</a>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                       <th>更新用代理服务器</th>
                                                       <td>
                                                           <input type="text" class="input_ss_table" style="width:auto;" size="50" id="v2ray_update_proxy" name="v2ray_update_proxy" maxlength="50" placeholder="--socks5-hostname 127.0.0.1:23456" value='<% dbus_get_def("v2ray_update_proxy", ""); %>' >
                                                       </td>
                                                   </tr>

                                                    </table>
                                                    <table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="v2ray_detail_table">
                                                        <thead>
                                                        <tr>
                                                            <td colspan="2">基本设置</td>
                                                        </tr>
                                                        </thead>
                                                        <tr>
                                                            <th width="35%">服务器</th>
                                                            <td>
                                                                <input type="text" class="input_ss_table" style="width:auto;" size="30" id="v2ray_host" name="v2ray_host" maxlength="20" placeholder="v2ray 服务器" value='<% dbus_get_def("v2ray_host", ""); %>' >
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th width="35%">用户uuid</th>
                                                            <td>
                                                                <input  type="password" class="input_ss_table" style="width:auto;" size="20"  id="v2ray_id" name="v2ray_id" maxlength="30" placeholder="v2ray id" value='<% dbus_get_def("v2ray_id", ""); %>' />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                        <th width="20%">配置</th>
                                                        <td>
                                                            <textarea placeholder="# v2ray 配置" rows="12" style="width:99%; font-family:'Lucida Console'; font-size:12px;background:#475A5F;color:#FFFFFF;" id="v2ray_config" name="v2ray_config" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" title=""></textarea>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <div id="warn" style="display: none;margin-top: 20px;text-align: center;font-size: 20px;margin-bottom: 20px;"class="formfontdesc" ></div>
                                                <div class="apply_gen">
                                                    <button id="cmdBtn" type="button" class="button_gen" onclick="onSubmit()">提交</button>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="10" align="center" valign="top"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
        <div id="footer"></div>
    </body>
</html>
