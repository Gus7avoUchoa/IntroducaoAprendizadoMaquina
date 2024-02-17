library("RCurl")
library("rjson")

# Accept SSL certificates issued by public Certificate Authorities
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"), ssl.verifypeer = FALSE))

h = basicTextGatherer()
hdr = basicHeaderGatherer()

# Request data goes here
# The example below assumes JSON formatting which may be updated
# depending on the format your endpoint expects.
# More information can be found here:
# https://docs.microsoft.com/azure/machine-learning/how-to-deploy-advanced-entry-script
req = fromJSON('{
  "Inputs": {
    "data": [
      {
        "day": 0,
        "mnth": 0,
        "year": 0,
        "season": 0,
        "holiday": 0,
        "weekday": 0,
        "workingday": 0,
        "weathersit": 0,
        "temp": 0.0,
        "atemp": 0.0,
        "hum": 0.0,
        "windspeed": 0.0
      }
    ]
  },
  "GlobalParameters": 0.0
}')

requestBody = enc2utf8(toJSON(req))
# Replace this with the primary/secondary key or AMLToken for the endpoint
api_key = ""
if (api_key == "" || !is.character(api_key))
{
    stop("A key should be provided to invoke the endpoint")
}
authz_hdr = paste('Bearer', api_key, sep=' ')

h$reset()

# The azureml-model-deployment header will force the request to go to a specific deployment.
# Remove this header to have the request observe the endpoint traffic rules
curlPerform(
    url = "http://b60196ab-f76a-49f5-be1d-4755821d6847.centralus.azurecontainer.io/score",
    httpheader=c('Content-Type' = "application/json", 'Authorization' = authz_hdr),
    postfields=requestBody,
    writefunction = h$update,
    headerfunction = hdr$update,
    verbose = TRUE
)

headers = hdr$value()
httpStatus = headers["status"]
if (httpStatus >= 400)
{
    print(paste("The request failed with status code:", httpStatus, sep=" "))

    # Print the headers - they include the request ID and the timestamp, which are useful for debugging the failure
    print(headers)
}

print("Result:")
result = h$value()
print(result)