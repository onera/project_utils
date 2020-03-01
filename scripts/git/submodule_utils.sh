# __git_sclone: clones a repository with submodules
# Precondition: if the submodules have submodules,
#               they must also be direct submodules of the repository # TODO: check it is the case
#               and everybody must point to the same commit of the submodules # TODO: check it is the case
# 1. clones a repository
# 2. init and updates direct submodules
# 3. for each submodules,
#        init its submodules
#        make their working directory point to the one already present
__git_config_submod_wd() {
  root_path=$1
  git submodule init
  submod_conf_paths=`git config --file .gitmodules --name-only --get-regexp path`
  for submod_conf_path in $submod_conf_paths; do
    if [[ $submod_conf_path =~ submodule\.(.*)\.path ]]; then
    submod_path=${BASH_REMATCH[1]}
    echo gitdir: $root_path/.git/modules/$submod_path > $submod_path/.git # TODO $root_path is absolute -> use relative path (here: breaks if repo is moved on the filesystem)
  fi
  done
}
export -f __git_config_submod_wd

__git_sclone() { 
  # clone without submodules
  clone_res="$(LANG=en_US git clone $@ 2>&1)"
  echo $clone_res
  if (($? != 0)); then
    echo "command \"git clone $@\" failed"; exit 1
  fi

  # get the name of the folder cloned
  if [[ $clone_res =~ .*Cloning\ into\ \'(.*)\'.* ]]; then
    repository_name=${BASH_REMATCH[1]}
  else
    echo "in __git_sclone: unable to parse output of \"git clone $@\""; exit 1
  fi

  # update submodules and create git "symlinks" from subsubmodules to main repository submodules
  (cd $repository_name
    git submodule update --init
    if (($? != 0)); then
      echo "command \"git submodule update --init\" failed"; exit 1
    fi

    git submodule foreach '__git_config_submod_wd $toplevel'
  )

  #git rev-parse HEAD | xargs git name-rev # name of the branch associated to HEAD
}
export -f __git_sclone

# With relative path for subsubmodules: not working
#__git_config_submod_wd() {
#  submod_path=$2
#  echo "Configuring submodule $submod_path"
#
#  # init
#  git submodule init
#
#  # path to come back to the main repo
#  declare -i nb_sub_dir=`echo $submod_path | grep -o / | wc -l`
#  to_main_repo=..
#  for (( i=0; i<nb_sub_dir; ++i)); do
#    to_main_repo+=/..
#  done 
#  echo $to_main_repo
#
#  # each subsub repo is also a sub repo, so
#  # for each subsub repo, make the working dir be a pointer to the corresponding sub repo
#  subsubmod_conf_paths=`git config --file .gitmodules --name-only --get-regexp path`
#  for subsubmod_conf_path in $subsubmod_conf_paths; do
#    if [[ $subsubmod_conf_path =~ submodule\.(.*)\.path ]]; then
#      subsubmod_path=${BASH_REMATCH[1]}
#      echo $subsubmod_path
#      echo gitdir: $to_main_repo/.git/modules/$subsubmod_path > $subsubmod_path/.git
#    fi
#  done
#}
#export -f __git_config_submod_wd
#
#__git_sclone() { 
#  # clone without submodules
#  clone_res="$(LANG=en_US git clone $@ 2>&1)"
#  echo $clone_res
#  if (($? != 0)); then
#    echo "Command \"git clone $@\" failed"; exit 1
#  else
#    echo "Successfully cloned the main repository"
#  fi
#
#  # get the name of the folder cloned
#  if [[ $clone_res =~ .*Cloning\ into\ \'(.*)\'.* ]]; then
#    repository_name=${BASH_REMATCH[1]}
#  else
#    echo "In __git_sclone: unable to parse output of \"git clone $@\""; exit 1
#  fi
#
#  # update submodules and create git "symlinks" from subsubmodules to main repository submodules
#  (cd $repository_name
#    if (($? != 0)); then
#      echo "Unable to access folder \"$repository_name\""; exit 1
#    fi
#
#    git submodule update --init
#    if (($? != 0)); then
#      echo "Cloning of submodules failed"; exit 1
#    else 
#      echo "Successfully cloned submodules"
#    fi
#
#    git submodule foreach '__git_config_submod_wd $toplevel $sm_path'
#    if (($? != 0)); then
#      echo "Configuring submodules of submodules failed"; exit 1
#    else 
#      echo "Successfully configured submodules of submodules"
#    fi
#  )
#
#  ##git rev-parse HEAD | xargs git name-rev # name of the branch associated to HEAD
#}
#export -f __git_sclone

__git_fetchall() {
  git fetch --recurse-submodules=yes "$@";
}
export -f __git_fetchall
__git_spull() {
  git pull "$@" && git submodule update --init;
}
export -f __git_spull
__git_spush() {
  git push --recurse-submodules=on-demand "$@";
}
export -f __git_spush


# aliases and more verbose status
git config --global status.submoduleSummary true
git config --global diff.submodule log

git config --global alias.sclone '! __git_sclone'
git config --global alias.fetchall '! __git_fetchall'
git config --global alias.spull '! __git_spull'
git config --global alias.spush '! __git_spush'
