# Description #
We present here a way to organize git repositories for developping multiple projects sharing common libraries.
To give an more concrete idea of related libraries and projects, here is an example of dependencies between projects ![dependency graph](./project_dep_graph.svg).
The projects we are talking about are *fine-grained*: a few peoples working on small libraries. We envision 2/3 people working on the same library at the same time, and 1 person working in several libraries at the same time.


# Rationale #
## Requirements ##
1. Versionning done by git. Git has become the de-facto standard and has gained a large consensus as being the right tool for the job.
2. Be able to easily create a library as we see fit, or extract a factored piece of code into a library. A well-written library has a well-defined role, a weak coupling with its dependencies, and no coupling at all to the other project that depend on it. Thus it is easier to learn, share, maintain and test.
3. Each library has its own git repository and can be built by itself. It simplifies testing. Furthermore, it also simplify learning it and ensures their is no hidden coupling with a "container" repository.
4. Possible to develop collabolatively on several project and library repositories at the same time.
5. Dependencies between repositories (both library and applications) should be *explicit, but lightweight*. It means that when working on several repositories, we do not want to manually create version numbers for each dependency repository, and then tell the dependent repository which version number it should use. It would be perfectly fine at a higher level of granularity, but here we are at a very fine level and versionning should be commit-based: "libA at commit 5f25414f works with libB at commit f16af47b", that's all: we do not ensure any further compatiblity.
6. Possibility to depend on libraries not integrated within this framework of interdependent git repositories. The main driving factor for using git-based dependency management comes from the fact that we want both separate libraries and develop them seamlessly when working on a dependent project. It may feels unpractical to use commit-based dependencies if the library is too big, or developped by another team, or developpers are not working on both at the same time. In this case it, version-based dependencies and release should be the way to go.

## Non-requirements ##
1. API stability.
  While it is certainly a good idea to ensure API stability and proper versioning for top-level projects, there is a tradeoff with flexibility. Here, we do not want to garantee API stability regarding small-scale libraries. Because then it would empede the ability to easily split projects into libraries, on behalf that a new library should ensure API stability.
2. Everybody uses master branches.
  While merging with master should be done as soon as possible, staying on the same commit of a dependency and not updating it while doing something else is perfectly acceptable.


# Proposed solution #
## Folder structure ##
```
libA/
|-- README.md
|-- LICENSE.md
|-- CMakeLists.txt # Top-level CMakeLists.txt for compiled project.
|                  # If non-compiled, an installation script should still be there.
|
|-- libA/          # Code of the library. No include/src separation (to useful). Contains unit tests.
|-- external/      # Library dependencies. They are submodules.
|   |-- libB/
|   |-- libC/
|
|-- doc/
|-- examples/
|
|-- scripts/       # Additional scripts (building, building tests, deployement machine-specific instructions...)
|-- tests/         # Functionnality/acceptance/performance/deployment tests
|-- build/         # NOT followd by git. Temporary files go there (.o files, ...)
```

## Versionning ##
Use of git.

## Build system ##
Use of Cmake (lack of a better alternative as of 2020). We at least mandate the use of "modern Cmake" i.e. with a somewhat clean definition of dependencies where each repository has its associated target(s) and they depend on other targets (not on paths and directories).

## Dependency management ##
There are three kinds of dependencies:
* Project-related dependencies
* Other-project dependencies (as per requirement 6.)
* System dependencies
The latter two are taken care of through Cmake and proper versionning. Regarding project-related dependencies, they must be managed at the commit level but we are not aware of git-based (or other version-control system) dependency managers. Our compromise is to use git submodules with a diciplined approach. In our ![example of library dependencies](./project_dep_graph.svg), dependencies form a direct acyclic graph of depth 4. It is complicated:
1. It is 4 levels deep, which mean that dependencies (example: `project_1` depends on `app_lib_0`) have themselves dependencies (`app_lib_0` depends on `base_lib`)
2. It is NOT a tree (example `project_2` depends on `app_lib_0` and `app_lib_1`, and both depend on `base_lib`). Which raises two questions:
    1. What should we do if `app_lib_0` and `app_lib_1` depend on two different versions of `base_lib`?
    2. Should we include the content of `base_lib` twice? If yes, when changing it during the developpement of `project_2`, which one do we change?

