# About

How to pull and deploy your dotfiles in a brand new machine AFAP.

NOTE: not all folders are (or should be used as) deployables. That includes: bin, powerlevel10k, templates.

# Deploying dotfiles

## step 1: download dotfiles

In this scenario the user doesn't have any dotfiles in his system and will pull them from a git server.
```bash
# add an host entry for the git server
sudo vim /etc/hosts
    # 192.168.122.1   mothership
sudo apt-get install stow

# define the remote git server being used
export git_server="mothership"
export git_port="23231"

# OPTION A: for the user
tool="/tmp/dotfiler.sh"  # can be deleted after we cloned our dotfiles
ssh $git_server -p $git_port repo blob dotfiles_public $(basename $tool) > $tool
chmod +x $tool
# OPTION B: for root (only do this pass after you set up the user... and assuming that user isn't compromised!)
tool=/home/replicant/dotfiles_public/dotfiler.sh

cd
$tool get-repo dotfiles_public
```

## step 2: install dotfiles

NOTE: this should no longer be the case so you should be able to ignore this note... BUT if the `dotfiles_public` repo is referencing any private git repos (ie: submodules) then the process may fail due to remote server definitions, and then you would have to fix it and update the submodules manually. A better option may be to simply deploy the private dotfiles first. Or even better just ensure those submodules are on github.com in the first place.
For future reference the manual fix would consist of:
```bash
git submodule update --init --recursive             # download modules latest versions
git submodule foreach --recursive git reset --hard  # reset back to version previously used
```


During deployment any existing files will be moved the backup folder `dotfiler_bak`.

Define packages:
```bash
packages="shell vim neovim tmux"
#packages="shell vim neovim tmux wmde i3"
```

OPTION A: you have restored a complete backup of your dotfiles (eg: from a disk), so you have all files including git submodules, you're just missing the links.
```bash
$tool -n deploy-dotfiles-from-local ~/dotfiles_public $packages
$tool    deploy-dotfiles-from-local ~/dotfiles_public $packages
```

OPTION B: you restored your dotfiles from a git server but are still missing git submodules.
```bash
$tool -n deploy-dotfiles-from-remote ~/dotfiles_public $packages
$tool    deploy-dotfiles-from-remote ~/dotfiles_public $packages
```

OPTION C: you want to adopt existing dotfiles and bring them into your dotfiles repo (packagename can be something like `vim`, `shell`, `wmde`)
```bash
$tool -n adopt-dotfiles ~/dotfiles_public $packagename $dotfile1 ... $dotfileN
$tool    adopt-dotfiles ~/dotfiles_public $packagename $dotfile1 ... $dotfileN
```


## step 3: private dotfiles

OPTIONAL: if you don't have private dotfiles yet, then create a folder scaffold for them, and stow some files
```bash
# create a template:
$tool -n private-template ~/dotfiles_private
$tool    private-template ~/dotfiles_private

# then stash your private dotfiles, as an example for ssh:
mv ~/.ssh ~/dotfiles_private/ssh/
cd dotfiles_private
echo ".ssh" > .gitignore # optional and will change depending if or to where you'll be pushing dotfiles_private
```


Now deploy your private dotfiles:
```bash
# and finally deploy (ie link back)
###stow ssh
###stow shell
packages="shell ssh other"
$tool -n deploy-dotfiles-from-local ~/dotfiles_private $packages
$tool    deploy-dotfiles-from-local ~/dotfiles_private $packages

# VERY IMPORTANT to prevent you getting locked out (especially in vagrant VMs). Adjust as needed
cat $HOME/dotfiler_bak/authorized_keys >> $HOME/.ssh/authorized_keys
```



## step 4: configure git remote

This will update the git remote endpoint settings for the `dotfiles_public` repo. It sets the remote to make use of the `~/.ssh/config` settings. This is required if you cloned your dotfiles (as opposed to a local storage backup restore) and you want to push to a git server.
Make sure your `~/.ssh/config` is properly set and you have any required keys.
```bash
export git_server='softserve' ; export git_port='' ; export git_name='home'
cd ~/dotfiles_public
$tool set-remote
```


## wallpapers
Least I forget about this again; the default wallpapers are in the `vagrant_recipes/blank-debian12-local` folder. Not sure what I was thinking back then. Maybe I'll move them to this `dotfiles_public` folder instead.


# Managing dotfiles

## Tracking new file
This will move an existing dotfile into the chosen package in your dotfile repo and then deploy it (ie, link from the repo to its expected location) using stow.
```bash
$tool -n adopt-dotfiles $HOME/dotfiles_public $packagename $dotfile1 ... $dotfileN
$tool    adopt-dotfiles $HOME/dotfiles_public $packagename $dotfile1 ... $dotfileN

# examples
cd ~
$tool    adopt-dotfiles dotfiles_public shell .bashrc .profile
$tool    adopt-dotfiles dotfiles_public vim .vimrc
$tool    adopt-dotfiles dotfiles_public wmde ~/.config/i3/config
```

## Retreat dotfiles
This will unstow (ie remove the symlinks in your $HOME linking to your dotfiles folder) of all dotfiles in the given $packagename.
This is useful for swapping dotfiles settings, eg: swap between vim dotfile packages
```bash
$tool -n retreat-dotfiles $HOME/dotfiles_public $packagename
$tool    retreat-dotfiles $HOME/dotfiles_public $packagename
```


## Collisions
This tool can handle dotfile collisions. See help menu.


# Other tasks

## Dotfile backups
Ensure dotfiles are (referenced) in a location that is included by your backup system
YMMV here on what you need to do
```bash
cd $USER/data/home/
ln -s $HOME/dotfiles_public .
ln -s $HOME/dotfiles_private .
```


## Pushing new repo to git server
This isn't related to dotfiles per se, but more of a convenience type of thing on using our local git server and dotfiler tool
```bash
cd $some_git_repo
$tool push-repo
```

## Browsing the git server
```bash
# browse the git server repos
ssh $git_server -p $git_port -t

# you can also use dotfiler
$tool
$tool browse-server
```


