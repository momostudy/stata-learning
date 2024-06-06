version 16.0
mata:

real matrix blncdtree(real scalar nnode)
{
/*
  Return a balanced search tree with n nnode nodes,
  defined as a nnodes*2 matrix temporarily named tree,
  such that tree[i,1] is the left daughter row index of row i
  and tree[i,2] is the right daughter index of row i.
  nnode is the number of nodes.
*! Author: Roger Newson
*! Date: 11 August 2005
*/
real matrix tree

/*
  Conformability checks
*/
if(nnode<0) {
  exit(error(3200))
}

/*
  Create and return tree using _blncdtree
*/
tree=J(trunc(nnode),2,0)
if(rows(tree)>=1) {
  _blncdtree(tree,1,rows(tree))
}
return(tree)

}
end
