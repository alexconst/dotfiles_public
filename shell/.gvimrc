"syntax on
"colorscheme elflord


set guifont=Monospace\ 11
" https://vi.stackexchange.com/questions/3093/how-can-i-change-the-font-size-in-gvim
" :set guifont=*
" :set guifont?


""""""""
" start maximized
" https://superuser.com/questions/140419/how-to-start-gvim-maximized
""""""""
function Maximize()
   " put your actual values below
   winpos 0 0
   set lines=999
   set columns=999
endfunction
autocmd GUIEnter * call Maximize()