The approach is the following:
1. Depending on two versions of the same library is forbidden/not supported.
2. Each repository `r` has all its project-related dependencies `d` taken into account as git submodules placed in `root_of_r/external/d`
3. Each repository `r` also has its indirect dependencies `i_d` stored in `root_of_r/external/i_d`
4. When working on repository `r`, *only its submodules are checked out*. The submodules of the submodules (indirect dependencies) are already checked out at the first level, and they are supposed to have the same version. Hence there is no need to have them twice.

+ The approach is relatively simple because there is only one submodule depth.
- The top-level repository must know of all its indirect dependencies. If we where to use a complex layering of many library, this could be a problem, but
    * In reality, the total number of repository involved is small. If it grows too much, then some project-related dependencies should be separated as other-project dependencies.
    * In our example, indirect dependencies are also direct dependencies, so it doesn't change anything. Our experience is that we are in this scenario most of the time.
+ At this fine-grained "white-box" level, it would not make sense to depend on two versions of the same library. If this is the case at some point, it happened because of an update at one side. So either the discrepancy should be fixed, or the update should be reverted.
- The following scenario does not work out of the box:
    * working on `project_2`
    * we modify `base_lib`, its submodule, then commit it on `base_lib`
    * then update the `base_lib` commit on `project_2`
  We have violated the first rule because now `app_lib_0` points to the old commit of `base_lib`, but `project_2` points to the new one. In fact, the `app_lib_0` submodule working directory of `project_2` is built and uses the *new* sources of `base_lib`. In order to see in `app_lib_0` that the dependency `base_lib` has been updated, we must configure the working trees so that the one of `base_lib` is shared between `app_lib_0` and `project_2`. The `git sclone` alias defined in `scripts/git/submodule_utils.sh` does that.


## Proposed workflow ##
Multi-project structure example ![dependency graph](./project_dep_graph.svg). Say that we are working on `project_2`

* Put `scripts/git/submodule_utils.sh` in your bash profile. It will configure git to print more info if a change is made to a submodule. The git aliases `sclone` `fetchall` `spull` `spush` will also be available.
* Clone a repostory with `git sclone <repo-name>`. It will also make sure that submodules required several times in the dependency graph are only cloned once and share the same repository.
* When you are pulling, use `git spull` to update the dependencies.
* If you pull with `git pull` or `git fetch + git merge`, and the dependencies have changed you will likely git a compilation error, since the dependencies working trees are still on older versions. Use `git spull` to correct this behavior.
* If you develop only in the main project, then you only care about submodules when pulling.
* If you made a change to a submodule `base_lib` (located in `<main-repo-path>/external/base_lib`) then you should see it with `git status`. You sould commit the submodule change, then the change into the main repository
    * You can commit the change in the submodule by going into its folder (`cd <main-repo-path>/external/base_lib; git add ...; git commit`).
    * When in the submodule folder, git does as if it were a regular git repository. 
    * If `base_lib` is also a dependency of another submodule `app_lib_0`, then changes to `base_lib` will also be reported as changes to `app_lib_0`. After having commited the changes to the `base_lib`, you can commit the update of `base_lib` into `app_lib_0`, and then the update of `base_lib` and `app_lib_0` into the main repository.
* During a push, if you changed a submodule, you should make sure to also push it. Use `git spush` in the main repository, it will take care of that.
* If submodule `base_lib` has been changed outside of the `project_2` (e.g. through developpers working on `project_1`):
    * Most of the times, you don't care. Don't do anything special regarding `baselib`. Use `git spull` to get a coherent, new version of `project_2`.
    * If you want to update the dependency, go to `external/base_lib` and pull. Then if you come back to the main folder project, you should see that `base_lib` has an updated version. Commit the change. Before that, you may have to do commit the change to other submodules that depend on `base_lib` (e.g. `app_lib_0).
* If you want to see all potential submodules to update, use `git fetchall` to download the changes.


