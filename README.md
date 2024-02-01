# About

How to pull and deploy your dotfiles in a brand new machine AFAP.

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

Any existing files will be moved to a backup folder.

Define packages:
```bash
packages="shell vim"
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

Create folder structure for private dotfiles (ie these are not stored in the remote git server). It doesn't stow anything automatically, you have to do it manually.
```bash
# if you don't have such files yet then create a template
$tool -n private-template ~/dotfiles_private
$tool    private-template ~/dotfiles_private

# as an example for ssh
mv ~/.ssh ~/dotfiles_private/ssh/
cd dotfiles_private
echo ".ssh" > .gitignore # optional and will change depending if or to where you'll be pushing dotfiles_private

# deploy
###stow ssh
###stow shell
packages="shell ssh"
$tool -n deploy-dotfiles-from-local ~/dotfiles_private $packages
$tool    deploy-dotfiles-from-local ~/dotfiles_private $packages
```


## step 4: configure git remote

This will update the git remote endpoint settings for the dotfiles_public repo. It sets the remote to make use of the `~/.ssh/config` settings, which helps when the git server requires authentication (to push).
Make sure your `~/.ssh/config` is properly set and you have any required keys.
```bash
export git_server='softserve' ; export git_port='' ; export git_name='home'
cd ~/dotfiles_public
$tool set-remote
```



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


