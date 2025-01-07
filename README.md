Usage
Create or update the file subdomains.txt to contain one subdomain per line.
Save the script above as check_subdomains.sh (or any other file name you prefer).
Make it executable:
chmod +x check_subdomains.sh
Run the script:
./check_subdomains.sh
The script will:
Print verbose messages for each subdomain (domain checked, IP address, status code, active or inactive).
Write only active subdomains (status 200, 301, 302, or 403) to the output.csv file, with columns:
Subdomain
IP Address
Status Code
Open output.csv in Excel or another spreadsheet program to view your results.
