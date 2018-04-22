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

        var params_input = ["v2ray_host", "v2ray_update_proxy"];
        var params_check = ["v2ray_enable"];
        var params_base64 = ["v2ray_config"];
        var current_page = 'Module_v2ray.asp';

        function init() {
            show_menu();
            update_ss_ui(db_v2ray);
            buildswitch();
            version_show();
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
                            $("#updateBtn").html("<i>升级到：" + local_version + "</i>");
                        }
                    }
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


        function save() {
            var dbus = {};
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

        function showLoadingBar(check_file) {
            showSSLoadingBar(0);
            setTimeout("get_realtime_log('" + check_file + "');", 500);
        }

        function push_data(obj, check_file) {
            if(!check_file) {
                check_file = '/res/v2ray_status.htm'
            }

            $.ajax({
                type: "POST",
                url: '/applydb.cgi?p=v2ray',
                contentType: "application/x-www-form-urlencoded",
                dataType: 'text',
                data: $.param(obj),
                success: function(response) {
                    showLoadingBar(check_file);
                }
            });
        }

        function get_realtime_log(url) {
            $.ajax({
                url: url,
                dataType: 'html',
                error: function(xhr) {
                    setTimeout("get_realtime_log('" + url + "');", 1000);
                },
                success: function(response) {
                    var retArea = E("log_content3");
                    if (response.search("XU6J03M6") != -1) {
                        retArea.value = response.replace("XU6J03M6", " ");
                        E("ok_button").style.display = "";
                        retArea.scrollTop = retArea.scrollHeight;
                        x = 5;
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
                        setTimeout("get_realtime_log('" + url + "');", 250);
                    }
                    retArea.value = response.replace("XU6J03M6", " ");
                    retArea.scrollTop = retArea.scrollHeight;
                    _responseLen = response.length;
                },
                error: function() {
                    setTimeout("get_realtime_log('" + url + "');", 500);
                }
            });
        }

        function count_down_close() {
            if (x == "0") {
                hideSSLoadingBar();
            }
            if (x < 0) {
                E("ok_button1").value = "手动关闭"
                return false;
            }
            E("ok_button1").value = "自动关闭（" + x + "）"
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
                                                <div>通过 v2ray 科学上网，需要和 ss 科学上网插件配合使用。</div>
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
                                                            <div id="ss_version_show" style="display:table-cell;float: left;position: absolute;margin-left:170px;padding: 5.5px 0px;"> 
                                                                <i>当前版本：<% dbus_get_def("v2ray_module_version", "未知"); %></i>
                                                            </div>
                                                            <div style="display:table-cell;float: left;margin-left:270px;position: absolute;padding: 5.5px 0px;">
                                                                <a type="button" class="ss_btn" target="_blank" href="https://github.com/wd/koolshare_plugin_v2ray/blob/master/Changelog.md">更新日志</a>
                                                            </div>

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
                                                        <th width="35%">更新用代理服务器</th>
                                                        <td>
                                                            <input type="text" class="input_ss_table" style="width:auto;" size="50" id="v2ray_update_proxy" name="v2ray_update_proxy" maxlength="50" placeholder="--socks5-hostname 127.0.0.1:23456" value='<% dbus_get_def("v2ray_update_proxy", ""); %>' >
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th width="35%">服务器</th>
                                                        <td>
                                                            <input type="text" class="input_ss_table" style="width:auto;" size="30" id="v2ray_host" name="v2ray_host" maxlength="20" placeholder="v2ray 服务器" value='<% dbus_get_def("v2ray_host", ""); %>' >
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th width="35%">ID</th>
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
