
<!--- Param the form values. --->
<cfparam name="FORM.username" type="string" default="" />
<cfparam name="FORM.password" type="string" default="" />
<cfparam name="FORM.remember_me" type="boolean" default="false" />

<!---
	Check to see if the form has been submitted. Since we
	are trying to keep this low-level, just check to see
	if both values match up.
--->
<cfif (
	(FORM.username EQ "big") AND
	(FORM.password EQ "sexy")
	)>

	<!---
		The user has logged in. This is where we would do the
		authorization; however, since we are just running a very
		simple demo app, simply give the user an ID of "1" to
		signify that they have logged in.
	--->
	<cfset SESSION.User.ID = 1 />


	<!--- Check to see if the user want to be remembered. --->
	<cfif FORM.remember_me>

		<!---
			The user wants their login to be remembered such that
			they do not have to log into the system upon future
			returns. To do this, let's store and obfuscated and
			encrypted verion of their user ID in their cookies.
			We are hiding the value so that it cannot be easily
			tampered with and the user cannot try to login as a
			different user by changing thier cookie value.
		--->

		<!---
			Build the obfuscated value. This will be a list in
			which the user ID is the middle value.
		--->
		<cfset strRememberMe = (
			CreateUUID() & ":" &
			SESSION.User.ID & ":" &
			CreateUUID()
			) />

		<!--- Encrypt the value. --->
		<cfset strRememberMe = Encrypt(
			strRememberMe,
			APPLICATION.EncryptionKey,
			"cfmx_compat",
			"hex"
			) />

		<!--- Store the cookie such that it never expires. --->
		<cfcookie
			name="RememberMe"
			value="#strRememberMe#"
			expires="never"
			/>

	</cfif>


	<!--- Redirect to root. --->
	<cflocation
		url="./"
		addtoken="false"
		/>

</cfif>


<cfoutput>

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html>
	<head>
		<title>Login</title>
	</head>
	<body>

		<h1>
			Application Login
		</h1>

		<form action="#CGI.script_name#" method="post">

			<label>
				Username:
				<input type="text" name="username" size="20" />
			</label>
			<br />
			<br />

			<label>
				Password:
				<input type="password" name="password" size="20" />
			</label>
			<br />
			<br />

			<label>
				<input type="checkbox" name="remember_me" value="1" />
				Remember Me
			</label>
			<br />
			<br />

			<input type="submit" value="Login" />

		</form>

	</body>
	</html>

</cfoutput>