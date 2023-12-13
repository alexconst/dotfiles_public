#!/bin/bash

# TODO: (hindsight is 20-20) refactor code to use a $dotfiles_public/private env variables instead of accepting a parameter to operations

# flag to decide if the script makes any changes or just does a dry run
dry_run=false

# default git remote name
git_remote=${git_remote:-home}


# run stow to either deploy or retrieve dotfiles
run_stow() {
  local folder_name="$1"
  local packages="${@:2}"
  if [[ -z $folder_name ]]; then
    echo "ERROR: expected the dotfiles folder as argument"
    return
  fi
  folder_name="$(readlink -f $folder_name)"
  pushd . >/dev/null
  cd ${folder_name}
  if [[ -z "$packages" ]]; then
    packages=$(ls -d */ | xargs -n 1 basename | paste -sd ' ')
  fi
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: cd ${folder_name}"
    echo "Dry run: stow -n --verbose=2 ${stow_args} ${packages}"
    stow -n --verbose=2 ${stow_args} ${packages}
  else
    stow ${stow_args} ${packages}
  fi
  popd >/dev/null
}

remove_dotfiles() {
  local folder_name="$1"
  local packages="${@:2}"

  if [ "$dry_run" = "true" ]; then
    echo "Dry run: would move existing files that conflict with stow packages:"
  else
    echo "Moving existing files that conflict with stow packages:"
  fi
  msg='* existing target is neither a link nor a directory:'
  local dotfiles=( $(run_stow "$folder_name" "$packages" 2>&1 | grep "$msg" | sed "s#$msg##g") )
  undo_folder="$HOME/dotfiler_bak"
  for item in "${dotfiles[@]}"; do
    cmd="mv -v -n ~/$item ${undo_folder}/"
    if [ "$dry_run" = "true" ]; then
      echo "$cmd"
    else
      mkdir -p $undo_folder
      eval $cmd
    fi
  done
}

# deploy-dotfiles operation: run stow
deploy_dotfiles() {
  local deploy_mode="$1"
  local folder_name="$2"
  local packages="${@:3}"

  run_stow "$folder_name" "$packages"

  if [ "$deploy_mode" = "remote" ]; then
    cd ${folder_name}
    if [ "$dry_run" = "true" ]; then
        echo "Dry run: git submodule update --init --recursive"
    else
        git submodule update --init --recursive
    fi
  fi
}

# adopt-dotfiles operation: run stow
adopt_dotfiles() {
  export stow_args=" "
  dotfiles_folder="$(readlink -f $1)"
  package_name="$2"
  shift 2
  for dotfile in "$@"; do
    subfolder=$(readlink -f "${dotfile}" | sed "s#$HOME/##" | xargs dirname)
    destination="${dotfiles_folder}/${package_name}/${subfolder}"
    if [ "$dry_run" = "true" ]; then
      echo "Dry run: mkdir -p ${destination}"
      echo "Dry run: mv -n ${dotfile} ${destination}/"
    else
      mkdir -p "${destination}"
      mv -n "${dotfile}" "${destination}/"
    fi
  done
  deploy_dotfiles "remote" "$dotfiles_folder" # NOTE: I'm not sure about using remote but at least maintains compatibility
}

# private-template operation: create folder structure
private_template() {
  local folder_name="$1"
  if [[ -z $folder_name ]]; then
    folder_name="dotfiles_private"
  fi
  cd $HOME
  mkdir -p $folder_name/ssh
  mkdir -p $folder_name/shell
  touch $folder_name/shell/.gitconfig.user
  echo -e "[user]\n    email = $USER@$(hostname).local\n    name = $USER" > $folder_name/shell/.gitconfig.user
  touch $folder_name/shell/.shellrc.local
}

# browse operation: browse soft-serve git repo
browse() {
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: ssh -t $git_server -p $git_port"
  else
    ssh -t $git_server -p $git_port
  fi
}

# get-repo operation: clone a git repo via ssh or pull/update from remote
get_repo() {
  local repo_name="$1"
  if [[ -z $repo_name ]]; then
    echo "ERROR: expected a repo_name as argument"
    return
  fi
  if [ "$dry_run" = "true" ]; then
    if [[ -d "$repo_name" ]]; then
      echo "Dry run: cd ${repo_name}"
      echo "Dry run: git pull"
    else
      echo "Dry run: git clone ssh://$git_server:$git_port/$repo_name"
    fi
  else
    if [[ -d "$repo_name" ]]; then
      cd "$repo_name"
      git pull
    else
      git clone ssh://$git_server:$git_port/$repo_name
    fi
  fi
}

