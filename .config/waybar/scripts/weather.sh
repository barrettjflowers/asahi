#!/bin/bash
curl -s -m 10 "https://api.open-meteo.com/v1/forecast?latitude=39.7684&longitude=-86.1581&current=temperature_2m&temperature_unit=fahrenheit" | jq -r '.current.temperature_2m | "\(.)°F"'
