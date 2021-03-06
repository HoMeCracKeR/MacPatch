<cfsilent>
<cfquery datasource="#session.dbsource#" name="qProdBaselineID" result="iGetProdID">
	Select baseline_id from mp_baseline
	Where state = '1'
</cfquery>
<cfset bID = "#qProdBaselineID.baseline_id#">
<!--- If there are no production records, dont copy it --->
<cfif qProdBaselineID.RecordCount EQ 0>
<style type="text/css">
.back a {color:black;}
</style>
	<h3>Error</h3>
    You can only duplicate a production baseline.
    <br />
    <div class="back" style="margin-top:20px;">
    <a href="admin_baseline_patches.cfm"> << Back to baseline(s)</a>
    </div>
    <cfabort>
</cfif>


<cfquery datasource="#session.dbsource#" name="qBaselineList" result="iGetProd">
	Select 
	p_id as id, baseline_enabled, p_name as name, p_version as version, p_postdate as postdate, p_title as title, p_reboot as reboot, p_type as type, p_suname as suname, p_active as active, p_severity as severity, p_patch_state as patch_state 
	from mp_baseline_patches
	Where baseline_id = <cfqueryparam value="#bID#">
	Order By p_postdate Desc
</cfquery>

<!--- Get Older Start Row --->
<cfoutput query="qBaselineList" maxrows="1">
	<cfset bIDStartDate = "#postdate#">
</cfoutput>

<cfquery datasource="#session.dbsource#" name="qBaselineListNew" result="iGetProd1">
	Select * From combined_patches_view
    Where postdate
    Between #bIDStartDate# AND now()
    AND 
    suname NOT like '%firm%' 
    AND 
    title NOT like '%firm%' 
    AND
    suname NOT like '%NIL%' 
    AND 
    active = 1
    Order By postdate Desc
	
</cfquery>

