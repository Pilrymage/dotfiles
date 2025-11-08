" .ideavimrc is a configuration file for IdeaVim plugin. It uses
"   the same commands as the original .vimrc configuration.
" You can find a list of commands here: https://jb.gg/h38q75
" Find more examples here: https://jb.gg/share-ideavimrc


"" -- Suggested options --
" Show a few lines of context around the cursor. Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

" Do incremental searching.
set incsearch

" Don't use Ex mode, use Q for formatting.
map Q gq
" 基本移動
nnoremap u k
vnoremap u k
nnoremap e j
vnoremap e j
nnoremap n h
vnoremap n h
nnoremap i l
vnoremap i l

" 多行移動
nnoremap U 5k
vnoremap U 5k
nnoremap E 5j
vnoremap E 5j

" 行內移動
nnoremap N 0
vnoremap N 0
nnoremap I $
vnoremap I $

" 單字移動
nnoremap m e
vnoremap m e
nnoremap M E
vnoremap M E
nnoremap h b
vnoremap h b
nnoremap H B
vnoremap H B

" 編輯與模式切換
nnoremap ; :
nnoremap ` ~
nnoremap j u
nnoremap l i
nnoremap L I

" 搜尋
nnoremap k n
nnoremap K N

" --- Insert 模式的按鍵映射 ---
" 在 Insert 模式中，使用 <C-o> 可以暫時切換到 Normal 模式執行一個命令
inoremap <C-p> <C-o>k
inoremap <C-n> <C-o>j
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-a> <C-o>0
inoremap <C-e> <C-o>$
" --- 新增的單詞移動 (使用 Meta/Alt 鍵) ---
inoremap <M-f> <C-o>w
inoremap <M-b> <C-o>b
" --- 新增的編輯命令 ---
inoremap <C-d> <Delete>
inoremap <M-d> <C-o>dw
inoremap <M-Backspace> <C-o>db
inoremap <C-k> <C-o>d$
inoremap <C-y> <C-o>p
inoremap <C-t> <C-o>xp
" --- 取消或禁用 Vim 原有功能 ---
" <C-w> 在 Insert 模式下預設是向後刪除一個單詞，這與 Emacs 的行為一致，所以通常不需要重新映射。
inoremap <C-u> <Nop>


" --- Enable IdeaVim plugins https://jb.gg/ideavim-plugins

" Highlight copied text
" Commentary plugin


"" -- Map IDE actions to IdeaVim -- https://jb.gg/abva4t
"" Map \r to the Reformat Code action
"map \r <Action>(ReformatCode)

"" Map <leader>d to start debug
"map <leader>d <Action>(Debug)

"" Map \b to toggle the breakpoint on the current line
"map \b <Action>(ToggleLineBreakpoint)
