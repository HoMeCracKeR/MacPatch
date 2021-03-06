<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">


<script type="text/javascript" src="/admin/js/jquery-latest.js"></script>
<script type="text/javascript" src="/admin/js/jquery-ui-latest.js"></script>
<link rel="stylesheet" type="text/css" media="screen" href="/admin/js/ui/Aristo-jQuery-UI-Theme/css/Aristo/Aristo.css" />
<link rel="stylesheet" type="text/css" media="screen" href="/admin/js/jqGrid/css/ui.jqgrid.css" />
<script src="/admin/js/jqGrid/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="/admin/js/jqGrid/js/jquery.jqGrid.min.js" type="text/javascript"></script>

<style type="text/css">
	.EditTable td {
	    align: left;
	}
</style>
<style type="text/css">
	.ui-jqgrid {font-size:12px;}
	.ui-jqgrid .ui-jqgrid-titlebar {font-size:18px; font-weight:bold; font-style:italic;}
	.ui-jqgrid .ui-jqgrid-htable th {font-size:12px; font-weight:bold; vertical-align:bottom;}
	.ui-jqgrid .ui-jqgrid-pager { font-size: 12px; vertical-align:center;}
	.ui-jqgrid-btable .ui-state-highlight { background: yellow; }
</style>

<style type="text/css">
    .xAltRow { background-color: #F0F8FF; background-image: none; }
</style>

<script type="text/Javascript">
	function load(url)
	{
		window.open(url,'_self') ;
	}
</script>

<script type="text/javascript">
	$(document).ready(function()
		{
			var lastsel=-1;
			$("#list").jqGrid(
			{
				url:'admin_mp_servers.cfc?method=getMPServers', //CFC that will return the users
				datatype: 'json', //We specify that the datatype we will be using will be JSON
				colNames:['','Server', 'Port', 'Use SSL', 'Use SSL Auth', 'Is Master', 'Is Proxy', 'Active'],
				colModel :[
				  {name:'rid',index:'rid', width:1, align:"center", sortable:false, hidden:true},
				  {name:'server', index:'server', width:160, editable:true, editoptions:{size:70}},
				  {name:'port', index:'port', width:60, editable:true, formoptions:{align: 'left'}},
				  {name:'useSSL', index:'useSSL', width:60, editable:true, edittype:'select', editoptions:{value:{1:'Yes',0:'No'}}},
				  {name:'useSSLAuth', index:'useSSLAuth', width:60, editable:true, edittype:'select', editoptions:{value:{1:'Yes',0:'No'}}},
				  {name:'isMaster', index:'isMaster', width:60, editable:true, edittype:'select', editoptions:{value:{1:'Yes',0:'No'}}},
				  {name:'isProxy', index:'isProxy', width:60, editable:true, edittype:'select', editoptions:{value:{1:'Yes',0:'No'}}},
				  {name:'active', index:'active', width:60, editable:true, edittype:'select', editoptions:{value:{1:'Yes',0:'No'}}}
				],
				altRows:true,
				altclass:'xAltRow',
				pager: jQuery('#pager'), //The div we have specified, tells jqGrid where to put the pager
				rowNum:20, //Number of records we want to show per page
				rowList:[5,10,20,30], //Row List, to allow user to select how many rows they want to see per page
				sortorder: "desc", //Default sort order
				sortname: "rid", //Default sort column
				viewrecords: true, //Shows the nice message on the pager
				imgpath: '/', //Image path for prev/next etc images
				caption: 'MacPatch Servers', //Grid Name
				height:'auto', //I like auto, so there is no blank space between. Using a fixed height can mean either a scrollbar or a blank space before the pager
				recordtext: "View {0} - {1} of {2} Records",
				pgtext: "Page {0} of {1}",
				pginput:true,
				width:980,
				hidegrid:false,
				editurl:"admin_mp_servers.cfc?method=editMPServers",//Not used right now.
				toolbar:[false,"top"],//Shows the toolbar at the top. I will decide if I need to put anything in there later.
				//The JSON reader. This defines what the JSON data returned from the CFC should look like
				loadComplete: function(){
					var ids = jQuery("#list").getDataIDs();
					for(var i=0;i<ids.length;i++){
						var cl = ids[i]
						//sync = "<input type='image' style='padding-left:4px;' onclick=syncContent('"+cl+"'); src='/admins/images/sync_16.png'>"
						//jQuery("#list").setRowData(ids[i],{rid:sync})
					}
				},
				onSelectRow: function(id)
				{
					if(id && id!==lastsel)
					{
					  lastsel=id;
					}
				},
				ondblClickRow: function(id) 
				{
				    <cfif session.IsAdmin IS true>
					$('#list').editRow(id, true, undefined, function(res) {
					    // res is the response object from the $.ajax call
					    $("#list").trigger("reloadGrid");
					});
					</cfif>
				},
				jsonReader: {
					total: "total",
					page: "page",
					records:"records",
					root: "rows",
					userdata: "userdata",
					cell: "",
					id: "0"
					}
				}
			);
			<cfif session.IsAdmin IS true>
			$("#list").jqGrid('navGrid',"#pager",{edit:true,add:true,del:true},{closeOnEscape:true,reloadAfterSubmit:true,width:600, align:"left"},{reloadAfterSubmit:true,width:600},{});
			</cfif>
			
			$(window).bind('resize', function() {
				$("#list").setGridWidth($(window).width()-20);
			}).trigger('resize');
		}
	);
</script>
<table id="list" class="scroll" cellpadding="0" cellspacing="0" style="font-size:11px;"></table>
<div id="pager" class="scroll" style="display:block"></div>
<div id="dialog" title="Detailed Proxy Server Information" style="text-align:left;" class="ui-dialog-titlebar"></div>

