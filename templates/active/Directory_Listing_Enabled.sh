AUTHOR='@xer0dayz'
VULN_NAME='Directory Listing Enabled'
URI='/'
METHOD='GET'
MATCH="<title>Index\ of|To\ Parent\ Directory"
SEVERITY='P4 - LOW'
CURL_OPTS="--user-agent '' -s -L --insecure"
SECONDARY_COMMANDS=''
GREP_OPTIONS='-i'