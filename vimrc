"Numbers
set nu

"Pasting to clipboard - needs +clipbound in 'vim --version' (needs Xserver)
"sudo apt-get install vim-gtk or vim-gnome comes with +clipboard
set clipboard=unnamed     "linux
"set clipboard=unnamedplus  "windows

"Moves to search as typing
set incsearch

"Highlights
set hlsearch

"Allows closing/navigating of buffers if unsaved
set hidden

"Splits new window right
set splitright

"Shows matching ()[]
set noshowmatch
let loaded_matchparen = 1

"Sets indent to 4 spaces and only uses spaces
"To insert a literal tab, first press Ctrl-v and then press Tab (or our keybind S-Tab).
set softtabstop=4  "Simulates tab key to go X on tab AND backspace
set shiftwidth=4   "When using > < for shifting Ident
set tabstop=8      "Default for vim and many programs (only change if using noexpandtab)
set expandtab      "Sets tab key to insert spaces
set smarttab
set autoindent

function TabToggle()
  if &expandtab        "If using default, switch to tabs (uses tabs but looks like tab = 4 spaces)
    set tabstop=4
    set noexpandtab
    echom 'Set to Tab Ident'
  elseif &tabstop == 4  "If using tabs, switch to mixed (ident is 4 spaces, 2 ident = tab)
    set tabstop=8
    echom 'Set to Mixed Ident'
  else
    set expandtab       "Switch back to default (ident is 4 spaces, only spaces no tabs)
    echom 'Set to Default Ident'
  endif
endfunction

"vims global update time - for gitgutter
set updatetime=1000

":[cmdtxt]<Tab> shows list of commands 
set wildmenu                       
set wildmode=list:longest,full 

"The number of screen lines to keep above and below the cursor
set scrolloff=2

"Always show status bar
set laststatus=2

"Prevent automatic linebreak (":set nolist" changes these values from default)
set textwidth=0
set wrapmargin=0

syntax on


""Set the format for file
"set ff=unix
"set ff=dos
"set ff=mac

""Automatically re-read files if unmodified inside Vim
"set autoread


"================ Mappings ======================
"nnoremap <Leader>e :33Lexplore<CR>
nnoremap <Leader>e :NERDTreeToggleVCS %<CR><C-w><C-p>
nnoremap <Leader>E :e $MYVIMRC<CR>
nnoremap <Leader>EE :so $MYVIMRC<CR>
nnoremap <Leader>r :set hls!<CR>
nnoremap <Leader>c :set relativenumber!<CR>
nnoremap <Leader>R :NERDTreeRefreshRoot<CR>:NERDTreeRefreshRoot<CR>
nnoremap <Leader>f :vimgrep /
nnoremap <Leader>FF :FZF<CR>
nnoremap <Leader>A :Ag<CR>
nnoremap <Leader>F :NERDTreeFind<CR>
nnoremap <Leader>t :tabnew
nnoremap <Leader>H :tab h 
nnoremap <Leader>/ :set formatoptions-=cro<CR>
nnoremap <Leader>// :set formatoptions+=cro<CR>
nnoremap <Leader>p :set paste<CR>
nnoremap <Leader>pp :set nopaste<CR>
nnoremap <Leader>g :GitGutter<CR>
nnoremap <Leader>d :Git<CR><C-w>L<CR>
nnoremap <Leader>D :tab Git diff --cached
nnoremap <Leader>s :NERDTreeClose<CR>:mks!<CR>:NERDTreeToggleVCS %<CR><C-w><C-p>
nnoremap <Leader>l :source Session.vim<CR>
nnoremap ,, :bn<CR>
nnoremap ,p :bp<CR>
nnoremap ,d :bd<CR>
nnoremap ,D :bn\|bd #<CR>
nnoremap ,n :cn<CR>
nnoremap ,N :cp<CR>
nnoremap '' "+

inoremap jj <Esc>
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-d> <Del>
inoremap <S-Tab> <C-V><Tab>

vnoremap mm "0p
vnoremap '' "+y

cnoremap <C-j> <Left>
cnoremap <C-k> <Right>


