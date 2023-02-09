# About

How to pull and deploy your dotfiles in a brand new machine AFAP.

# Deploy dotfiles

```bash
export git_server="mothership" # adapt as needed
export git_port="23231"
tool="/tmp/dotfiler.sh"  # can be deleted after we cloned our dotfiles

ssh $git_server -p $git_port cat dotfiles_public/$(basename $tool) > $tool
chmod +x $tool
cd
$tool clone dotfiles_public

# OPTION 1: you don't have any dotfiles in the current system or don't mind overwriting them
$tool -d deploy-dotfiles dotfiles_public
$tool deploy-dotfiles dotfiles_public

# OPTION 2: you have dotfiles and want to keep those changes and integrate them with the dotfiles repo
$tool -d adopt-dotfiles dotfiles_public
$tool adopt-dotfiles dotfiles_public
```

# Other tasks

```bash
# browse the git server repos
ssh $git_server -p $git_port -t
```