# set-remote operation: sets the remote origin using the $git_server and $git_port variables
set_remote() {
  local repo_name="$1"
  if [[ -z $repo_name ]]; then
    repo_name="$(basename `pwd`)"
  fi
  if [ "$dry_run" = "true" ]; then
    #echo "Dry run: git remote rm origin 2>/dev/null || true"
    echo "Dry run: git remote add $git_remote ssh://$git_server:$git_port/$repo_name"
  else
    #git remote rm origin 2>/dev/null || true
    git remote add $git_remote ssh://$git_server:$git_port/$repo_name
  fi
}

# push-repo operation: push all branches to remote
push_repo() {
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: git push -u $git_remote" --all
  else
    git push -u $git_remote --all
  fi
}

# usage operation
usage() {
  echo -e "
About:
  Helper script to install and manage dotfiles on a machine. It uses GNU stow to do so.
  It can either deploy dotfiles from a restored backup.
  Or deploy dotfiles in a blank system by pulling them from a git repo over SSH. It also helps with handling the remote git server. In which it expects the variables \$git_server and \$git_port to be set.

Usage: $0 [options]\n
  Options
  -n, --dry-run  Dry run, echo the commands that would be executed without actually executing them
  -h, --help     Show this help message

Commands:
  adopt-dotfiles               Moves dotfiles into the repo and then deploys links with stow. Expects as argument a \$repo_name
  deploy-dotfiles-from-local   Deploys dotfiles with stow using local repo with all files. Expects as argument a \$repo_name and optionally \$packages
                               Use this when you restored your dotfiles from a backup and it already includes all submodules.
  deploy-dotfiles-from-remote  Deploys dotfiles with stow and inits git submodules. Expects as argument a \$repo_name and optionally \$packages
                               Use this when you you cloned the repo from a server.
  private-template             Creates a dotfiles_private folder structure. Accepts optional argument for the \$folder_name
  browse-server                Accesses the soft-serve git server
  set-remote                   Sets a remote server origin. Expects as argument a \$repo_name, if none then it uses the current pwd
  get-repo                     Clones a git repo if it doesn't exist. It it exists then does a git pull. Expects as argument a \$repo_name
  push-repo                    Push all branches of repo in pwd to remote (also particularly useful if the repo doesn't exist on the server yet)
  usage                        Prints this help message

Current configuration:
  git_server: $git_server
  git_port:   $git_port
  git_remote: $git_remote


NOTE: recent changes have been made and this hasn't been throughly tested yet. Not safe for prod. Run in VM instead.
"
}

check_config() {
  if [[ -z $git_server ]] || [[ -z $git_port ]]; then
    echo "WARN: variables git_server and git_port have not been configured. Setting defaults:"
    export git_server=mothership
    export git_port=23231
    echo -e "\tgit_server: $git_server"
    echo -e "\tgit_port:   $git_port"
    echo -e "\tgit_remote: $git_remote"
  fi
}




# process command line arguments
if [[ $# -eq 0 ]]; then
  usage
  check_config
  exit
fi

# check requirements
check_config

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -n|--dry-run)
      dry_run=true
    ;;
    -h|--help)
      usage
    ;;
    adopt-dotfiles)
      shift
      adopt_dotfiles "$@"
      break
    ;;
    deploy-dotfiles-from-local)
      shift
      #export stow_args=" " # couldn't find a flag that would help in overwriting existing files with stow links
      remove_dotfiles "$@"
      deploy_dotfiles "local" "$@"
      break
    ;;
    deploy-dotfiles-from-remote)
      shift
      #export stow_args=" " # couldn't find a flag that would help in overwriting existing files with stow links
      remove_dotfiles "$@"
      deploy_dotfiles "remote" "$@"
      break
    ;;
    private-template)
      private_template $2
      break
    ;;
    browse-server)
      browse
      break
    ;;
    get-repo)
      get_repo $2
      break
    ;;
    set-remote)
      set_remote $2
      break
    ;;
    push-repo)
      push_repo
      break
    ;;
    *)    # unknown option
    usage
    ;;
  esac
  shift # past argument or value
done

