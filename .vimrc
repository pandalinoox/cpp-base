let s:cxx = 'g++ -std=c++20 -g -Wall -Wextra -Wshadow -DLOCAL -D_GLIBCXX_DEBUG -fsanitize=address,undefined'
let s:time_limit = 5

set autoread

let s:template =<< trim END
#include <bits/stdc++.h>
using namespace std;

#ifdef LOCAL
#define dbg(x) cerr << "[" << #x << "] = " << (x) << endl
#else
#define dbg(x)
#endif

void solve() {
  //woa so much intelligence
}

int main() {
  ios::sync_with_stdio(false);
  cin.tie(nullptr);

  int t = 1;
  // cin >> t;
  while (t--)
    solve();

  return 0;
}
END

function! s:ReloadWin(file) abort
  let l:win = bufwinid(bufnr(fnamemodify(a:file, ':p')))
  if l:win != -1
    let l:cur = win_getid()
    call win_gotoid(l:win)
    silent! edit!
    call win_gotoid(l:cur)
  endif
endfunction

function! CPPLayout() abort
  silent! only
  edit main.cpp
  rightbelow vsplit input.txt
  rightbelow split output.txt
  wincmd h
  execute 'vertical resize ' . (&columns * 6 / 10)
  call search('^void solve')
  normal! j
endfunction

command! CPPLayout call CPPLayout()

function! ResetTemplate() abort
  if confirm('Reset main.cpp, input.txt and output.txt?', "&Yes\n&No", 2) != 1
    return
  endif

  call writefile([], 'input.txt')
  call writefile([], 'output.txt')

  let l:win = bufwinid(bufnr(fnamemodify('main.cpp', ':p')))
  if l:win != -1
    call win_gotoid(l:win)
  else
    edit main.cpp
  endif

  silent %delete _
  call setline(1, s:template)
  call search('^void solve')
  normal! j

  call s:ReloadWin('input.txt')
  call s:ReloadWin('output.txt')
endfunction

command! ResetTemplate call ResetTemplate()
nnoremap <silent> <leader>rt :ResetTemplate<CR>

function! CompileRun() abort
  silent! wall

  let l:out = system(s:cxx . ' main.cpp -o main 2>&1')

  if v:shell_error
    call writefile(['--- Compilation Error ---'] + split(l:out, "\n"), 'output.txt')
    call s:ReloadWin('output.txt')
    echohl ErrorMsg | echo 'Compilation failed' | echohl None
    return
  endif

  let l:err = tempname()
  let l:to = (s:time_limit > 0 && executable('timeout')) ? 'timeout ' . s:time_limit . 's ' : ''
  let l:t0 = reltime()

  call system(l:to . './main < input.txt > output.txt 2> ' . shellescape(l:err))

  let l:code = v:shell_error
  let l:ms = float2nr(reltimefloat(reltime(l:t0)) * 1000)

  let l:dbg = filereadable(l:err) ? readfile(l:err, '', 200) : []

  if !empty(l:dbg)
    call writefile(['', '--- stderr ---'] + l:dbg, 'output.txt', 'a')
  endif

  if l:code == 124
    call writefile(['', '--- Time Limit Exceeded ---'], 'output.txt', 'a')
  elseif l:code == 136
    call writefile(['', '--- Runtime Error: SIGFPE (Arithmetic Exception) ---'], 'output.txt', 'a')
  elseif l:code == 134
    call writefile(['', '--- Runtime Error: SIGABRT ---'], 'output.txt', 'a')
  elseif l:code == 139
    call writefile(['', '--- Runtime Error: SIGSEGV (Segmentation Fault) ---'], 'output.txt', 'a')
  endif

  call delete(l:err)

  call s:ReloadWin('output.txt')

  if l:code == 0
    echohl MoreMsg | echo printf('OK (%d ms)', l:ms) | echohl None
  elseif l:code == 124
    echohl ErrorMsg | echo printf('Time limit exceeded (> %ds)', s:time_limit) | echohl None
  else
    echohl ErrorMsg | echo printf('Runtime error (exit code %d, %d ms)', l:code, l:ms) | echohl None
  endif
endfunction

command! CompileAndRun call CompileRun()

cnoreabbrev <expr> q  (getcmdtype() ==# ':' && getcmdline() ==# 'q')  ? 'qa'  : 'q'
cnoreabbrev <expr> wq (getcmdtype() ==# ':' && getcmdline() ==# 'wq') ? 'wqa' : 'wq'

augroup cp_local
  autocmd!
  autocmd VimEnter * nested call CPPLayout()
  autocmd BufEnter * nnoremap <buffer> <nowait> <silent> <C-'> :CompileAndRun<CR>
augroup END
