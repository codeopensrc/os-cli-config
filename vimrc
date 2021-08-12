"Numbers
set nu

"Pasting to clipboard - needs +clipbound in vim --version (needs Xserver)
"set clipboard=unnamedplus  "windows
"sudo apt-get install vim-gtk or vim-gnome comes with +clipboard
set clipboard=unnamed     "linux

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

"Sets indent to 4
set softtabstop=4
set autoindent
set shiftwidth=4

"Set tab key to insert spaces
set expandtab
set smarttab

"vims global update time - for gitgutter
set updatetime=1000

":[cmdtxt]<Tab> shows list of commands 
set wildmenu                       
set wildmode=list:longest,full 


syntax on


" Misc possible configs to lookup
"set laststatus=2
"filetype plugin indent on
"set foldmethod=marker
"filetype on
"filetype plugin on
"syntax enable





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
nnoremap <Leader>d :tab Git diff
nnoremap ,, :bn<CR>
nnoremap ,p :bp<CR>
nnoremap ,d :bd<CR>
nnoremap ,D :bn\|bd #<CR>
nnoremap ,n :cn<CR>
nnoremap ,N :cp<CR>

inoremap jj <Esc>
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-d> <Del>


cnoremap <C-j> <Left>
cnoremap <C-k> <Right>


nnoremap ]c :pclose<CR>:GitGutterNextHunk<CR>:GitGutterPreviewHunk<CR>
nnoremap [c :pclose<CR>:GitGutterPrevHunk<CR>:GitGutterPreviewHunk<CR>

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
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -l -g ""'



"====== vim-jsx-pretty =====
let g:vim_jsx_pretty_colorful_config = 1



"===== ALE =====
let g:ale_completion_enabled = 1



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
"
"

colorscheme monokai
