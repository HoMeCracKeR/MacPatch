<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<cfquery datasource="#session.dbsource#" name="qGet">
    SELECT	*
    FROM	mp_clients_view
    Where cuuid = <cfqueryparam value="#url.cuuid#">
</cfquery> 

<html> 
<head> 
    <title><cfoutput query="qGet">#hostname# Info...</cfoutput></title> 
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> 
    
    <link rel="stylesheet" href="/admin/js/tablesorter/themes/blue/style.css" type="text/css"/>
    <link rel="stylesheet" type="text/css" media="screen" href="/admin/js/ui/Aristo-jQuery-UI-Theme/css/Aristo/Aristo.css" />

    
<script type="text/javascript" src="/admin/js/jquery-latest.js"></script>
	<script type="text/javascript" src="/admin/js/jquery-ui-latest.js"></script>
    <script type="text/javascript" src="/admin/js/tablesorter/jquery.tablesorter.js"></script>
    <script type="text/javascript" src="/admin/js/tablesorter/pager/jquery.tablesorter.pager.js"></script>
    
    <script type="text/javascript">	
        $(function() {
            $("#invTable").tablesorter({
                widgets: ['zebra'] 
            });
            $("#invTable2").tablesorter({
            });
        });	
    </script>
    
    <style type="text/css">
    <!--
    body {
        background-color:#fff;
    }
   
    table#invTable2 th { font-size:12px;
        text-align:left;
        background-color:#EDEDED;
        padding-top:4px;
        padding-left:10px;
        padding-bottom:4px;
        padding-right:20;
    }
    table#invTable2 td { 
        font-size:11px;
        text-align:left;
        background-color:white;
        padding-top:4px;
        padding-left:10px;
        padding-bottom:4px;
        padding-right:20;
    }

    table {border:thin;}
    table#invTable2 {border-spacing:1px; background-color:black;}
    -->
    </style>
<cfsilent>
	<cfif url.type EQ "swinstalls">
        <cfquery datasource="#session.dbsource#" name="qGetColumns" cachedwithin="#CreateTimeSpan(0,0,0,5)#">
            Select mpsi.cuuid, mpsi.result, mpsi.resultString as Result_String, mpsi.cDate, mpsi.action, mps.sName as Package, mps.sVersion as Package_Version, mpst.name as Task_Name, mpst.sw_task_type as Task_Type
            From mp_software_installs mpsi
            Left Join mp_software mps on mpsi.suuid = mps.suuid
            Left Join mp_software_task mpst on mpsi.tuuid = mpst.tuuid
            Where 1 = 1
            Limit 1
        </cfquery>	
    <cfelse>
        <cfquery datasource="#session.dbsource#" name="qGetColumns" cachedwithin="#CreateTimeSpan(0,0,0,5)#">
            Select * From
            <cfif url.type EQ "systemoverview">
            mpi_SPSystemOverview
            </cfif>
            <cfif url.type EQ "applications">
            mpi_SPApplications
            </cfif>
            <cfif url.type EQ "applicationusage">
            mpi_AppUsage
            </cfif>
            <cfif url.type EQ "hardwareoverview">
            mpi_SPHardwareOverview
            </cfif>
            <cfif url.type EQ "networkoverview">
            mpi_SPNetwork
            </cfif>
            <cfif url.type EQ "directoryoverview">
            mpi_DirectoryServices
            </cfif>
            <cfif url.type EQ "frameworks">
            mpi_SPFrameworks
            </cfif>
            <cfif url.type EQ "internetplugins">
            mpi_InternetPlugins
            </cfif>
            <cfif url.type EQ "clienttasks">
            mpi_ClientTasks
            </cfif>
            <cfif url.type EQ "diskinfo">
            mpi_DiskInfo
            </cfif>
            Where 1 = 1
            Limit 1
        </cfquery> 	
    </cfif>
    
    <cfset _cols = qGetColumns.columnlist>
    <cfset _cols = ListDeleteAt(_cols,ListContainsNoCase(_cols,'rid',","),",")>	
    <cfset _cols = ListDeleteAt(_cols,ListContainsNoCase(_cols,'cuuid',","),",")>
    <cfset _cols = ListDeleteAt(_cols,ListContainsNoCase(_cols,'cdateint',","),",")>
    <cfset _cols = ListDeleteAt(_cols,ListContainsNoCase(_cols,'dateint',","),",")>
    <cfif ListContainsNoCase(_cols,'mdate',",") AND ListContainsNoCase(_cols,'date',",")>
    <cfset _cols = ListDeleteAt(_cols,ListContainsNoCase(_cols,'date',","),",")>	
    </cfif>
    <cfset _colsRaw = _cols>
    <cfset _cols = "`"&#Replace(_cols,",","`,`","All")#&"`">
    <cfif url.type EQ "swinstalls">
        <cfquery datasource="#session.dbsource#" name="qGetData" cachedwithin="#CreateTimeSpan(0,0,0,2)#">
            Select mpsi.cuuid, mpsi.result, mpsi.resultString, mpsi.cDate, mpsi.action, mps.sName as Package, mps.sVersion as Package_Version, mpst.name as Task_Name, mpst.sw_task_type as Task_Type
            From mp_software_installs mpsi
            Left Join mp_software mps on mpsi.suuid = mps.suuid
            Left Join mp_software_task mpst on mpsi.tuuid = mpst.tuuid
            Where cuuid = <cfqueryparam value="#url.cuuid#">
        </cfquery>	
    <cfelse>
        <cfquery datasource="#session.dbsource#" name="qGetData" cachedwithin="#CreateTimeSpan(0,0,0,2)#"> 
            Select #PreserveSingleQuotes(_cols)#
            <cfif url.type EQ "systemoverview">
            from mpi_SPSystemOverview
            </cfif>
            <cfif url.type EQ "applications">
            from mpi_SPApplications
            </cfif>
            <cfif url.type EQ "applicationusage">
            from mpi_AppUsage
            </cfif>
            <cfif url.type EQ "hardwareoverview">
            from mpi_SPHardwareOverview
            </cfif>
            <cfif url.type EQ "networkoverview">
            from mpi_SPNetwork
            </cfif>
            <cfif url.type EQ "directoryoverview">
            from mpi_DirectoryServices
            </cfif>
            <cfif url.type EQ "frameworks">
            from mpi_SPFrameworks
            </cfif>
            <cfif url.type EQ "internetplugins">
            from mpi_InternetPlugins
            </cfif>
            <cfif url.type EQ "clienttasks">
            from mpi_ClientTasks
            </cfif>
            <cfif url.type EQ "diskinfo">
            from mpi_DiskInfo
            </cfif>
            Where cuuid = <cfqueryparam value="#url.cuuid#">
        </cfquery>
    </cfif>	
