# Organizing multiple interdependent projects #

## Description ##
We present here a way to organize git repositories for developing multiple projects sharing common libraries.

To give an more concrete idea of related libraries and projects, see the example of dependencies between projects on the graph below.

The projects we are talking about are **fine-grained**: a few people working on small libraries. We picture 2/3 people working on the same library at the same time, and 1 person working in several libraries at the same time.

![Dependency graph of connected git repositories](./project_dep_graph.svg)

## Rationale ##
### Requirements ###
1. Versioning done by git. Git has become the de-facto standard and has gained a large consensus as being the right tool for the job.
2. Being able to **easily create a library** as we see fit, or extract a factored piece of code into a library. A well-written library has a well-defined role, a weak coupling with its dependencies, and no coupling at all to the other projects that depend on it. Thus, it is easier to learn, share, maintain and test.
3. **Each library has its own git repository** and can be built by itself. This simplifies testing. Furthermore, it also simplifies learning it and ensures there is no hidden coupling with a "container" repository.
4. Possible to develop collabolatively on several projects and library repositories at the same time.
5. Dependencies between repositories (both library and applications) should be **explicit, but lightweight**. This means that when working on several repositories, we do not want to manually create version numbers for each dependency repository and then tell the dependent repository which version number it should use. This would be perfectly fine at a higher level of granularity, but here we are at a very fine level and versionning should be commit-based: "libA at commit 5f25414f works with libB at commit f16af47b", that's all: we do not ensure any further compatiblity.
6. Possibility to depend on libraries not integrated within this framework of interdependent git repositories. The main driving factor for using git-based dependency management comes from the fact that we want both separate libraries while being able to develop them seamlessly when working on a dependent project. It may feel unpractical to use commit-based dependencies if the library is too big, if developped by another team or when developpers are not working on both at the same time. In this case,  version-based dependencies and release should be the way to go.

### Non-requirements ###
1. API stability. While it is certainly a good idea to ensure API stability and proper versioning for top-level projects, there is a tradeoff with flexibility. Here, we do not want to garantee API stability regarding small-scale libraries as this would hamper the ability to easily split projects into libraries for the sake of ensuring API stability for each new library.
2. Everybody uses master branches. While merging with master should be done as soon as it is possible, staying on the same commit of a dependency and not updating it while doing something else is perfectly acceptable.


## Proposed solution ##
### Folder structure ###
```
project_2/
|-- README.md
|-- LICENSE.md
|-- CMakeLists.txt        # Top-level CMakeLists.txt for compiled project.
|                         # If non-compiled, an installation script should still be there.
|
|-- project_2/            # Code of the library. No include/src separation (not useful). Contains unit tests.
|-- external/             # Library dependencies. They are submodules.
|   |-- app_lib_0/
|   |-- app_lib_1/
|   |-- base_lib/
|   |-- low_level_common/
|
|-- doc/
|-- examples/
|
|-- scripts/              # Additional scripts (building, building tests,
|                         #                deployement machine-specific instructions...)
|-- tests/                # Functionnality/acceptance/performance/deployment tests
|-- build/                # NOT followd by git. Temporary files go there (.o files, ...)
```

### Versionning ###
Use of git with submodules.

### Build system ###
Use of Cmake (lack of a better alternative as of 2020). We at least mandate the use of "modern Cmake" i.e. with a somewhat clean definition of dependencies where each repository has its associated target(s) and they depend on other targets (not on paths and directories).

### Dependency management ###
There are three kinds of dependencies:
* **Project-related** dependencies
* **Other-project**  dependencies (as per requirement 6.)
* **System** dependencies

The latter two are taken care of through Cmake (or other build system tools if not possible) and proper versionning. Regarding project-related dependencies, they must be managed at the commit level but we are not aware of any git-based (or other version-control system) dependency managers. Our compromise is to use git submodules with a disciplined approach. In our example of library dependencies, dependencies form a direct acyclic graph of depth 4. It is complicated:
1. It is 4 levels deep, which mean that dependencies (example: `project_1` depends on `app_lib_0`) have themselves dependencies (`app_lib_0` depends on `base_lib`)
2. It is NOT a tree (e.g. `project_2` depends on `app_lib_0` and `app_lib_1`, and both depend on `base_lib`). Which raises two questions:
    1. What should we do if `app_lib_0` and `app_lib_1` depend on two different versions of `base_lib`?
    2. Should we include the content of `base_lib` twice? If yes, when changing it during the developpement of `project_2`, which one do we change?

