#!/usr/bin/env bash

# Name of the file containing subdomains
SUBDOMAINS_FILE="subdomains.txt"

# Name of the output CSV file
OUTPUT_FILE="output.csv"

# List of status codes considered "active"
ACTIVE_CODES="200|301|302|403"

# Check if the subdomains file exists
if [[ ! -f "$SUBDOMAINS_FILE" ]]; then
  echo "File $SUBDOMAINS_FILE not found!"
  exit 1
fi

# Let the user know what we're about to do
echo "Reading subdomains from: $SUBDOMAINS_FILE"
echo "Active status codes: $ACTIVE_CODES"
echo "Creating/overwriting output CSV: $OUTPUT_FILE"

# Write the CSV header
echo "Subdomain,IP Address,Status Code" > "$OUTPUT_FILE"

# Loop through each subdomain in the file
while IFS= read -r domain; do
  # Skip empty lines
  if [[ -z "$domain" ]]; then
    continue
  fi

  # Verbose: let the user know we're checking this domain
  echo "----------------------------------------"
  echo "[*] Checking domain: $domain"

  # Get the IP address using dig
  #   +short outputs only the IPs
  #   head -n1 picks the first IP if multiple exist
  ip_address=$(dig +short "$domain" | head -n1)

  # If dig fails (no IP returned), set to "Unknown"
  if [[ -z "$ip_address" ]]; then
    ip_address="Unknown"
  fi

  echo "[*] Resolved IP: $ip_address"

  # Use curl to fetch the HTTP status code
  # --head        = fetch headers only
  # --silent      = silent mode, no progress meter
  # --location    = follow redirects
  # --max-time 10 = timeout after 10 seconds
  # -w '%{http_code}' = write out the HTTP status code only
  # -o /dev/null  = discard the body
  status_code=$(curl --head --silent --location --max-time 10 "$domain" -o /dev/null -w '%{http_code}')

  echo "[*] HTTP Status Code: $status_code"

  # If the status_code matches one of our ACTIVE_CODES, it goes to CSV
  if [[ "$status_code" =~ ^($ACTIVE_CODES)$ ]]; then
    echo "[+] $domain is ACTIVE"
    echo "$domain,$ip_address,$status_code" >> "$OUTPUT_FILE"
  else
    echo "[-] $domain is INACTIVE"
  fi

done < "$SUBDOMAINS_FILE"

echo "----------------------------------------"
echo "Done. Results have been saved to $OUTPUT_FILE."
