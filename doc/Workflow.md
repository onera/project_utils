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
