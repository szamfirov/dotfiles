" URL: https://github.com/szamfirov/dotfiles/blob/master/.vimrc
" Author: szamfirov

execute pathogen#infect()

call plug#begin()
Plug '~/.fzf'
Plug 'preservim/nerdtree'
call plug#end()

colorscheme desert

"------------------------------------------------------------
" Features
set nocompatible

"------------------------------------------------------------
" Allow intelligent auto-indenting for each filetype
filetype indent plugin on

"------------------------------------------------------------
" Enable syntax highlighting
syntax on

"------------------------------------------------------------
" Must have options
set hidden

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

"------------------------------------------------------------
" Usability options
" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
"set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F8> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F8>

"------------------------------------------------------------
" Indentation options {{{1
set shiftwidth=4
set softtabstop=4
set expandtab

"------------------------------------------------------------
" Mappings
" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Mapping to toggle line numbers
noremap <F7> :set invnumber<CR>
inoremap <F7> <C-O>:set invnumber<CR>

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%81v.\+/
set colorcolumn=80

"------------------------------------------------------------
" Extra
" Cursor line
set cursorline
hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine ctermbg=LightGrey

" VimDiff
if &diff
    colorscheme darkblue
    "hi DiffText   cterm=none ctermfg=Black ctermbg=Red gui=none guifg=Black guibg=Red
    "hi DiffChange cterm=none ctermfg=Black ctermbg=LightMagenta gui=none guifg=Black guibg=LightMagenta
    highlight DiffAdd    term=bold         ctermbg=darkgreen ctermfg=white    cterm=bold guibg=DarkGreen  guifg=White    gui=bold
    highlight DiffText   term=reverse,bold ctermbg=red       ctermfg=white    cterm=bold guibg=DarkRed    guifg=White   gui=bold
    highlight DiffChange term=bold         ctermbg=black     ctermfg=white    cterm=bold guibg=Black      guifg=White    gui=bold
    highlight DiffDelete term=none         ctermbg=darkblue  ctermfg=darkblue cterm=none guibg=DarkBlue   guifg=DarkBlue gui=none
    highlight CursorLine ctermbg=none
endif

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Fuzzy finder
nmap ; :Buffers<CR>
nmap <Leader>r :Tags<CR>
nmap <Leader>t :Files<CR>

nnoremap <C-t> :NERDTreeToggle<CR>
