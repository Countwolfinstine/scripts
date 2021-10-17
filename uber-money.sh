#!/bin/bash -e
# Script to find total money spent on uber rides. Need to do some processing on output
for name in {0..30};
do
curl 'https://riders.uber.com/api/getTripsForClient' \
  -H 'authority: riders.uber.com' \
  -H 'sec-ch-ua: "Chromium";v="94", "Google Chrome";v="94", ";Not A Brand";v="99"' \
  -H 'dnt: 1' \
  -H 'content-type: application/json' \
  -H 'x-csrf-token: 1634464182-CLqjMF0_BHoKTX1vKaf333IhcA08ZjCXQMgB31tEYOk' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'accept: */*' \
  -H 'origin: https://riders.uber.com' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-dest: empty' \
  -H 'referer: https://riders.uber.com/trips?offset=0&fromTime&toTime' \
  -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'cookie:<your cookie>:b' \
  --data-raw '{"limit":10,"offset":"'$((10*$name))'","range":{"fromTime":null,"toTime":null},"tenancy":"uber/production"}' \
  --silent \
  --compressed | jq -r '[.data.trips.trips[].clientFare]'
done
