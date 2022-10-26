##########################################################################
## Project: csm2r
## Script purpose: extract data structure from magicdraw bdd
##                 performs aggregation of attributes (mass only for now)
## Date: 10/25/22 (last update: 10/25/22)
## Author: J.K. DeHart
##########################################################################
# About the data.tree library
# https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html
#
##########################################################################
# TODO:
##########################################################################
# NOTES: 
##########################################################################

# Init
source("code/init.R")
source("code/funcs.R")

# Setup model import
csmfileName <- "models/example_model.mdzip"
rootNodeName <- "MISSILE ASSY"
modelFileName <- "com.nomagic.magicdraw.uml_model.model" # cameo XML model
xmlFile <- unz(csmfileName, modelFileName) # unzip the model to memory

# Read XML file using xml2 package
# https://blog.rstudio.com/2015/04/21/xml2/
xmlData <- read_xml(xmlFile)

# Lets look at the XML data
modelData <- xmlParse(xmlData)
modelData

# Set XML look up Strings using an XPATH expression (like regex for trees...)
xmlElement <- "//packagedElement[@name="
xmlClass <- "and @xmi:type='uml:Class']"
xpathCall <- paste0(xmlElement, "'", rootNodeName, "'", xmlClass)
xpathCall

# BUild the root node in the tree
rootNodeXML <- xml_find_all(xmlData, xpathCall)
rootNodeChildrenNames <- toupper(xml_attr(xml_children(rootNodeXML), "name"))
treeStruct <- Node$new(rootNodeName)
treeStruct

# Build the first level since its known and add custom attributes
lapply(rootNodeChildrenNames, function(x)
  treeStruct$AddChild(x, cost=0))
treeStruct

# Recurse and build the full tree
# Always start with the root node's children names
csm2Diagram(rootNodeChildrenNames)
print(treeStruct, "cost")
plot(treeStruct)

# Play with cost attribute (unremark to present...)
dfCost = ToDataFrameNetwork(treeStruct, "cost")
dfCost <- edit(dfCost)

# Convert back to a network after the 
treeStruct <- FromDataFrameNetwork(dfCost)
print(treeStruct, "cost")

# Get running total of costs based on nodes and children values.
treeStruct$Do(function(x) x$total <- ifelse(is.null(x$cost), 0, x$cost) + sum(Get(x$children, "total")), traversal = "post-order")
print(treeStruct, "cost", "total")


####
#------- Lets fetch some data from the XML
####

# Fetch a list of the first stage blocks
baseModel <- (xml_find_all(xmlData, paste0(xmlElement, "'", rootNodeName, "'", xmlClass)))
baseModel # go and review in the view model

# -----------------  Put your analysis model here!!!! ########

## Set XML look up Strings
## Find the new attribute in the model and update the value
attribute = "xyz"
xmlElement <- "//ownedAttribute[@name="
xmlClass <- "and @xmi:type='uml:Property']/defaultValue"
xpathCall <- paste0(xmlElement, "'", attribute, "'", xmlClass)
xpathCall

# Fetch that defaultValue for the noted attribute item
xyz_defaultValue <- as.numeric(
  xml_attr(xml_find_all(xmlData, xpathCall), "value")
  )

# -----------------  Put your analysis model here!!!!
# in this case lets just multiply by 2
xyz_newValue <- as.numeric(xyz_defaultValue) / 2

# Now lets set the attributes defaultValue in the model based on the results of the analysis
xml_set_attr(xml_find_all(xmlData, xpathCall), "value", xyz_newValue)

# Finally lets save the xmlData model back to disk
write_xml(xmlData, modelFileName)
zip(csmfileName, files=modelFileName, flags="-uv") # replace with updated model

### That's it... in about 50 working lines of code (including the recursive func) we:
# 1) pulled an entire model out of csm
# 2) performed some foreign attribute work (cost summation)
# 3) found a specific attribute and modified it value
# 4) and finally saved the model back to disk
