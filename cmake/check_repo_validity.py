from pathlib import Path
import os


def is_empty_git_repo(repo):
  children = list(repo.iterdir())
  n_child  = len(children)
  if n_child==0:
    return 'empty'
  elif n_child>1:
    return 'filled'
  else:
    child = children[0]
    if child.name=='.git' and child.is_file():
      return '.gitted'
    else:
      return 'filled'


def _get_repo_tree(root, repo_list):

  if Path.exists(root/'external'):
    for child in (root/'external').iterdir():
      repo_list.append(child)
      _get_repo_tree(child, repo_list)

  return True


def get_repo_tree(root):
  repo_list = list()
  _get_repo_tree(root, repo_list)

  return repo_list


def get_repo_tree_filling(repo_tree):
  repo_filling = dict()
  for repo in repo_tree:
    # print(f'{repo.name}:')
    if repo.name not in repo_filling:
      is_empty = is_empty_git_repo(repo)
      repo_filling[repo.name] = [(repo, is_empty)]
    else:
      is_empty = is_empty_git_repo(repo)
      repo_filling[repo.name].append((repo, is_empty))

  return repo_filling


def check_repo_filled_once(repo_filling, optional_dependencies):
  msg = ''
  indent = '    '
  for repo_name, paths_info in repo_filling.items():
    unfilled_paths = list()
    filled_paths   = list()
    for path, fill_status in paths_info:
      if fill_status=="filled":
        filled_paths.append(path)
      else:
        unfilled_paths.append(path)

    if len(filled_paths)>1:
      msg     += f"Error: repo \"{repo_name}\" is initialized more than once. You need to keep only one of the following locations initialized:\n"
      str_path = '\n'.join([indent+str(path) for path in filled_paths])
      msg     += f"{str_path}\n\n"
    if repo_name not in optional_dependencies and len(filled_paths)==0:
      if len(unfilled_paths)==1:
        msg     += f"Error: repo \"{repo_name}\" is not initialized, You need to initialize it at the following location:\n"
        str_path = indent+str(unfilled_paths[0])+'\n'
        msg     += f"{str_path}\n"
      else:
        msg     += f"Error: repo \"{repo_name}\" is not initialized. You need to initialize it at one of the following locations:\n"
        str_path = '\n'.join([indent+str(path) for path in unfilled_paths])
        msg     += f"{str_path}\n\n"

  return msg

def filter_dependencies(repo_list, repo_root_list):
  repo_cur_names = {path.name for path in repo_list}
  # print(repo_cur_names)
  common_repos = []
  for repo_path in repo_root_list:
    repo_name = repo_path.name
    if repo_name in repo_cur_names:
      common_repos.append(repo_path)
  return common_repos

if __name__=="__main__":

  import argparse
  parser = argparse.ArgumentParser()
  parser.add_argument('--root'               , type=Path, help='Root of the repo that should be checked')
  parser.add_argument('--current'            , type=Path, help='Current repo that should be checked')
  parser.add_argument('--ignore-dependencies', type=str , help='Comma-separated list of dependencies that can be empty (because they are optional)')
  args = parser.parse_args()

  verbose = False

  optional_dependencies = args.ignore_dependencies.split(',')
  optional_dependencies = [x.strip() for x in optional_dependencies if x.strip() != ""]

  repo_list      = get_repo_tree(args.current)
  repo_root_list = get_repo_tree(args.root)

  if verbose:
    print("root    : ", args.root   )
    print("current : ", args.current)
    print("repo_list")
    for rep in repo_list:
      print(rep)

    print("repo_root_list")
    for rep in repo_root_list:
      print(rep)

  common_repos = filter_dependencies(repo_list, repo_root_list)

  if verbose:
    print("common_repos : ")
    for common in common_repos:
      print(common)

  # ---
  repo_filling   = get_repo_tree_filling(common_repos)

  if verbose:
    for repo_name, paths_info in repo_filling.items():
     print(repo_name)
     for path,fill_status in paths_info:
       print(f'  {path}: {fill_status}')

  # > Principal fonction
  msg = check_repo_filled_once(repo_filling, optional_dependencies)

  print(msg)

  if msg=="":
    exit(0)
  else:
    exit(1)
