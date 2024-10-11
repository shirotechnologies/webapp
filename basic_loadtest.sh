#!/bin/bash

# URL of the Load Balancer or Web Server
URL="http://YOUR_LOAD_BALANCER_URL"

# Number of requests to send
NUM_REQUESTS=1000

# Time between requests (in seconds)
DELAY=0.1  # Adjust delay as needed

# Start sending requests
echo "Sending $NUM_REQUESTS requests to $URL..."

for ((i=1; i<=NUM_REQUESTS; i++))
do
  # Send the request and capture the response status
  STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $URL)
  # curl -H "User-Agent: TestTraffic" -o /dev/null -s -w "%{http_code}\n" $URL


  # Print the status and request number
  echo "Request $i: HTTP Status $STATUS"

  # Introduce delay between requests
  sleep $DELAY
done

echo "Completed sending $NUM_REQUESTS requests."

# chmod +x cpu_load_test.sh./cpu_load_test.sh
# ./cpu_load_test.sh

