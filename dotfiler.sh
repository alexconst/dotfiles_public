#!/bin/bash

# flag to decide if the script makes any changes or just does a dry run
dry_run=false

# default git remote name
git_remote=${git_remote:-home}


# run stow to either deploy or retrieve dotfiles
run_stow() {
  local folder_name="$1"
  if [[ -z $folder_name ]]; then
    echo "ERROR: expected the dotfiles folder as argument"
    return
  fi
  folder_name="$(readlink -f $folder_name)"
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: cd ${folder_name}"
    cd ${folder_name}
    echo "Dry run: stow -n --verbose=2 ${stow_args} $(ls -d */ | xargs -n 1 basename | paste -sd ' ')"
    stow -n --verbose=2 ${stow_args} $(ls -d */ | xargs -n 1 basename | paste -sd ' ')
  else
    cd ${folder_name}
    stow ${stow_args} $(ls -d */ | xargs -n 1 basename | paste -sd ' ')
  fi
}

# deploy-dotfiles operation: run stow
deploy_dotfiles() {
    export stow_args=" "
    run_stow "$1"
}

# adopt-dotfiles operation: run stow
adopt_dotfiles() {
    export stow_args="--adopt"
    run_stow "$1"
}

# browse operation: browse soft-serve git repo
browse() {
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: ssh -t $git_server -p $git_port"
  else
    ssh -t $git_server -p $git_port
  fi
}

# clone operation: clone a git repo via ssh
clone() {
  local repo_name="$1"
  if [[ -z $repo_name ]]; then
    echo "ERROR: expected a repo_name as argument"
    return
  fi
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: git clone ssh://$git_server:$git_port/$repo_name"
  else
    git clone ssh://$git_server:$git_port/$repo_name
  fi
}

# set-remote operation: sets the remote origin using the $git_server and $git_port variables
set_remote() {
  local repo_name="$1"
  if [[ -z $repo_name ]]; then
    repo_name="$(basename `pwd`)"
  fi
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: git remote rm origin 2>/dev/null || true"
    echo "Dry run: git remote add $git_remote ssh://$git_server:$git_port/$repo_name"
  else
    git remote rm origin 2>/dev/null || true
    git remote add $git_remote ssh://$git_server:$git_port/$repo_name
  fi
}

# push operation: push changes to remote
push() {
  if [ "$dry_run" = "true" ]; then
    echo "Dry run: git push -u $git_remote"
  else
    git push -u $git_remote
  fi
}

# usage operation
usage() {
  echo -e "
About:
  Helper script to install and manage dotfiles on a machine.
  It pulls the dotfiles from a git repo over SSH and the deploys them using GNU stow.
  It expects for the variables \$git_server and \$git_port to be set.

Usage: $0 [options]\n
  Options
  -d, --dry-run  Dry run, echo the commands that would be executed without actually executing them
  -h, --help     Show this help message

Commands:
  adopt-dotfiles   Moves dotfiles into the dotfiles repo and then deploys links. Expects as argument a \$repo_name
  deploy-dotfiles  Deploys dotfiles with stow. Expects as argument a \$repo_name
  browse-server    Accesses the soft-serve git server
  clone            Clones a git repo. Expects as argument a \$repo_name
  set-remote       Sets a remote server origin. Expects as argument a \$repo_name, if none them uses default basedir
  push             Push committed changes to remote
  usage            Prints this help message

Current configuration:
  git_server: $git_server
  git_port:   $git_port
  git_remote: $git_remote
"
}

check_requirements() {
    if [[ -z $git_server ]] || [[ -z $git_port ]]; then
        usage
        echo "ERROR: variables git_server and git_port must be properly configured."
        exit 1
    fi
}




# check requirements
check_requirements

# process command line arguments
if [[ $# -eq 0 ]]; then
  usage
fi
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--dry-run)
      dry_run=true
    ;;
    -h|--help)
      usage
    ;;
    adopt-dotfiles)
      adopt_dotfiles $2
      break
    ;;
    deploy-dotfiles)
      deploy_dotfiles $2
      break
    ;;
    browse-server)
      browse
      break
    ;;
    clone)
      clone $2
      break
    ;;
    set-remote)
      set_remote $2
      break
    ;;
    push)
      push
      break
    ;;
    *)    # unknown option
    usage
    ;;
  esac
  shift # past argument or value
done

