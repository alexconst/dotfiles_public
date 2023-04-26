# About

How to pull and deploy your dotfiles in a brand new machine AFAP.

# Deploy dotfiles

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
ssh $git_server -p $git_port cat dotfiles_public/$(basename $tool) > $tool
chmod +x $tool
# OPTION B: for root (only do this pass after you set up the user... and assuming that user isn't compromised!)
tool=/home/replicant/dotfiles_public/dotfiler.sh

cd
$tool get-repo dotfiles_public

# OPTION 1: you don't have any dotfiles in the current system or don't mind overwriting them
$tool -n deploy-dotfiles dotfiles_public
$tool    deploy-dotfiles dotfiles_public
# OPTION 2: you already have dotfiles and want to keep them and integrate them with the dotfiles repo (packagename can be something like `vim`, `shell`, `wmde`)
$tool -n adopt-dotfiles dotfiles_public $packagename $dotfile1 ... $dotfileN
$tool    adopt-dotfiles dotfiles_public $packagename $dotfile1 ... $dotfileN

# create folder structure for private dotfiles. It doesn't stow anything automatically, you have to do it manually
$tool private-template dotfiles_private
# as an example for ssh
mv ~/.ssh ~/dotfiles_private/ssh/
cd dotfiles_private
echo ".ssh" > .gitignore # add safeguard (but you can still cherry pick files to git add)
stow ssh
stow shell
```

# Dotfile backups
Ensure dotfiles are (referenced) in a location that is included by your backup system
YMMV here on what you need to do
```bash
cd $USER/data/home/
ln -s $HOME/dotfiles_public .
ln -s $HOME/dotfiles_private .
```


# Track new file
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


# Push new repo to server
This isn't exclusive to dotfiles, but more of a convenience type of thing on using our local git server
```bash
cd $some_git_repo
$tool push-repo
```

# Browse the git repo
```bash
# browse the git server repos
ssh $git_server -p $git_port -t

# you can also use dotfiler
$tool
$tool browse-server
```