<cfset myNewQuery = QueryNew("id, baseline_enabled, name, version, postdate, title, reboot, type, suname, active, severity, patch_state")>
<cfset newRow = QueryAddRow(MyNewQuery, #qBaselineList.RecordCount# + #qBaselineListNew.recordCount#)>
<cfset counter = 0>

<!--- set the cells in the query --->
<cfoutput query="qBaselineList">
     <cfset counter = counter + 1>
     <cfset temp = QuerySetCell(myNewQuery, "id", qBaselineList.id, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "baseline_enabled", qBaselineList.baseline_enabled, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "name", qBaselineList.name, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "version", qBaselineList.version, counter)>
	 <cfset temp = QuerySetCell(myNewQuery, "postdate", qBaselineList.postdate, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "title", qBaselineList.title, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "reboot", qBaselineList.reboot, counter)>
	 <cfset temp = QuerySetCell(myNewQuery, "type", qBaselineList.type, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "suname", qBaselineList.suname, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "active", qBaselineList.active, counter)>
	 <cfset temp = QuerySetCell(myNewQuery, "severity", qBaselineList.severity, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "patch_state", qBaselineList.patch_state, counter)>
</cfoutput>
<!--- set the cells in the query --->
<cfoutput query="qBaselineListNew">
     <cfset counter = counter + 1>
     <cfset temp = QuerySetCell(myNewQuery, "id", qBaselineListNew.id, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "baseline_enabled", "0", counter)>
     <cfset temp = QuerySetCell(myNewQuery, "name", qBaselineListNew.name, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "version", qBaselineListNew.version, counter)>
	 <cfset temp = QuerySetCell(myNewQuery, "postdate", qBaselineListNew.postdate, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "title", qBaselineListNew.title, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "reboot", qBaselineListNew.reboot, counter)>
	 <cfset temp = QuerySetCell(myNewQuery, "type", qBaselineListNew.type, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "suname", qBaselineListNew.suname, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "active", qBaselineListNew.active, counter)>
	 <cfset temp = QuerySetCell(myNewQuery, "severity", qBaselineListNew.severity, counter)>
     <cfset temp = QuerySetCell(myNewQuery, "patch_state", qBaselineListNew.patch_state, counter)>
</cfoutput>

<cfset dt = "#LSDateFormat(Now())# #LSTimeFormat(Now())#">
<cfset dts = #DateFormat(Now(), "yyyymmdd")# & #TimeFormat(Now(), "HHmmss")#>
<cfset dtsName = #DateFormat(Now(), "mmmm yyyy")#>
</cfsilent>
<cftry>
<cfoutput query="myNewQuery">
	<cfif checkForExistingPatch(dts,id) EQ false>
        <cfquery datasource="#session.dbsource#" name="qBaseline" result="iResult">
            INSERT INTO mp_baseline_patches (baseline_id, p_id, baseline_enabled, p_name, p_version, p_postdate, p_title, p_reboot, p_type, p_suname, p_active, p_severity, p_patch_state)
            select _latin1 '#dts#' AS `baseline_id`, '#id#', '#baseline_enabled#', '#name#', '#version#', #postdate#, '#title#', '#reboot#', '#type#', '#suname#', '#active#', '#severity#', '#patch_state#'
        </cfquery>
    </cfif>
</cfoutput>
<cfcatch type="Database">
	<!--- Cleanup --->
	<cfquery datasource="#session.dbsource#" name="qBaseline">
    	Delete from mp_baseline_patches
        Where baseline_id = '#dts#'
    </cfquery>
    <h1>Database Error</h1>
    <cfoutput>
    <ul>
        <li><b>Message:</b> #cfcatch.Message#
        <li><b>Native error code:</b> #cfcatch.NativeErrorCode#
        <li><b>SQLState:</b> #cfcatch.SQLState#
        <li><b>Detail:</b> #cfcatch.Detail#
    </ul>
    </cfoutput>
    <cfabort>
</cfcatch>
<cfcatch type="Any">
	<cfoutput>
    <hr>
    <h1>Other Error: #cfcatch.Type#</h1>
    <ul>
        <li><b>Message:</b> #cfcatch.Message#
        <li><b>Detail:</b> #cfcatch.Detail#
    </ul>
    </cfoutput>
    <cfabort>
</cfcatch>
</cftry>

<cftry>
<cfquery datasource="#session.dbsource#" name="qPut">
    Insert Into mp_baseline (baseline_id, name, cdate, mdate, state)
    Values ('#dts#', '#dtsName#', #CreateODBCDateTime(dt)#, #CreateODBCDateTime(dt)#, '2') 
</cfquery>
<cfcatch type="Database">
	<!--- Cleanup --->
	<cfquery datasource="#session.dbsource#" name="qBaseline">
    	Delete from mp_baseline_patches
        Where baseline_id = '#dts#'
    </cfquery>
    <h1>Database Error</h1>
    <cfoutput>
    <ul>
        <li><b>Message:</b> #cfcatch.Message#
        <li><b>Native error code:</b> #cfcatch.NativeErrorCode#
        <li><b>SQLState:</b> #cfcatch.SQLState#
        <li><b>Detail:</b> #cfcatch.Detail#
    </ul>
    </cfoutput>
    <cfabort>
</cfcatch>
<cfcatch type="Any">
	<cfoutput>
    <hr>
    <h1>Other Error: #cfcatch.Type#</h1>
    <ul>
        <li><b>Message:</b> #cfcatch.Message#
        <li><b>Detail:</b> #cfcatch.Detail#
    </ul>
    </cfoutput>
    <cfabort>
</cfcatch>
</cftry>

<cflocation url="#session.cflocFix#/admin/inc/admin_baseline_patches.cfm">

<cffunction name="checkForExistingPatch" access="private" returntype="any">
    <cfargument name="baseline_id" required="no" hint="Field that was editted">
    <cfargument name="patch_id" required="no" hint="Field that was editted">
    
    <cfset var result = false>
    <cfset var strMsgType = "Success">
    <cfset var userdata = "">
    
    <cftry>
        <cfquery datasource="#session.dbsource#" name="qBaseline">
            Select p_id from mp_baseline_patches
            Where baseline_id = <cfqueryparam value="#Arguments.baseline_id#">
            AND p_id = <cfqueryparam value="#Arguments.patch_id#">
        </cfquery>
        <cfif qBaseline.RecordCount EQ 1>        
            <cfset result = true>
        </cfif>
        <cfcatch type="any">
            <cfset strMsgType = "Error">
            <cfset strMsg = "Error occured while setting baseline state. #cfcatch.detail# -- #cfcatch.message#">
        </cfcatch>
    </cftry>
        
    <cfreturn result>
</cffunction>