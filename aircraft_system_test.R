# Init
source("code/init.R")
source("code/funcs.R")

# Setup model import
csmfileName <- "models/example_model.mdzip"
rootNodeName <- "Instances"
modelFileName <- "com.nomagic.magicdraw.uml_model.model" # cameo XML model
xmlFile <- unz(csmfileName, modelFileName) 
xmlData <- read_xml(xmlFile)

# Read in json files
opus_input <- read_json('example_json/opus_input.json')
opus_response <- read_json('example_json/opus_response.json')

# Set XML look up Strings using an XPATH expression (like regex for trees...)
xmlElement <- "//slot/value[@xmi:type='uml:LiteralReal']"
xpathCall <- paste0(xmlElement)
xpathCall
slots <- xml_find_all(xmlData, xpathCall)

# simple dynamic list dynamic variable list from all instances in csm 
# Remember this should be based on id... just hard coding for now...
slotCount <- as.numeric(length(slots))
slotStep <- seq(from=2, to=slotCount, by=2)
failureRates <- as.numeric(c())

for (i in 1:(slotCount/2))
{
  print(xml_attrs(slots[[slotStep[i]]])[3])
  failureRates[i] <- as.numeric(xml_attrs(slots[[slotStep[i]]])[3])
}

# Now lets loop thought the failRates vector and run the analyses


# Update the json file with the Failure Rate