</cfsilent>
</head>
<body>
	<img src="/admin/images/icons/table_save.png" title="Export to CSV" align="left" onClick="window.open('client_group_inv_details_export.cfm?type=<cfoutput>#url.type#</cfoutput>&cuuid=<cfoutput>#url.cuuid#</cfoutput>','Export2CSV');"><div style="text-align:left;"> Export (CSV)</div><br />
<cfif qGetData.recordcount GT 1>
	<cfoutput>
        <div style="text-align:left;font-size:12px;">
            #qGetData.recordcount# record(s) found.<br>
        <div>
        <cfset _cols = #ArrayToList(qGetData.getColumnNames())#>
        <table class="tablesorter" id="invTable" border="0" cellpadding="0" cellspacing="1" width="100%">
            <thead>
                <tr>
                    <cfloop list="#_cols#" index="col">
                    <th>#cleanText(col)#</th>
                    </cfloop>
                </tr>
            </thead>
            <tbody>
            <cfloop query="qGetData">
            <tr>
                <cfloop list="#_cols#" index="col">
                <td>#qGetData[col][currentrow]#</td>
                </cfloop>
            </tr>
            </cfloop>
            </tbody>
        </table>
    </cfoutput>
<cfelse>
    <table id="invTable2">
    <cfoutput query="qGetData">
    <cfloop index="col" list="#_colsRaw#">
    <tr>
    <th>#ucase(cleanText(col))#</th><td>#qGetData[col][qGetData.currentrow]#</td>
    </tr>
    </cfloop>
    </cfoutput>
    </table>
</cfif>
</body>
</html>

<cffunction name="cleanText" access="public" returntype="any">
	<cfargument name="text" required="yes">
	<cfset htmlClean1 = Replace(text,"mpa_","","All")>
	<cfset htmlClean2 = Replace(htmlClean1,"_"," ","All")>
    <cfreturn htmlClean2>
</cffunction>
