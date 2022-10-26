# Recursive function to build treeStruct (this is the hard part!!!)
csm2Diagram <- function(p) {
  pNodesXML <-
    lapply(p, function(x)
      xml_find_all(xmlData, paste0(xmlElement, "'", x, "'", xmlClass)))
  pNodeChildrenNames <-
    lapply(pNodesXML, function(x)
      toupper(xml_attr(xml_children(x), "name")))
  for (i in 1:length(pNodeChildrenNames)) {
    if (!length(pNodeChildrenNames))
      return() # Check for empty child node set
    lapply(pNodeChildrenNames[[i]], function(x)
      node <-
        FindNode(treeStruct, p[i])$AddChild(
          x,
          cost=0
        ))
  }
  
  p <- unlist(pNodeChildrenNames) # Set children to parents
  csm2Diagram(p) # Recurse until there are no children left (i don't like kids!!)
  
}