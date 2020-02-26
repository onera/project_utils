#!/bin/bash

git_repo_name() {
  basename `git rev-parse --show-toplevel`
}

#
git_scommit() {
  declare -A updates_by_submod
  repo_names=`git submodule foreach --quiet git_repo_name`
  for repo_name in $repo_names
  do
    echo $repo_name
    updates_by_submod[$repo_name]=""
  done
  #echo updates_by_submod
  #echo ${updates_by_submod[$repo_name]}
  for repo_name in $repo_names
  do
  done
    
#   updates_by_submod = {sub_mod : []}
#   for each s : submodule of c
#     if commit updates s to commit_s_i
#       for each t : submodule of c
#         if t contains s as a submodule
#           updates_by_submod[t] += [s,commit_s_i]

#   for each t : submodule of c
#       make a commit on the branch of t used by c
#       that updates the branche according to updates_by_submod[t]

#   for each submod : updates_by_submod.keys()
#     git add submod
#   git commit
}

export -f git_repo_name
export -f git_scommit

git_scommit

##!/bin/bash
#
#git-sfetch() {
#  
#
#}
#export -f git-sfetch

#git config --global status.submoduleSummary true
#git config --global diff.submodule log
#
#git config --global alias.sclone '__git_sclone() { git clone "$@" && git --git-dir=`pwd`/"$@" submodule update --init; }; __git_sclone'
#
#git config --global alias.fetchall '__git_fetchall() { git fetch --recurse-submodules=yes "$@"; }; __git_fetchall'
#
#git config --global alias.spull '__git_spull() { git pull "$@" && git submodule update --init; }; __git_spull'
#
#git config --global alias.spush '__git_spush() { git push --recurse-submodules=on-demand "$@"; }; __git_spush'


##!/bin/bash
#git_repo_name() {
#  basename `git rev-parse --show-toplevel`
#}
#export -f git_repo_name
#
#git submodule foreach git_repo_name


#module load python/3.6.1
#git config --global alias.testaliases '! \
#  python3 -c "
#print(\"lala\")
#  "; \
#  echo lulu \
#'

#git config --global alias.testaliases '!/bin/bash -c "\
#  declare -A updates_by_submod \
#  date >> lili \
#"'






#__git_scommit() {
#  declare -A updates_by_submod
#  for f in 
##   updates_by_submod = {sub_mod : []}
##   for each s : submodule of c
##     if commit updates s to commit_s_i
##       for each t : submodule of c
##         if t contains s as a submodule
##           updates_by_submod[t] += [s,commit_s_i]
#
##   for each t : submodule of c
##       make a commit on the branch of t used by c
##       that updates the branche according to updates_by_submod[t]
#
##   for each submod : updates_by_submod.keys()
##     git add submod
##   git commit
#}