"mz marks line, 'z returns to mark, as execute goes to top of file
nnoremap <F9> mz:execute TabToggle()<CR>'z
nnoremap ]c :pclose<CR>:GitGutterNextHunk<CR>:GitGutterPreviewHunk<CR>
nnoremap [c :pclose<CR>:GitGutterPrevHunk<CR>:GitGutterPreviewHunk<CR>

"Add/remove entries from quicklist
"https://stackoverflow.com/a/51962260

"================ Commands ======================
"# Write to file with sudo
command! SW execute "silent! :w !sudo tee %" <bar> edit!

"# Write to file, run command silently, and redraw vim
command! WE execute ":w <bar> silent! :!bash %" <bar> redraw!
"# Write to file, run command silently with req args, and redraw vim
command! -nargs=1 WW execute ":w <bar> silent! :!bash % <args>" <bar> redraw!

"Edit a remote file
":e scp://USER@SERVER/RELATIVE/TO/USER/HOME/PATH

"To add browsable hunks to quickfix list
":GitGutterQuickFix


"Download vim-plug:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"=============== Plugins Start ===============
call plug#begin('~/.vim/plugged')




"===== Nav ====="
"File Explorer
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

"Fuzzy finder
"==== REQUIRES ag --- sudo apt-get install silversearcher-ag
"==== SEE $FZF_DEFAULT_COMMAND in this file
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'



"====== Display =====
"Git status highlighting
Plug 'airblade/vim-gitgutter'

"Git diff in vim
Plug 'tpope/vim-fugitive'

"Vim status bar
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'mengelbrecht/lightline-bufferline'

"Monokai theme
Plug 'crusoexia/vim-monokai'



"====== Syntax Highlight =====
Plug 'OmniSharp/omnisharp-vim'   "C#
Plug 'maxmellon/vim-jsx-pretty'  "jsx 
Plug 'jvirtanen/vim-hcl'         "HCL
Plug 'yuezk/vim-js'              "js
"Plug 'pangloss/vim-javascript'  "js

"Syntax linter
Plug 'dense-analysis/ale'




"Plug 'ryanoasis/vim-devicons'
"===================== Plugins End ===============
call plug#end()






"====== fzf ======
"let $FZF_DEFAULT_OPTS = ""
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore node_modules --ignore .git -l -g ""'


"====== vim-jsx-pretty =====
let g:vim_jsx_pretty_colorful_config = 1



"===== ALE =====
let g:ale_completion_enabled = 1
"https://github.com/dense-analysis/ale/issues/1536
"Cursor disappears when over error, either delay or disable echo to fix
let g:ale_echo_delay = 250

"===== OmniSharp =====
let g:OmniSharp_translate_cygwin_wsl = 1
set completeopt=longest,menuone,preview
"+++++ ALE +++++
let g:ale_linters = { 'cs': ['OmniSharp'] }
set omnifunc=ale#completion#OmniFunc



"======= NERDTree ======
let g:NERDTreeShowHidden = 1
let NERDTreeIgnore=['\.vim$', '\~$', '\.csproj$', '\.meta$', '\.sln$', '\.asset$', '\.cache$' ]
let g:NERDTreeMinimalUI = 1
"let g:NERDTreeMinimalMenu = 1
"let NERDTreeAutoDeleteBuffer = 1



"====== nerdtree-git-plugin =====
"let g:NERDTreeGitStatusUseNerdFonts = 0
"set encoding=utf-8
let g:NERDTreeGitStatusShowIgnored = 1
let g:NERDTreeGitStatusConcealBrackets = 0
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'*',
                \ 'Staged'    :'+',
                \ 'Untracked' :'!',
                \ 'Renamed'   :'R',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'x',
                \ 'Dirty'     :'~',
                \ 'Ignored'   :'I',
                \ 'Clean'     :'C',
                \ 'Unknown'   :'?',
                \ }



"====== vim-gitgutter =====
set signcolumn=yes
let g:gitgutter_set_sign_backgrounds = 1
highlight SignColumn      guibg=#dd4814 ctermbg=232
highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1
"let g:gitgutter_preview_win_floating = 1



"==== vim-lightline =====
let g:lightline#bufferline#show_number = 1
let g:lightline#bufferline#min_buffer_count = 1
let g:lightline = {
\ 'colorscheme': 'molokai',
\ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitbranch', 'readonly', 'relativepath', 'modified' ] ]
  \ },
  \ 'tabline': {
  \   'left': [ ['buffers'] ],
  \   'right': [ ['tabs'] ]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'gitbranch#name'
  \ },
  \ 'component_expand': {
  \   'buffers': 'lightline#bufferline#buffers'
  \ },
  \ 'component_type': {
  \   'buffers': 'tabsel'
  \ }
\ }



"Forgot why necessary at bottom
colorscheme monokai

"============== Bottom ===============


"========== Unused/saved configs ========

"==== vim-devicons ====
"let g:webdevicons_enable = 0
"let g:webdevicons_enable_nerdtree = 0
" adding to vim-airline's tabline
"let g:webdevicons_enable_airline_tabline = 0
" adding to vim-airline's statusline
"let g:webdevicons_enable_airline_statusline = 0
"let g:WebDevIconsNerdTreeGitPluginForceVAlign = 0

"==== vim-airline ======
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#formatter = 'unique_tail'
""++++ ale +++++
"let g:airline#extensions#ale#enabled = 1

"=== syntastic ====
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0

""==== Netrw ====
""Sets netrw to tree view
"let g:netrw_liststyle=3
"
""Dont open files in same split as netrw/2nd window
"let g:netrw_chgwin=2
"let g:netrw_altv=1
"
""Remove banner
"let g:netrw_banner = 0
"let g:netrw_winsize = 33
"
""Ignore casing in sort
"let g:netrw_sort_options="i"
"
""Sets to use previous window instead of set window
""let g:netrw_browse_split = 4

"======== Misc =======
"Addressing Enter or CMD to continue
"let g:netrw_silent = 1
"set noautowrite
"set confirm
