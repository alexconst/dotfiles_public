#!/bin/bash

# TODO: (hindsight is 20-20) refactor code to use a $dotfiles_public/private env variables instead of accepting a parameter to operations

# flag to decide if the script makes any changes or just does a dry run
dry_run=false

# default git remote name
git_name=${git_name:-home}


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

retreat_dotfiles() {
  stow_args="--delete"
  run_stow "$@"
}

remove_dotfiles() {
  local folder_name="$1"
  local packages="${@:2}"
  undo_folder="$HOME/dotfiler_bak"

  msg='* existing target is neither a link nor a directory:'
  local dotfiles=( $(run_stow "$folder_name" "$packages" 2>&1 | grep "$msg" | sed "s#$msg##g") )
  if [[ ${#dotfiles[@]} -gt 0 ]]; then
    if [ "$dry_run" = "true" ]; then
      echo "Dry run: would move existing files that conflict with stow packages:"
    else
      echo "Moving existing files that conflict with stow packages:"
    fi
  else
    echo "There are no files that conflict with the stow packages."
  fi
  for item in "${dotfiles[@]}"; do
    cmd="mv -v -n ~/$item ${undo_folder}/"
    if [ "$dry_run" = "true" ]; then
      echo "  $cmd"
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

  if [[ -z "$folder_name" ]] || [[ ! -d "$folder_name" ]] || [[ -z "${packages}" ]]; then
    echo "ERROR: missing parameters to this operation"
    return
  fi

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
  local privates_folder="$1"
  local templates_folder="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/templates"
  if [[ -z $privates_folder ]]; then
    privates_folder="$HOME/dotfiles_private"
  fi
  cd $HOME

  files=("shell/.gitconfig.user" "ssh/.ssh/config" "shell/.shellrc.local")
  for item in "${files[@]}"; do
    source_file="$templates_folder/$(echo ${item} | sed 's#_#/#g')"
    target_file="$privates_folder/$item"
    if [[ -f "$target_file" ]]; then
      echo "WARN: skipping because file already exists: $target_file"
    elif [[ "$dry_run" == "true" ]]; then
      echo "INFO: DRY-RUN would copy: ${source_file}  ->  ${target_file}"
    else
      mkdir -p $(dirname $target_file)
      cat "${source_file}" | envsubst > "${target_file}"
    fi
  done

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
  git_address=$git_server
  if [[ -n $git_port ]]; then
    git_address=$git_server:$git_port
  fi
  cmd="git remote add $git_name ssh://$git_address/$repo_name"
  if [ "$dry_run" = "true" ]; then
    #echo "Dry run: git remote rm origin 2>/dev/null || true"
    echo "Dry run: $cmd"
  else
    #git remote rm origin 2>/dev/null || true
    eval $cmd
  fi
}

# push-repo operation: push all branches to remote
push_repo() {
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: git push -u $git_name" --all
  else
    git push -u $git_name --all
  fi
}

# usage operation
usage() {
  tool=$(basename $0)
  echo -e "
About:
  Helper script to install and manage dotfiles on a machine. Under the hood it uses GNU stow to do so.
  It can either deploy dotfiles from a restored backup. Or deploy dotfiles in a blank system by pulling them from a git repo over SSH.
  It also helps with handling the remote git server. In which it expects the variables \$git_server and optionally \$git_port to be set.
  It can handle folder collisions across packages (ie same folder exists in different packages being deployed). It will abort on file collisions.

Usage: $0 [options]\n
  Options
  -n, --dry-run  Dry run, echo the commands that would be executed without actually executing them
  -h, --help     Show this help message

Commands:
  deploy-dotfiles-from-local   Deploys dotfiles with stow using local repo with all files. Expects as argument a \$repo_name and optionally \$packages
                               Use this when you restored your dotfiles from a backup and it already includes all submodules.
  deploy-dotfiles-from-remote  Deploys dotfiles with stow and inits git submodules. Expects as argument a \$repo_name and optionally \$packages
                               Use this when you you cloned the repo from a server.
  retreat-dotfiles             Unstow (ie remove the links) of all dotfiles for the given \$packages
                               Use this when you want to swap dotfile packages (eg: vim)
  adopt-dotfiles               Moves dotfiles into the repo and then deploys links with stow. Expects as argument a \$repo_name
  private-template             Creates a dotfiles_private folder structure. Accepts optional argument for the \$folder_name
  browse-server                Accesses the soft-serve git server
  set-remote                   Sets a remote server origin. Expects as argument a \$repo_name, if none then it uses the current pwd
  get-repo                     Clones a git repo if it doesn't exist. It it exists then does a git pull. Expects as argument a \$repo_name
  push-repo                    Push all branches of repo in pwd to remote (also particularly useful if the repo doesn't exist on the server yet)
  usage                        Prints this help message


To bootstrap in another machine with access to a remote a soft-serve git server:
  ssh $git_server -p $git_port repo blob dotfiles_public $tool > $tool
  chmod +x $tool
  ./$tool get-repo dotfiles_public
  rm $tool

"
}

check_config() {
  if [[ -z $git_server ]]; then
    echo "WARN: variables git_server and git_port have not been configured. Setting defaults:"
    export git_server=mothership
    export git_port=23231
  fi
  printf "INFO: current settings:\n"
  printf "  %-30s %s\n" "git_server: $git_server" "(git server address)"
  printf "  %-30s %s\n" "git_port: $git_port" "(git server port)"
  printf "  %-30s %s\n" "git_name: $git_name" "(name to identify the \$git_server as part of the remotes in the git repo)"
}




# process command line arguments
if [[ $# -eq 0 ]]; then
  check_config
  usage
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
    retreat-dotfiles)
      shift
      retreat_dotfiles "$@"
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
      echo "ERROR: unknown option: '$1'"
      exit
    ;;
  esac
  shift # past argument or value
done

