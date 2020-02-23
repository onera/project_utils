# Description #
The worflow is based on git so every repository is a git repository.

## Definitions ##
A end-user package is repository which contains functionnalities that will be used by a end-user, not only by developper. It makes sense to install a end-user package for using it directly.
A building-block package is a repository that is primarily there to give some functionnality to a developper


In order to better explain the kind of problems we are dealing with, 
A project is a git repository 

# Context #

API stab
Size / maintainers

A way to 



## Pitfalls ##
1. Not taking into account changes to a submodule
TL;DR: 

Let's say you modify a file "file-1" in a git repository "top-level" and a file "file-2" on one of its submodules "sub-mod-A". Then commiting on the repository "top-level" (with either `git add -A; git commit -m "message"` or `git commit -am "message"` will not take the submodule "file-2" into account, it will not commit with it "file-1" to "top-level", nor create a commit with "file-2" on "sub-mod-A". You first need to commit "file-2" to "sub-mod-A", then commit everything to "top-level", so that "top-level" does two thing: commit "file-1", and commit the new commit of "sub-mod-A" to which its new commit will refer to.




## Open issues ##
With
B -> A
C -> A
C -> B
the project tree is
C/
|--C content
|--external/
   |--A/
   |  |--A content
   |--B/
      |--B content
      |--external
         /* EMPTY */
C/external/B/external is not populated because we already have C/external/A, so C/external/B/external/A would be redundant.
This is what we want. The problem is that when updating A and B accordingly, B should see that its dependency should also be updated. But this is not the case.
From the C perspective, it does not matter since everything is in sync from the top-level working tree perspective.
But if we are to build the updated B separatly, then it will refer to the un-updated A (because we never told the B git that A git has been updated), which is wrong
