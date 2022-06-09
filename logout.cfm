<!---
	When logging out, we want to both log out the current user
	AND make sure that they don't get automatically logged in
	next time.
--->

<!---
	Since our application is using the User ID to keep track
	of login status, let's reset that value.
--->
<cfset SESSION.User.ID = 0 />

<!---
	We also don't want the user to be automatically logged
	in again, so remove the client cookies.
--->
<cfcookie
	name="RememberMe"
	value=""
	expires="now"
	/>


<!--- Now that the user has been logged out, redirect. --->
<cflocation
	url="./"
	addtoken="false"
	/>