#### Chosen solution ####
1. Depending on two versions of the same library is forbidden/not supported.
2. Each repository `r` has all its project-related dependencies `d` taken into account as git submodules placed in `root_of_r/external/d`.
3. Each repository `r` **also has its indirect dependencies `i_d` stored in `root_of_r/external/i_d`**.
4. When working on repository `r`, *only its submodules are checked out*. The submodules of the submodules (indirect dependencies) are already checked out at the first level, and they are supposed to have the same version. Hence there is no need to have them twice.

* [+] The approach is relatively simple because from a working tree perspective, there is only one submodule depth.
* [-] The top-level repository must know all its indirect dependencies. If we were to use a complex layering of many libraries, this could be a problem, but:
    * In reality, the total number of repositories involved is small. If it grows too much, then some *project-related* dependencies should be separated as *other-project* dependencies.
    * In our example, indirect dependencies are also direct dependencies, so it doesn't change anything. Our experience is that we are in this scenario most of the time.
* [+] At this fine-grained "white-box" level, it would not make sense to depend on two versions of the same library. If this is the case at some point, it happened because of an update at one side. So either the discrepancy should be fixed, or the update should be reverted.
* [-] We must configure local git repositories in order to see new commits of `base_lib` for all its dependencies (see section "Git additionnal commands")

## Proposed workflow ##
* Put the contents of `scripts/git/submodule_utils.sh` in your **bash profile**. It will configure git to print more info if a change is made to a submodule. The git aliases `sclone` will also be available.
* **Clone a repostory** with `git sclone <repo-name>`. This will also make sure that submodules required several times in the dependency graph are only cloned once and share the same repository.
* When you **switch to a branch**, use `git scheckout` so that the dependencies' working trees will be updated to the versions referenced by the current branch of main repository.
* When you are **pulling**, use `git spull` to update the dependencies. If you pull with `git pull` or `git fetch + git merge`, the dependencies' working trees are still on older versions. To update them to the versions referenced by the current branch of main repository, use `git submodule update`.
* If you develop only in the main project, then you don't need to care about submodules for anything else.
* If you made a **change to a submodule** `base_lib` (located in `<main-repo-path>/external/base_lib`) then
    * You should see it with e.g. `cd <main-repo-path>; git status`.
    * You can commit the change in the submodule by going into its folder (`cd <main-repo-path>/external/base_lib`)
    * When in the submodule folder, git does as if it were a regular git repository. 
    * Be aware that, by default, submodules are on a "detached head" state (see `git status`) which mean you are not on a branch (not even master).
        * If you are to make commits, you should go on a branch.
        * You can ask git for the branch of the current commit with `git rev-parse HEAD | xargs git name-rev`.
        * Say the branch is `master`, you can go on it by `git checkout master`.
    * You can then commit your change (`git add ...; git commit ...`).
    * If `base_lib` is also a dependency of another submodule `app_lib_0`, then changes to `base_lib` will also be reported as changes to `app_lib_0`. After having commited the changes to the `base_lib`, you can commit the update of `base_lib` into `app_lib_0`, and then the update of `base_lib` and `app_lib_0` into the main repository.
* When you are **pushing** a repository, if you changed one of its submodules (new commits), then make sure to also push it.
* TODO create git aliases to
   * automate commits of just submodule dependency updates 
   * push new submodule commits

**Updating submodules**
* Say that we are working on `project_2`. If submodule `base_lib` has been changed outside of `project_2` (e.g. through developpers working on `project_1`):
    * **Most of the time, it doesn't matter**. Don't do anything special regarding `baselib`. Use `git spull` to get a coherent, new version of `project_2`. It will **not** pull the latest `project_2` changes created by the unrelated `project_1`. This is the correct behavior, because it ensures that a particular commit of `project_2` is not silently affected by new versions of its dependencies (here, by a new version of `base_lib` developped in a different context than `project_2`). 
    * If you want to update the dependency, go to `external/base_lib` and pull. Then when you come back to the main folder project, you should see that `base_lib` has an updated version. Commit the change. You may have to commit changes to other submodules that depend on `base_lib` (e.g. `app_lib_0`) before that.

## Git additionnal commands ##
### sclone #
The following scenario does not work out of the box:
 * working on `project_2`
 * we modify `base_lib`, submodule of `project_2`, then commit the change
 * then update the `base_lib` commit on `project_2`

  We have violated the first rule because now `app_lib_0` points to the old commit of `base_lib`, but `project_2` points to the new one. In fact, the `app_lib_0` submodule working directory of `project_2` is built and uses the *new* sources of `base_lib`. In order to see in `app_lib_0` that the dependency `base_lib` has been updated, we must configure the working trees so that the one corresponding to `base_lib` is shared between `app_lib_0` and `project_2`. The `git sclone` alias defined in `scripts/git/submodule_utils.sh` does just that.


