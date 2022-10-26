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
xmlFile <- unz(csmfileName,modelFileName) # unzip the model to memory


# Read XML file using xml2 package
# https://blog.rstudio.com/2015/04/21/xml2/
xmlData <- read_xml(xmlFile)

# Set XML look up Strings
xmlElement <- "//packagedElement[@name="
xmlClass <- "and @xmi:type='uml:Class']"

# BUild the root node in the tree
rootNodeXML <- xml_find_all(xmlData, paste0(xmlElement, "'", rootNodeName, "'", xmlClass))
rootNodeChildrenNames <- toupper(xml_attr(xml_children(rootNodeXML), "name"))
treeStruct <- Node$new(rootNodeName)

# Build the first level since its known
lapply(rootNodeChildrenNames, function(x)
  treeStruct$AddChild(x,cost=0))

# Recurse and build the full tree
# Always start with the root node's children names
csm2Diagram(rootNodeChildrenNames)
treeStruct
plot(treeStruct)

# Play with cost attribute
dfCost = ToDataFrameNetwork(treeStruct, "cost")
#dfCost <- edit(dfCost)

#### Other fun... lets look at the XML data
modelData <- xmlParse(xmlData)
modelData

# Get a single list of the blocks
baseModel <- (xml_find_all(xmlData, paste0(xmlElement, "'", rootNodeName, "'", xmlClass)))

## Set XML look up Strings
## Find the new attribute in the model and fetch its owned attribute property
attribute = "xyz"
xmlElement <- "//ownedAttribute[@name="
xmlClass <- "and @xmi:type='uml:Property']"
ownedAttribute <- xml_find_all(xmlData, paste0(xmlElement, "'", attribute, "'", xmlClass))

# Now get the list of attributes for 'ownedAttribute'
xmlElement <- "//defaultValue"
xmlClass <- "[@xmi:type='uml:LiteralReal']"
ownedAttributeAtts <- xml_find_all(ownedAttribute, paste(xmlElement, xmlClass))
ownedAttributeAtts

# Now lets get the value
defaultValue <- xml_attrs(xml_find_all(ownedAttribute, paste(xmlElement, xmlClass)))[[1]][3] # the hard way
defaultValue <- xml_attr(ownedAttributeAtts, "value")
defaultValue

### That's it... in about 45 lines of code we pulled a model out of csm and found a default value for use elsewhere

# -----------------  Put your analysis model here!!!! ########

### Now what??? Lets push a value back into the csm model and save it :)

# Lets change the attribute that we just looked at
xml_attr(ownedAttributeAtts, "value") <- "2"
ownedAttributeAtts


doc <- xml_children(xmlData)[3]
ns <- xml_ns()

