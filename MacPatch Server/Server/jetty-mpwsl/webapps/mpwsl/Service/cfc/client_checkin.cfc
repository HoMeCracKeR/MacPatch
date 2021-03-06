<cfcomponent name="client_checkin" extends="_mpbase">
	<cffunction name="_base" access="public" returntype="any" output="no">
		<cfargument name="data" hint="Encoded Data">
		<cfargument name="type" hint="Encodign Type">
		
		<cfset var l_data = "">
		<cfset var l_result = "0">
		<cfset var l_table = "mp_clients">
		
		<cfset var _res = StructNew()>
		<cfset _res.errorCode = "0">
		<cfset _res.errorMessage = "">
		<cfset _res.result = "false">
		
		<cfif arguments.type EQ "JSON">
			<cfif isJson(arguments.data) EQ false>
				<!--- Log issue --->
				<cfset el = elogit("Not JSON Data.")>
				<cfset _res.errorCode = "1">
				<cfset _res.errorMessage = "Not JSON Data.">
				<cfset _res.result = "false">
				<cfreturn _res>	
			</cfif>			
			<cfset l_data = Deserializejson(arguments.data,"false")>
		
			<cfset xCols = l_data['COLUMNS']>
			<cfset xData = l_data['DATA']>	
			
			<!--- Check for valid lengths --->
			<cfif ArrayLen(xCols) EQ 0>
				<cfset el = elogit("No columns defined, length = 0.")>
				<cfset _res.errorCode = "1">
				<cfset _res.errorMessage = "No columns defined, length = 0.">
				<cfset _res.result = "false">
				<cfreturn _res>	
			</cfif>
			<cfif ArrayLen(xData) EQ 0>
				<cfset el = elogit("No data defined, length = 0.")>
				<cfset _res.errorCode = "1">
				<cfset _res.errorMessage = "No data defined, length = 0.">
				<cfset _res.result = "false">
				<cfreturn _res>
			</cfif>
			
			<!--- Verify Table --->
			<cfset l_tblVerify = #verifyTable(l_table,xCols)#>
			<cfif l_tblVerify.errorCode NEQ 0>
				<cfset el = elogit("Error verifing table #l_table#")>
				<cfset _res.errorCode = "1">
				<cfset _res.errorMessage = "Error verifing table #l_table#">
				<cfset _res.result = "false">
				<cfreturn _res>
			</cfif>
			
			<cfloop array="#l_data['DATA']#" index="iArr">
				<cfif ArrayLen(iArr) EQ ArrayLen(xCols)>
					<cfset l_row = #genRow(xCols,iArr)#>
					<cfif REFIND("[^A-Za-z0-9-]",l_row.cuuid) GTE 1>
						<cfset el = elogit("Error cuuid is not correct format (#l_row.cuuid#)")>
						<cfset l_result = #l_result# + 1>
						<cfbreak> 
					<cfelse>
						<cfset _rres = colExists('cuuid',l_row.cuuid,l_table)>
						<cfif _rres.error NEQ "0">
							<cfset el = elogit("Error[#_rres.error#] checking for column,#_rres.errorMessage#")>
							<cfset l_result = #l_result# + 1>
						<cfelse>
							<cfif _rres.qresult.RecordCount GTE 1>
								<cflog file="_mpbase" type="error" application="no" text="Update">
								<!--- Update --->
								<cfset _ures = rowUpdate(xCols,iArr,'rid',_rres.qresult.rid,l_table)>
								<cfif #_ures.error# NEQ "0">
									<cfset l_result = #l_result# + 1>
								</cfif>
							<cfelse>
								<cflog file="_mpbase" type="error" application="no" text="Insert">
								<!--- Insert --->
								<cfset _ires = rowInsert(xCols,iArr,l_table)>
								<cfif #_ires.error# NEQ "0">
									<cfset l_result = #l_result# + 1>
								</cfif>
							</cfif>
						</cfif>
					</cfif>	
				</cfif>
			</cfloop>
		<cfelse>	
			<cfset _res.errorCode = "1">
			<cfreturn _res>
		</cfif>	
	
		<cfif #l_result# EQ 0>
			<cfset _res.errorCode = "0">
			<cfset _res.errorMessage = "">
			<cfset _res.result = "true">
			<cfreturn _res>
		<cfelse>
			<cfset _res.errorCode = "1">
			<cfset _res.errorMessage = "Check server log for error.">
			<cfset _res.result = "false">
			<cfreturn _res>
		</cfif>
	</cffunction>
	
	<cffunction name="_plist" access="public" returntype="any" output="no">
		<cfargument name="data" hint="Encoded Data">
		<cfargument name="type" hint="Encodign Type">
		
		<cfset var l_data = "">
		<cfset var l_result = "0">
		<cfset var l_table = "mp_clients_plist">
		
		<cfset var _res = StructNew()>
		<cfset _res.errorCode = "0">
		<cfset _res.errorMessage = "">
		<cfset _res.result = false>
		
		<cfif arguments.type EQ "JSON">
			<cfif isJson(arguments.data) EQ false>
				<!--- Log issue --->
				<cfset el = elogit("Not JSON Data.")>
				<cfset _res.errorCode = "1">
				<cfset _res.errorMessage = "Not JSON Data.">
				<cfset _res.result = "false">
				<cfreturn _res>	
			</cfif>			
			<cfset l_data = Deserializejson(arguments.data,"false")>
			
			<cfset xCols = l_data['COLUMNS']>
			<cfset xData = l_data['DATA']>
			<!--- Check for valid lengths --->
			<cfif ArrayLen(xCols) EQ 0>
				<cfset el = elogit("No columns defined, length = 0.")>
				<cfset _res.errorCode = "1">
				<cfset _res.errorMessage = "No columns defined, length = 0.">
				<cfset _res.result = "false">
				<cfreturn _res>	
			</cfif>
			<cfif ArrayLen(xData) EQ 0>
				<cfset el = elogit("No data defined, length = 0.")>
				<cfset _res.errorCode = "1">
				<cfset _res.errorMessage = "No data defined, length = 0.">
				<cfset _res.result = "false">
				<cfreturn _res>
			</cfif>
			
			<!--- Verify Table --->
			<cfset l_tblVerify = #verifyTable(l_table,xCols)#>
			<cfif l_tblVerify.errorCode NEQ 0>
				<cfset el = elogit("Error verifing table #l_table#")>
				<cfset _res.errorCode = "1">
				<cfset _res.errorMessage = "Error verifing table #l_table#">
				<cfset _res.result = "false">
				<cfreturn _res>
			</cfif>
			
			<cfloop array="#l_data['DATA']#" index="iArr">
				<cfif ArrayLen(iArr) EQ ArrayLen(xCols)>
					<cfset l_row = #genRow(xCols,iArr)#>
					<cfif IsDefined("l_row.cuuid")>
						<cfif REFIND("[^A-Za-z0-9-]",l_row.cuuid) GTE 1>
							<cfset el = elogit("Error cuuid is not correct format (#l_row.cuuid#)")>
							<cfset l_result = #l_result# + 1>
							<cfbreak> 
						<cfelse>
							<cfset _rres = colExists('cuuid',l_row.cuuid,l_table)>
							<cfif _rres.error NEQ "0">
								<cfset el = elogit("Error[#_rres.error#] checking for column,#_rres.errorMessage#")>
								<cfset l_result = #l_result# + 1>
							<cfelse>
								<cfif _rres.qresult.RecordCount GTE 1>
									<!--- Update --->
									<cfset _ures = rowUpdate(xCols,iArr,'rid',_rres.qresult.rid,l_table)>
									<cfif #_ures.error# NEQ "0">
										<cfset l_result = #l_result# + 1>
									</cfif>
									<!--- <cfdump var="#_ures#"> --->
								<cfelse>
									<!--- Insert --->
									<cfset _ires = rowInsert(xCols,iArr,l_table)>
									<cfif #_ires.error# NEQ "0">
										<cfset l_result = #l_result# + 1>
									</cfif>
									<!--- <cfdump var="#_ires#"> --->
								</cfif>
							</cfif>
						</cfif>	
					<cfelse>
						<cfset el = elogit("Error: client id was not in data set.")>
						<cfset l_result = #l_result# + 1>	
					</cfif>	
				</cfif>
			</cfloop>							
		<cfelseif arguments.type EQ "XML">
			<!--- Will Fill This In Later--->	
			<cfset _res.errorCode = "0">
			<cfreturn _res>
		<cfelse>	
			<cfset _res.errorCode = "0">
			<cfreturn _res>
		</cfif>	
	
		<cfif #l_result# EQ 0>
			<cfset _res.errorCode = "0">
			<cfset _res.errorMessage = "">
			<cfset _res.result = "true">
			<cfreturn _res>
		<cfelse>
			<cfset _res.errorCode = "1">
			<cfset _res.errorMessage = "Check server log for error.">
			<cfset _res.result = "false">
			<cfreturn _res>
		</cfif>
	</cffunction>
</cfcomponent>	