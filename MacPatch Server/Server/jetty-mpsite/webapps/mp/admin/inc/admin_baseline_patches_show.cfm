<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script type="text/javascript" src="/admin/js/jquery-latest.js"></script>
<script type="text/javascript" src="/admin/js/jquery-ui-latest.js"></script>
<link rel="stylesheet" type="text/css" media="screen" href="/admin/js/ui/Aristo-jQuery-UI-Theme/css/Aristo/Aristo.css" />
<link rel="stylesheet" type="text/css" media="screen" href="/admin/js/jqGrid/css/ui.jqgrid.css" />
<script src="/admin/js/jqGrid/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="/admin/js/jqGrid/js/jquery.jqGrid.min.js" type="text/javascript"></script>

<cfif NOT IsDefined("url.bid")>
	Error: baseline info was not found.
<cfelse>
	<cfset fDD = url.bid>    
</cfif>

<script type="text/javascript">	
	function loadContent(param, id) {
		$("#dialog").load("includes/available_patches_apple_description.cfm?id="+id);
		$("#dialog").dialog(
		 	{
			bgiframe: false,
			height: 300,
			width: 600,
			modal: true
			}
		); 
		$("#dialog").dialog('open');
	}
</script>
<script type="text/Javascript">
	function load(url,id)
	{
		window.open(url,'_self') ;
	}
</script>
<cfif isDefined("fDD")>
	<cfquery name="qBInfo" datasource="#session.dbsource#">
        select *
        From mp_baseline
        Where
        baseline_id = '#fDD#'
    </cfquery>
</cfif>

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

<script type="text/javascript">
	$(document).ready(function()
		{
			function getLink() {
				var rowid = $("#list").getGridParam('selrow');
				var MyCellData = $("#list").jqGrid('getCell', rowid, 'p_name');
				return MyCellData;
			}
			
			var selMe = 0;
			var lastsel=-1;
			var getColumnIndexByName = function(grid, columnName) {
                    var cm = grid.jqGrid('getGridParam', 'colModel'), i, l;
                    for (i = 0, l = cm.length; i < l; i += 1) {
                        if (cm[i].name === columnName) {
                            return i; // return the index
                        }
                    }
                    return -1;
            };
			$("#list").jqGrid(
			{
				sortable: true,
				datatype: 'json', //We specify that the datatype we will be using will be JSON
				ajaxGridOptions:{
					type: "POST",
					url: "admin_baseline_patches.cfc?method=getMPBaselinePatches",
				},
				<cfif isDefined("fDD")>
				postData: {
					/* method: '', */
					searchType:true,
					searchField: function() { return "baseline_id"; },
					searchString: function() { return "<cfoutput>#fDD#</cfoutput>"; },
					searchOper: function() { return "cn"; }
				},
				</cfif>
				colNames:['','', 'Patch', 'Version', 'Type', 'Post Date'],
				colModel :[ 
				  {name:'rid',index:'rid', width:36, align:"center", sortable:false, resizable:false, hidden:true},
				  {name:'enbl', index:'enbl', width: 30, align:'center', sortable:true, sorttype:'int', 
				  formatter:'checkbox', editoptions:{value:'1:0'}, 
				  formatoptions:{disabled:<cfif session.IsAdmin IS true>false<cfelse>true</cfif>}},		
				  {name:'p_name', index:'p_name', width:200}, 
				  {name:'p_version', index:'p_version', width:100},
				  {name:'p_type', index:'p_type', width:100, align:"center"},
				  {name:'p_postdate', index:'p_postdate', width:200}
				],
				altRows:true,
				altclass:'xAltRow',
				pager: jQuery('#pager'), //The div we have specified, tells jqGrid where to put the pager
				rowNum:20, //Number of records we want to show per page
				rowList:[10,20,30,50,100], //Row List, to allow user to select how many rows they want to see per page
				sortorder: "desc", //Default sort order
				sortname: "p_postdate", //Default sort column
				viewrecords: true, //Shows the nice message on the pager
				imgpath: '/', //Image path for prev/next etc images
				caption: 'Patch Baseline<cfif qBInfo.Recordcount GTE 1><cfoutput> - #qBInfo.name#</cfoutput></cfif>', //Grid Name
				height:'auto', //I like auto, so there is no blank space between. Using a fixed height can mean either a scrollbar or a blank space before the pager
				recordtext: "View {0} - {1} of {2} Records",
				pgtext: "Page {0} of {1}",
				pginput:true,
				width:980,
				hidegrid:false,
				multiselect: false,
				multiboxonly: false,
				editurl:"admin_baseline_patches.cfc?method=addEditMPBaselinePatches",//Not used right now.
				toolbar:[false,"top"],
				loadComplete: function(){ 
					var ids = jQuery("#list").getDataIDs(); 
					for(var i=0;i<ids.length;i++){ 
						var cl = ids[i];
					}
					// Auto Enable Disable on Checkbox
                    var iCol = getColumnIndexByName ($(this), 'enbl'), rows = this.rows, i, c = rows.length;
                    for (i = 0; i < c; i += 1) {
                        $(rows[i].cells[iCol]).click(function (e) {
                            var id = $(e.target).closest('tr')[0].id,
                                isChecked = $(e.target).is(':checked');
								
                            $.ajax({
							    url: "admin_baseline_patches.cfc"
							  , type: "get"
							  , dataType: "json"
							  , data: {
							      method: "toggleBaselinePatch",
							  	  id: id
							  }
							  // this runs if an error
							  , error: function (xhr, textStatus, errorThrown){
							    // show error
							    alert(errorThrown);
							  }
							});
                        });
                    }
				}, 
				onSelectRow: function(id){
					/* This section of code fixes the highlight issues, with altRows */
					selMe = id;
					if(id && id!==lastsel){
						var xyz = $("#list").getDataIDs().indexOf(lastsel);
						if (xyz%2 != 0)
						{
						  $('#'+lastsel).addClass('ui-priority-secondary');	
						} 							 

					  $('#list').jqGrid('restoreRow',lastsel);
					  lastsel=id;
					}
					$('#'+id).removeClass('ui-priority-secondary');
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
			jQuery("#list").jqGrid('navGrid','#pager',{edit:false,add:false,del:false,view:false})
			.navSeparatorAdd('#pager')
			.navButtonAdd('#pager', {
				caption:    "Export (CSV)",
				buttonicon: "ui-icon-disk",
				title:      "Export the grid",
				onClickButton:  function() {
					window.location.href = 'admin_baseline_patches_export.cfm?baseline_id=<cfoutput>#fDD#</cfoutput>';
				}
			});
			
			$(window).bind('resize', function() {
				$("#list").setGridWidth($(window).width()-20);
			}).trigger('resize');

		}
	);
	
	function deleteGridRow(){
		var id = jQuery("#list").jqGrid('getGridParam','selrow'); 
		var pName = $('#list').jqGrid('getCell', id, 1);
		if( id != null ) {
			jQuery("#list").jqGrid('delGridRow',id,
			{
				height: 150,
				width: 300,
				msg: "<div align=\"left\" style=\"white-space: normal; font-size:11px;\">Are you sure you want to delete the patch "+pName+", from this baseline?</div>",
				modal: true
			});
		} else {
			alert("Please Select Row to delete!");
		}
	
	}
</script>
<div align="center">
<table id="list" cellpadding="0" cellspacing="0"></table>
<div id="pager" style="text-align:center;font-size:11px;"></div>
</div>
<div id="dialog" title="Detailed Patch Information" style="text-align:left;" class="ui-dialog-titlebar"></div>