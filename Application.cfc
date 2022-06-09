<cfcomponent
	output="false"
	hint="I define the application and root-level event handlers.">

	<!--- Define application settings. --->
	<cfset THIS.Name = "RememberMeDemo" />
	<cfset THIS.ApplicationTimeout = CreateTimeSpan( 0, 0, 5, 0 ) />
	<cfset THIS.SessionManagement = true />
	<cfset THIS.SessionTimeout = CreateTimeSpan( 0, 0, 0, 20 ) />
	<cfset THIS.SetClientCookies = true />

	<!--- Define the request settings. --->
	<cfsetting
		showdebugoutput="false"
		requesttimeout="10"
		/>


	<cffunction
		name="OnApplicationStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="I run when the application boots up. If I return false, the application initialization will hault.">

		<!---
			Let's create an encryption key that will be used to
			encrypt and decrypt values throughout the system.
		--->
		<cfset APPLICATION.EncryptionKey = "S3xy8run3tt3s" />

		<cfreturn true />
	</cffunction>


	<cffunction
		name="OnSessionStart"
		access="public"
		returntype="void"
		output="false"
		hint="I run when a session boots up.">

		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />

		<!---
			Store the CF id and token. We are about to clear the
			session scope for intialization and want to make sure
			we don't lose our auto-generated tokens.
		--->
		<cfset LOCAL.CFID = SESSION.CFID />
		<cfset LOCAL.CFTOKEN = SESSION.CFTOKEN />

		<!--- Clear the session. --->
		<cfset StructClear( SESSION ) />

		<!---
			Replace the id and token so that the ColdFusion
			application knows who we are.
		--->
		<cfset SESSION.CFID = LOCAL.CFID />
		<cfset SESSION.CFTOKEN = LOCAL.CFTOKEN />


		<!--- Create the default user. --->
		<cfset SESSION.User = {
			ID = 0,
			DateCreated = Now()
			} />


		<!---
			Now that we are starting a new session, let's check
			to see if this user want to be automatically logged
			in using their cookies.
			Since we don't know if the user has this "remember me"
			cookie in place, I would normally say let's param it
			and then use it. However, since this process involves
			decryption which might throw an error, I say, let's
			just wrap the whole thing in a TRY / CATCH and that
			way we don't have to worry about the multiple checks.
		--->
		<cftry>

			<!--- Decrypt out remember me cookie. --->
			<cfset LOCAL.RememberMe = Decrypt(
				COOKIE.RememberMe,
				APPLICATION.EncryptionKey,
				"cfmx_compat",
				"hex"
				) />

			<!---
				For security purposes, we tried to obfuscate the
				way the ID was stored. We wrapped it in the middle
				of list. Extract it from the list.
			--->
			<cfset LOCAL.RememberMe = ListGetAt(
				LOCAL.RememberMe,
				2,
				":"
				) />

			<!---
				Check to make sure this value is numeric,
				otherwise, it was not a valid value.
			--->
			<cfif IsNumeric( LOCAL.RememberMe )>

				<!---
					We have successfully retreived the "remember
					me" ID from the user's cookie. Now, store
					that ID into the session as that is how we
					are tracking the logged-in status.
				--->
				<cfset SESSION.User.ID = LOCAL.RememberMe />

			</cfif>

			<!--- Catch any errors. --->
			<cfcatch>
				<!---
					There was either no remember me cookie, or
					the cookie was not valid for decryption. Let
					the user proceed as NOT LOGGED IN.
				--->
			</cfcatch>
		</cftry>

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction
		name="OnRequestStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="I perform pre page processing. If I return false, I hault the rest of the page from processing.">

		<!--- Check for initialization. --->
		<cfif StructKeyExists( URL, "reset" )>

			<!--- Reset application and session. --->
			<cfset THIS.OnApplicationStart() />
			<cfset THIS.OnSessionStart() />

		</cfif>

		<!--- Return out. --->
		<cfreturn true />
	</cffunction>


	<cffunction
		name="OnRequest"
		access="public"
		returntype="void"
		output="true"
		hint="I execute the primary template.">

		<!--- Define arguments. --->
		<cfargument
			name="Page"
			type="string"
			required="true"
			hint="The page template requested by the user."
			/>

		<!---
			We are going to be using the user's ID as a the way
			to check for logged-in status. Check to see if the
			user is logged in based on the ID. If they are, then
			include the requested page; if they are not, then
			force the login page.
		--->
		<cfif SESSION.User.ID>

			<!--- User logged in. Allow page request. --->
			<cfinclude template="#ARGUMENTS.Page#" />

		<cfelse>

			<!---
				User is not logged in - include the login page
				regardless of what was requested.
			--->
			<cfinclude template="login.cfm" />

		</cfif>

		<!--- Return out. --->
		<cfreturn />
	</cffunction>

</cfcomponent>