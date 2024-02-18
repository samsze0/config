#!/usr/bin/env bash

# Get the resources usage through the consumption API
# Expect 2 arguments: startDate and endDate
# Format: YYYY-MM-DD
azure_consumption_usage() {
	startDate="$1"
	endDate="$2"

	subscriptionId=$(az account show --query id -o tsv)

	authToken=$(az account get-access-token --resource=https://management.azure.com/ --query accessToken -o tsv)

	# https://learn.microsoft.com/en-us/rest/api/consumption/usage-details/list?view=rest-consumption-2023-05-01&tabs=HTTP
	usage=$(curl -s -X GET -H "Authorization: Bearer $authToken" -H "Content-Type: application/json" "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Consumption/usageDetails?api-version=2023-03-01&$filter=properties/usageEnd ge '${startDate}' AND properties/usageEnd le '${endDate}'")

	echo "${usage}" | gojq -r '.value[]'
}
