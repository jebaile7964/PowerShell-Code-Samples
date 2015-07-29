# Active Directory Script Samples

#### Get-UsersNotLoggedIn

Gets a list of all users in a specific OU that have never logged in to a terminal server.  It's done first by importing
a PSsession from a domain controller to the terminal server in question, and then any users who have never logged in to
the server are displayed as output.

This is useful for licensing, especially in a tenanted server environment.
