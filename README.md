# About

How to pull and deploy your dotfiles in a brand new machine AFAP.

# Deploy dotfiles

```bash
# add an host entry for the git server
sudo vim /etc/hosts

# define the remote git server being used
export git_server="mothership"
export git_port="23231"

# for the user
tool="/tmp/dotfiler.sh"  # can be deleted after we cloned our dotfiles
ssh $git_server -p $git_port cat dotfiles_public/$(basename $tool) > $tool
chmod +x $tool
# for root (after you set up the user... and assuming you trust it!)
tool=/home/replicant/dotfiles_public/dotfiler.sh

cd
$tool clone dotfiles_public

# OPTION 1: you don't have any dotfiles in the current system or don't mind overwriting them
$tool -d deploy-dotfiles dotfiles_public
$tool deploy-dotfiles dotfiles_public
# OPTION 2: you have dotfiles and want to keep those changes and integrate them with the dotfiles repo
$tool -d adopt-dotfiles dotfiles_public
$tool adopt-dotfiles dotfiles_public

# create folder structure for private dotfiles. It doesn't stow anything automatically, you have to do it manually
$tool private-template dotfiles_private
# as an example for ssh
mv ~/.ssh ~/dotfiles_private/ssh/
cd dotfiles_private
echo ".ssh" > .gitignore
stow ssh
stow shell
```

# Other tasks

```bash
# browse the git server repos
ssh $git_server -p $git_port -t
```


