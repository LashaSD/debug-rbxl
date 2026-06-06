set makeprg=./scripts/editor-analyze.sh
set efm+=%f\\(%l\\,%c\\):\ %t%*[^:]:\ %m
noremap <Leader>s :make<CR>
noremap <Leader>c :!./scripts/sourcemap.sh<CR>
command! RestartLsp lua vim.lsp.enable("luau-lsp", false); vim.lsp.enable("luau-lsp");
command! StopLsp lua vim.lsp.enable("luau-lsp", false);
