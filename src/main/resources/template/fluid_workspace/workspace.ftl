[#ftl]
[#import "base.ftl" as base]

[#assign headCss]
<style>
    .row-fluid #noMargin {
        margin-left:0;
    }

    .tool-line {
        position:fixed;
        text-align: center;
        top: 56px;
    }

    #grid {
        margin-top: 60px;
        margin-left: 20px;
        margin-right: 20px;
    }

    .modal-body .sc-RepoBrowser, .modal-body .atb-WorkingResources {
        height: 400px;
    }
</style>
[/#assign]

[#assign headScripts]
[#include "ui_scripts.ftl"]
<script src="${cp}/static/js/dm/fluid_workspace.js" type="text/javascript"></script>
[/#assign]

[#assign headerButtons]
<li id="projectViewerButtons"></li>
<li id="searchButton" title="Search text documents in the current project">
    <a href="#" role="button">
        <span class="icon-search"></span>
        Search
    </a>
</li>
<li id="repositories_button" title="Show resources available on the internet">
    <a href="#repoBrowserModal" role="button" data-toggle="modal">
        <span class="icon-globe"></span>
        External Repositories
    </a>
</li>
<li class="dropdown" title="Change how many viewers are shown at a time">
    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
        <span class="icon-th"></span>
        Layout
        <b class="caret"></b>
    </a>
    <ul class="dropdown-menu" style="min-width: 0;">
        <li id="1x1_layout_button"><a href="#" title="Show one viewer per screen"><div class="atb-layout-picker-button-1x1"></div></a></li>
        <li id="1x2_layout_button"><a href="#" title="Show 1 row and 2 columns of viewers per screen"><div class="atb-layout-picker-button-2x1"></div></a></li>
        <li id="1x3_layout_button"><a href="#" title="Show 1 row and 3 columns of viewers per screen"><div class="atb-layout-picker-button-3x1"></div></a></li>
        <li id="2x2_layout_button"><a href="#" title="Show 2 rows and 2 columns of viewers per screen"><div class="atb-layout-picker-button-2x2"></div></a></li>
        <li id="2x3_layout_button"><a href="#" title="Show 3 rows and 2 columns of viewers per screen"><div class="atb-layout-picker-button-2x3"></div></a></li>
        <li id="3x3_layout_button"><a href="#" title="Show 3 rows and 3 columns of viewers per screen"><div class="atb-layout-picker-button-3x3"></div></a></li>
        <!-- <li id="3x4_layout_button"><a href="#">3x4</a></li> -->
        <!-- <li id="4x4_layout_button"><a href="#">4x4</a></li> -->
    </ul>
</li>
[/#assign]

[#assign initScripts]
<script type="text/javascript" >
    // Workspace setup code
    var staticUrl = "${cp}/static/";
    var styleRoot = "${cp}/static/css/";
    var wsURI = "${cp}";
    var mediawsURI = "${cp}/media/";
    var wsSameOriginURI = "/";

    var restBasePath = "${cp}/store";

    initWorkspace(wsURI, mediawsURI, wsSameOriginURI, [#if user?has_content]"${user.username}"[#else]null[/#if],
            styleRoot, staticUrl, restBasePath);


    $("#new_text_button").click(function(e) {
        openBlankTextDocument();
    });


    // Begin script for layout selection
    $("#1x1_layout_button").click(function(){
        viewerGrid.setDimensions(1,1);
    })

    $("#1x2_layout_button").click(function(){
        viewerGrid.setDimensions(1,2);
    })

    $("#1x3_layout_button").click(function(){
        viewerGrid.setDimensions(1,3);
    })

    $("#2x2_layout_button").click(function(){
        viewerGrid.setDimensions(2,2);
    })

    $("#2x3_layout_button").click(function(){
        viewerGrid.setDimensions(2,3);
    })

    $("#3x3_layout_button").click(function(){
        viewerGrid.setDimensions(3,3);
    })

    $("#3x4_layout_button").click(function(){
        viewerGrid.setDimensions(3,4);
    })

    $("#4x4_layout_button").click(function(){
        viewerGrid.setDimensions(4,4);
    })
    // End script for layout selection


</script>
[/#assign]

[@base.page title="DM Workspace" headCss=headCss headScripts=headScripts headerButtons=headerButtons]
<div>
    <div id="grid">

    </div>
</div>

<!-- Repo Browser Modal -->
<div id="repoBrowserModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
        <h3 id="myModalLabel">Repositories</h3>
    </div>
    <div class="modal-body">

    </div>
    <div class="modal-footer">
        <button class="btn btn-primary" data-dismiss="modal" aria-hidden="true">Done</button>
    </div>
</div>

<!-- Working Resources Modal -->
<div id="workingResourcesModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
        <h3 id="myModalLabel">My Resources</h3>
    </div>
    <div class="modal-body">

    </div>
    <div class="modal-footer">
        <button class="btn btn-primary" data-dismiss="modal" aria-hidden="true">Done</button>
    </div>
</div>
[/@base.page]