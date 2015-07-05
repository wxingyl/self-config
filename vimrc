runtime! debian.vim
"设置编码
set encoding=utf-8
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
set fileencodings=utf-8,ucs-bom,chinese
set tags=ctags
 
"语言设置
set langmenu=zh_CN.UTF-8
 
"设置语法高亮
syntax enable
syntax on
 
 
"可以在buffer的任何地方使用鼠标
set mouse=a
set selection=exclusive
set selectmode=mouse,key
 
"高亮显示匹配的括号
set showmatch
 
"去掉vi一致性
set nocompatible
 
"设置缩进
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set cindent
if &term=="xterm"
    set t_Co=8
    set t_Sb=^[[4%dm
    set t_Sf=^[[3%dm
endif
 
"打开文件类型自动检测功能
filetype on
 
"设置taglist
let Tlist_Show_One_File=0   "显示多个文件的tags
let Tlist_File_Fold_Auto_Close=1 "非当前文件，函数列表折叠隐藏
let Tlist_Exit_OnlyWindow=1 "在taglist是最后一个窗口时退出vim
let Tlist_Use_SingleClick=1 "单击时跳转
let Tlist_GainFocus_On_ToggleOpen=1 "打开taglist时获得输入焦点
let Tlist_Process_File_Always=1 "不管taglist窗口是否打开，始终解析文件中的tag
 
"设置WinManager插件
let g:winManagerWindowLayout='FileExplorer|TagList'
nmap wm :WMToggle<cr>
map <silent> <F9> :WMToggle<cr> "将F9绑定至WinManager,即打开WimManager
 
"设置CSCOPE
set cscopequickfix=s-,c-,d-,i-,t-,e- "设定是否使用quickfix窗口显示cscope结果
 
"设置Grep插件
nnoremap <silent> <F3> :Grep<CR>
 
"设置一键编译
map <F6> :make<CR>
 
"设置自动补全
filetype plugin indent on   "打开文件类型检测
set completeopt=longest,menu "关掉智能补全时的预览窗口
 
"启动vim时如果存在tags则自动加载
if exists("tags")
    set tags=./tags
endif
 
"设置按F12就更新tags的方法
map <F12> :call Do_CsTag()<CR>
nmap <C-@>s :cs find s <C-R>=expand("<cword>")<CR><CR>:copen<CR>
nmap <C-@>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>c :cs find c <C-R>=expand("<cword>")<CR><CR>:copen<CR>
nmap <C-@>t :cs find t <C-R>=expand("<cword>")<CR><CR>:copen<CR>
nmap <C-@>e :cs find e <C-R>=expand("<cword>")<CR><CR>:copen<CR>
nmap <C-@>f :cs find f <C-R>=expand("<cfile>")<CR><CR>:copen<CR>
nmap <C-@>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>:copen<CR>
nmap <C-@>d :cs find d <C-R>=expand("<cword>")<CR><CR>:copen<CR>
function Do_CsTag()
        let dir = getcwd()
        if filereadable("tags")
            if(g:iswindows==1)
                let tagsdeleted=delete(dir."\\"."tags")
            else
                let tagsdeleted=delete("./"."tags")
            endif
            if(tagsdeleted!=0)
                echohl WarningMsg | echo "Fail to do tags! I cannot delete the tags" | echohl None
                return
            endif
        endif
         
        if has("cscope")
            silent! execute "cs kill -1"
        endif
         
        if filereadable("cscope.files")
            if(g:iswindows==1)
                let csfilesdeleted=delete(dir."\\"."cscope.files")
            else
                let csfilesdeleted=delete("./"."cscope.files")
            endif
            if(csfilesdeleted!=0)
                echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.files" | echohl None
                return
            endif
        endif
                                             
        if filereadable("cscope.out")
            if(g:iswindows==1)
                let csoutdeleted=delete(dir."\\"."cscope.out")
            else
                let csoutdeleted=delete("./"."cscope.out")
            endif
            if(csoutdeleted!=0)
                echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.out" | echohl None
                return
            endif
        endif
                                             
        if(executable('ctags'))
            "silent! execute "!ctags -R --c-types=+p --fields=+S *"
            silent! execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q ."
        endif
             
        if(executable('cscope') && has("cscope") )
            if(g:iswindows!=1)
                silent! execute "!find . -name '*.h' -o -name '*.c' -o -name '*.cpp' -o -name '*.java' -o -name '*.cs' > cscope.files"
            else
                silent! execute "!dir /s/b *.c,*.cpp,*.h,*.java,*.cs >> cscope.files"
            endif
            silent! execute "!cscope -b"
            execute "normal :"
                                                                     
            if filereadable("cscope.out")
                execute "cs add cscope.out"
            endif
        endif
endfunction
 
"设置默认shell
set shell=zsh
 
"设置VIM记录的历史数
set history=400
 
"设置当文件被外部改变的时侯自动读入文件
if exists("&autoread")
    set autoread
endif
 
"设置ambiwidth
set ambiwidth=double
 
"设置文件类型
set ffs=unix,dos,mac
 
"设置增量搜索模式
set incsearch
 
"设置静音模式
set noerrorbells
set novisualbell
 
"不要备份文件
set nobackup
set nowb
set hlsearch
set nu

set background=dark
"设置配色方案
colorscheme solarized
set nocp
let g:solarized_termcolors=256
"设置ctags
let Tlist_Ctags_Cmd="/usr/local/bin/ctags"
