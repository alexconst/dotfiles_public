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
let g:spelling_language = 'en_us'
set wildmenu                        " vim command mode completion
set wildmode=longest:full,full      " vim command mode completion
"set modelines=0
"set nomodeline


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
" leader
let mapleader=' '           " character to use for <leader> mappings
let maplocalleader = '  '   " character sequence to use for <localleader> mappings
" shorcuts to leave edit mode and enter command mode
inoremap jj <esc>l
inoremap jk <esc>
" paste toggle
set pastetoggle=<F2>
" spell check toggle
map <silent> <F5> :execute 'setlocal spell! spelllang=' . g:spelling_language <CR>
" open file under cursor in a new tab using F8 or gF
" NOTE: you can already do this with `Ctrl+w gf`
" NOTE: to open it in the same tab use `gf`
" https://unix.stackexchange.com/questions/74571/vim-shortcut-to-open-a-file-under-cursor-in-an-already-opened-window
" https://vim.fandom.com/wiki/Open_file_under_cursor
" https://vi.stackexchange.com/questions/3364/open-filename-under-cursor-like-gf-but-in-a-new-tab-or-split
map <F8> 0^vg_<c-w>gf1<c-w><c-w>
map gF 0^vg_<c-w>gf1<c-w><c-w>
" shift+J is for joining a line, so we map ctrl+j for breaking/newlining a line
nnoremap <C-J> i<CR><Esc>k$hl
" search for text visually selected
vnoremap <Bslash> y/<C-r>=substitute(@",'/','\\/','g')<CR><CR>
" clear the search buffer by typing ,/ (, is used instead of : because vim shannaningas will cause an annoying delay)
nmap <silent> ,/ :nohlsearch<CR>

""""""""""""""""""""""""""""
" make life easier shortcuts (may have to reconsinder these)
""""""""""""""""""""""""""""
" ctrl+s saves the current buffer
map <C-s> <Esc>:w<CR>
" in python: leader+b types in 'ipdb.set_trace()'
au FileType python nmap <Leader>b Oipdb.set_trace()<Esc>
" in markdown: ctrl+b makes text bold
au FileType markdown vnoremap <silent> <C-b> :<C-u>execute "'<,'>s/\\%V.*\\%V./**&**/g \| :nohlsearch"<CR>`>4l
" in markdown: ctrl+i makes text italic
au FileType markdown vnoremap <silent> <C-i> :<C-u>execute "'<,'>s/\\%V.*\\%V./_&_/g \| :nohlsearch"<CR>`>2l
" in markdown: ctrl+q makes text within tick quotes, NOTE: this is not ideal https://stackoverflow.com/questions/21806168/vim-use-ctrl-q-for-visual-block-mode-in-vim-gnome
au FileType markdown vnoremap <silent> <C-q> :<C-u>execute "'<,'>s/\\%V.*\\%V./`&`/g \| :nohlsearch"<CR>`>2l
" in markdown: <leader>m fixes Toc window (this is useful when loading a vim session, because due to a bug the location list gets nerfed out) (I had to use <bar> because Toc messes up). How to: open a session, while the cursor is on the broken toc window, press leader m
au FileType markdown nnoremap <buffer> <Leader>m :execute "wincmd w \| only \| Toc"<CR> <bar> :execute "wincmd w \| file"<CR>


""""""""""""""""""""""""""""""""""""""""""""""""
" tabs
""""""""""""""""""""""""""""""""""""""""""""""""
set showtabline=2
" increase max num of tabs (useful for vim -p ...)
set tabpagemax=100
" efficient way to cycle through buffers (using ctrl+shift+char, with char being N, P, C):
" https://unix.stackexchange.com/questions/631241/mapping-otherwise-conflicting-or-unmappable-keys-in-terminal-vim
nnoremap <silent> <ESC>[78;5u :bn<CR>
nnoremap <silent> <ESC>[80;5u :bp<CR>
nnoremap <silent> <ESC>[67;5u :bd<CR>
" efficient way to cycle through tabs:
nnoremap <silent> <C-p> :tabprevious<CR>
nnoremap <silent> <C-n> :tabnext<CR>
nnoremap <silent> <C-c> :tabclose<CR>
" shortcuts for moving a tab to the left or right:
nnoremap <silent> <C-h> :execute 'silent! tabmove ' . (tabpagenr()-2) <CR>
nnoremap <silent> <C-l> :execute 'silent! tabmove ' . (tabpagenr()+1) <CR>
" press gl to go to last tab; https://stackoverflow.com/questions/2119754/switch-to-last-active-tab-in-vim
let g:lasttab = 1
nnoremap gl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
" show tab number in vim (terminal):
" done using plugin https://github.com/mkitt/tabline.vim
" show tab number in gVim:
set guitablabel=\[%N\]\ %t\ %M


""""""""""""""""""""""""""""""""""""""""""""""""
" buffers
""""""""""""""""""""""""""""""""""""""""""""""""
au FocusGained,BufEnter * :silent! checktime    " check for and reload (or discard) external changes when Vim or the current buffer gains focus (could also use CursorMoved but that seems overkill)
"au FocusLost,WinLeave * :silent! w              " auto-save changes when leaving focus


""""""""""""""""""""""""""""""""""""""""""""""""
" browser integration / open links / search google
""""""""""""""""""""""""""""""""""""""""""""""""
" open link under cursor with gx
let g:netrw_browsex_viewer = 'firefox'
" workaround to be able to open links in source code files, https://github.com/vim/vim/issues/4738
nmap gx yiW:!xdg-open <cWORD><CR> <C-r>" & <CR><CR>

" search selected text with gw
" NOTE: gx doesn't work with markdown files because vim-markdown uses it
" https://vi.stackexchange.com/questions/9001/how-do-i-search-google-from-vim
function! GoogleSearch()
     let searchterm = getreg("g")
     silent! exec "silent! !firefox \"http://google.com/search?q=" . searchterm . "\" &"
endfunction
vnoremap gw "gy<Esc>:call GoogleSearch()<CR> :redraw!<CR>


""""""""""""""""""""""""""""""""""""""""""""""""
" plugins
""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin on
try
    execute pathogen#infect()
endtry

if match(&runtimepath, 'vim-markdown') != -1
    let g:vim_markdown_frontmatter = 1
    let g:vim_markdown_folding_disabled = 1
    "let g:vim_markdown_folding_level = 6
    let g:vim_markdown_toc_autofit = 1
    let g:vim_markdown_emphasis_multiline = 0
    let g:vim_markdown_toc_location = 'right'
    augroup bash
        au!
        au BufNewFile,BufRead *.sh,*.bash setlocal filetype=sh
    augroup END
    augroup markdown
        au!
        au BufNewFile,BufRead *.md,*.markdown :Toc
    augroup END
endif

function! ToggleNerdTreeOnPath()
    if exists("g:NERDTree") && g:NERDTree.IsOpen()
        NERDTreeClose
    elseif filereadable(expand('%'))
        NERDTreeFind
    else
        NERDTree
    endif
endfunction
if match(&runtimepath, 'nerdtree') != -1
    " show hidden files
    let NERDTreeShowHidden=1
    " toggle nerdtree tab on path of the current file
    nnoremap <leader>e :call ToggleNerdTreeOnPath()<CR>
    " Open the existing NERDTree on each new tab.
    "autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif
    " match nerdtree shortcut with my own shortcut for opening files (from grepping notes). Unfortunately only one shortcut is possible (so gF doesn't work here)
    let NERDTreeMapOpenInTab='<F8>'
endif

""""""""""""""""""""""""""""""""""""""""""""""""
" color and syntax tweaks / overrides
" NOTE: to avoid colorscheme overriding our colors we need to use `autocmd ColorScheme * hi`
""""""""""""""""""""""""""""""""""""""""""""""""
" hightlight cursor location
if v:version >= 700
    "The following are a bit slow for me to enable by default
    "set cursorline   "highlight current line
    "set cursorcolumn "highlight current column
endif
" search highlight
if &t_Co > 2 || has("gui_running")
    syntax enable   " needs to come before any colorscheme or syntax
    set hlsearch
    set incsearch   " for fast terminals can highlight search string as you type
endif
" syntax highlight shell scripts as per POSIX; not the original Bourne shell which very few use
let g:is_posix = 1
" work around for large files (eg: markdown files). It avoids error: redraw time exceeded syntax highlighting disabled
set redrawtime=10000

" help troubleshoot undesirable syntax highlight (comment it if not using it)
"map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" use a different color for the current match than for other matches
augroup procsearch
  autocmd!
  au CmdLineLeave * let b:cmdtype = expand('<afile>') | if (b:cmdtype == '/' || b:cmdtype == '?') | call timer_start(200, 'ProcessSearch') | endif
augroup END
function! ProcessSearch(timerid)
    let l:patt = '\%#' . @/
    if &ic | let l:patt = '\c' . l:patt | endif
    exe 'match ErrorMsg /' . l:patt . '/'
endfunc

" enable highlight for spellcheck in the terminal, https://vi.stackexchange.com/questions/15422/figure-out-which-dictionary-is-used-when-spell-checking
autocmd ColorScheme * hi SpellBad cterm=underline ctermfg=red
autocmd ColorScheme * hi SpellCap cterm=underline ctermfg=yellow
autocmd ColorScheme * hi SpellRare cterm=underline ctermfg=green
autocmd ColorScheme * hi SpellLocal cterm=underline ctermfg=magenta
" always highlight some keywords
autocmd Syntax * call matchadd('PostIt', '\<NOTE\>:\|\<TODO\>:\|\<TLDR\>:\|\<tldr\>:')     " au Syntax ensures matching happens for any new tabs/buffers
autocmd ColorScheme * highlight PostIt cterm=bold ctermbg=yellow ctermfg=red guibg=yellow guifg=red   " ensure colorscheme loading does not override this
" flag problematic whitespace (trailing whitespace and spaces before tabs)
autocmd Syntax * syn match RedundantSpaces /\s\+$\| \+\ze\t/ "\ze sets end of match so only spaces highlighted
autocmd ColorScheme * hi RedundantSpaces ctermbg=red guibg=red

" vimdiff colors (might tweak them later); from https://github.com/romainl/Apprentice/blob/master/colors/apprentice.vim
autocmd ColorScheme * hi DiffAdd ctermbg=235 ctermfg=108 cterm=reverse guibg=#262626 guifg=#87af87 gui=reverse
autocmd ColorScheme * hi DiffChange ctermbg=235 ctermfg=103 cterm=reverse guibg=#262626 guifg=#8787af gui=reverse
autocmd ColorScheme * hi DiffDelete ctermbg=235 ctermfg=131 cterm=reverse guibg=#262626 guifg=#af5f5f gui=reverse
autocmd ColorScheme * hi DiffText ctermbg=235 ctermfg=208 cterm=reverse guibg=#262626 guifg=#ff8700 gui=reverse
" if it starts becoming difficult looking at vimdiff output, it might be better to disable syntax highlight
"if &diff
"    syntax off
"endif

" diff files syntax highlight
" going for explicit colors instead of existing references (eg: hi def link diffFile Identifier) to avoid getting locked to the colorscheme
"" meta
autocmd ColorScheme * hi diffFile         term=bold cterm=bold gui=bold ctermfg=12 guifg=blue1
autocmd ColorScheme * hi diffIndexLine    term=bold cterm=bold gui=bold ctermfg=12 guifg=blue1
autocmd ColorScheme * hi diffOldFile      term=bold cterm=bold gui=bold ctermfg=12 guifg=blue1
autocmd ColorScheme * hi diffNewFile      term=bold cterm=bold gui=bold ctermfg=12 guifg=blue1
autocmd ColorScheme * hi diffLine         ctermfg=5  guifg=magenta4
autocmd ColorScheme * hi diffSubname      ctermfg=13 guifg=magenta1
"" changes
autocmd ColorScheme * hi diffAdded        ctermfg=10 guifg=green1
autocmd ColorScheme * hi diffRemoved      ctermfg=9  guifg=red1
autocmd ColorScheme * hi diffChanged      ctermfg=11 guifg=yellow1
autocmd ColorScheme * hi diffCommon       ctermfg=7  guifg=gray
"" other
autocmd ColorScheme * hi diffIdentica     ctermfg=7  guifg=gray
autocmd ColorScheme * hi diffCommen       ctermfg=7  guifg=gray
autocmd ColorScheme * hi diffOnly         ctermfg=11 guifg=yellow1
autocmd ColorScheme * hi diffDiffer       ctermfg=11 guifg=yellow1
autocmd ColorScheme * hi diffBDiffer      ctermfg=11 guifg=yellow1
autocmd ColorScheme * hi diffIsA          ctermfg=11 guifg=yellow1
autocmd ColorScheme * hi diffNoEOL        ctermfg=11 guifg=yellow1


"""""""""""""""""""""""""""""""""""""""""""""""""
" colorscheme
"""""""""""""""""""""""""""""""""""""""""""""""""
"" NOTE: due to solarized being installed as a plugin this section needs to come after pathogen is active
"" NOTE: to check how many colors your terminal emulator supports run: `tput colors`

set background=dark                 " use a dark background
" 24-bit color mode (16777216 colours)
if has('gui_running') || &term =~ '^\%(xterm-direct\|tmux-direct\)'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
    try
        colorscheme solarized8_high
    catch /^Vim\%((\a\+)\)\=:E185/
        colorscheme desert
    endtry
" 8-bit colour mode (256 colours)
else
    set t_Co=256                        " force 256-color terminal support
    try
        let g:solarized_termcolors=256  " enable theme's 256-color terminal support
        let g:solarized_termtrans=0     " if set to 1 it will use the terminal's background; if set to 0 it will use the theme's one
        "let g:solarized_contrast='high' " shifts some values up or down in order to expand or compress the tonal range displayed.
        "let g:solarized_diffmode='high'
        let g:solarized_brighter=1      " makes greys whiter
        colorscheme solarized           " set theme
    catch /^Vim\%((\a\+)\)\=:E185/
        colorscheme desert
    endtry
endif

" top and bottom bar lines
autocmd ColorScheme * hi TabLineSel     term=bold cterm=bold gui=bold
autocmd ColorScheme * hi TabLine        ctermfg=Grey ctermbg=NONE term=reverse cterm=reverse gui=reverse
autocmd ColorScheme * hi TabLineFill    ctermfg=Grey
autocmd ColorScheme * hi StatusLine     ctermfg=Grey ctermbg=NONE guifg=NONE guibg=NONE


