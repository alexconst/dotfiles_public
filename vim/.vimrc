""""""""""""""""""""""""""""""""""""""""""""""""
" general options
""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
set ruler
set laststatus=2
set showcmd
set showmode
set number
set incsearch
set ignorecase
set smartcase
set hlsearch
set nopaste


""""""""""""""""""""""""""""""""""""""""""""""""
" indentation
""""""""""""""""""""""""""""""""""""""""""""""""
"set autoindent      " apply the indentation of the current line to the next
"set smartindent     " reacts to the syntax/style of the code you are editing (especially for C)
filetype indent on   " https://stackoverflow.com/questions/354097/how-to-configure-vim-to-not-put-comments-at-the-beginning-of-lines-while-editing/777385#777385
" whitespace handling:
set expandtab       " insert spaces instead of tabs
set tabstop=4       " make tabs 4 columns wide
set softtabstop=4   " indent as if tabs are 4 columns wide
set shiftwidth=4    " indent next line 4 columns wide
set shiftround      " use shiftwidth when shifting lines
set nojoinspaces    " avoid extra spaces when joining lines


""""""""""""""""""""""""""""""""""""""""""""""""
" shortcuts
""""""""""""""""""""""""""""""""""""""""""""""""
" shorcuts to leave edit mode and enter command mode
inoremap jj <esc>l
inoremap jk <esc>
" paste toggle
set pastetoggle=<F2>
" spell check toggle
map <F5> :setlocal spell! spelllang=en_us<CR>
" open file under cursor
" https://unix.stackexchange.com/questions/74571/vim-shortcut-to-open-a-file-under-cursor-in-an-already-opened-window
" https://vim.fandom.com/wiki/Open_file_under_cursor
map <F8> 0^vg_<c-w>gf1<c-w><c-w>
" shift+J is for joining a line, so we map ctrl+j for breaking/newlining a line
nnoremap <C-J> i<CR><Esc>k$hl
" search for text visually selected
vnoremap <Bslash> y/<C-r>=substitute(@",'/','\\/','g')<CR><CR>
" clear the search buffer by typing ,/ (, is used instead of : because vim shannaningas will cause an annoying delay)
nmap <silent> ,/ :nohlsearch<CR>


""""""""""""""""""""""""""""""""""""""""""""""""
" tabs
""""""""""""""""""""""""""""""""""""""""""""""""
set showtabline=2
" increase max num of tabs (useful for vim -p ...)
set tabpagemax=100
" efficient way to cycle through tabs:
nnoremap <silent> <C-p> :tabprevious<CR>
nnoremap <silent> <C-n> :tabnext<CR>
nnoremap <silent> <C-c> :tabclose<CR>
" shortcuts for moving a tab to the left or right:
nnoremap <silent> <C-h> :execute 'silent! tabmove ' . (tabpagenr()-2) <CR>
nnoremap <silent> <C-l> :execute 'silent! tabmove ' . (tabpagenr()+1) <CR>


""""""""""""""""""""""""""""""""""""""""""""""""
" buffers
""""""""""""""""""""""""""""""""""""""""""""""""
au FocusGained,BufEnter * :silent! checktime    " check for and reload (or discard) external changes when Vim or the current buffer gains focus (could also use CursorMoved but that seems overkill)
"au FocusLost,WinLeave * :silent! w              " auto-save changes when leaving focus


""""""""""""""""""""""""""""""""""""""""""""""""
" syntax highlighting
""""""""""""""""""""""""""""""""""""""""""""""""
" hightlight cursor location
if v:version >= 700
    "The following are a bit slow for me to enable by default
    "set cursorline   "highlight current line
    "set cursorcolumn "highlight current column
endif
" syntax highlighting if appropriate
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
    set incsearch   " for fast terminals can highlight search string as you type
endif
" .diff files
if &diff
    syntax off      " only interested in diff colours
endif
" syntax highlight shell scripts as per POSIX; not the original Bourne shell which very few use
let g:is_posix = 1
" flag problematic whitespace (trailing and spaces before tabs)
" note you get the same by doing let c_space_errors=1 but this rule really applys to everything.
highlight RedundantSpaces term=standout ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/ "\ze sets end of match so only spaces highlighted
" use :set list! to toggle visible whitespace on/off
set listchars=tab:>-,trail:.,extends:>


""""""""""""""""""""""""""""""""""""""""""""""""
" plugins
""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()
filetype plugin indent on

""""""""""""""""""""""""""""""""""""""""""""""""
" colours / themes
""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256                        " enable 256-color terminal support
set background=dark                 " use a dark background
try
    let g:solarized_termcolors=256  " enable theme's 256-color terminal support
    let g:solarized_termtrans=1     " use terminal's background instead of theme's
    colorscheme solarized           " set theme
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme desert
endtry
highlight TabLineSel     term=bold cterm=bold gui=bold
highlight TabLine        ctermfg=Grey ctermbg=NONE term=reverse cterm=reverse gui=reverse
highlight TabLineFill    ctermfg=Grey
highlight StatusLine     ctermfg=Grey ctermbg=NONE guifg=NONE guibg=NONE

