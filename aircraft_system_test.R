# Init
source("code/init.R")
source("code/funcs.R")

# Setup model import
csmfileName <- "models/example_model.mdzip"
rootNodeName <- "Instances"
modelFileName <- "com.nomagic.magicdraw.uml_model.model" # cameo XML model
xmlFile <- unz(csmfileName, modelFileName) 
xmlData <- read_xml(xmlFile)

# Set XML look up Strings using an XPATH expression (like regex for trees...)
xmlElement <- "//slot"
#xmlClass <- "xmi:type='uml:Slot]"
xpathCall <- xmlElement #paste0(xmlElement, xmlElement)
xpathCall

# Build the root node in the tree
slotValues <- xml_find_all(xmlData, xpathCall)

# Set XML look up Strings using an XPATH expression (like regex for trees...)
xmlElement <- "//slot"
#xmlClass <- "xmi:type='uml:Slot]"
xpathCall <- xmlElement #paste0(xmlElement, xmlElement)
xpathCall
