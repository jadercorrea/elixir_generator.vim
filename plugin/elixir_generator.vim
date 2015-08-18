function! Strip(input_string)
  return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" Generates the code for a given module
function! ModuleFileString(...)
  let l:module_names = a:1
  let l:code = ""

  let current_index = 0
  for i in l:module_names
    let l:module_name = substitute(Strip(i), '\%(^\|_\)\(.\)', '\u\1', 'g')
    let l:module_namespace = "defmodule"
    let l:code = l:code . l:module_namespace . " " . l:module_name . " do\n"
    let current_index += 1
  endfor

  let l:code = l:code . "\n"
  let l:code = l:code . "def some_method(opts \\\\ [])\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "def some_method(opts) when opts == [] do\n"
  let l:code = l:code . "{:ok}\n"
  let l:code = l:code . "end\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "def some_method(opts) do\n"
  let l:code = l:code . "{:ok, [opts]}\n"
  let l:code = l:code . "end\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "defp private_method do\n"
  let l:code = l:code . "{:ok}\n"
  let l:code = l:code . "end"

  for i in l:module_names
    let l:code = l:code . "\nend"
  endfor

  return l:code
endfunction

" Generates the test for a given module
function! TestFileString(...)
  let l:module_names = a:1
  let l:code = ""
  let l:camel_cased_module_names = []
  let l:alias = toupper(module_names[-1][0])

  for i in l:module_names
    let l:tmp = substitute(Strip(i), '\%(^\|_\)\(.\)', '\u\1', 'g')
    call add(l:camel_cased_module_names, l:tmp)
    echo l:camel_cased_module_names
    let l:module_chain = join(l:camel_cased_module_names, ".")
  endfor

  let l:code = l:code . "defmodule " . module_chain . "Test do\n"
  let l:code = l:code . "use ExUnit.Case, async: true\n"
  let l:code = l:code . "require " . module_chain . ", as: " . alias . "\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "test \"some method without param\" do\n"
  let l:code = l:code . "assert " . alias .".some_method == {:ok}\n"
  let l:code = l:code . "end\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "test \"some method with param\" do\n"
  let l:code = l:code . "assert " . alias .".some_method(1) == {:ok, [1]}"
  let l:code = l:code . "\nend"
  let l:code = l:code . "\nend"

  return l:code
endfunction

function! ElixirGeneratorCreateModuleFile()
  let l:module_name    = input('Type the path (e.g store/cart/item): ')
  let l:current_dir   = getcwd()
  let current_index = 0

  let l:module_names = split(module_name, "/")

  " CREATES THE PRODUCTION CODE

  " We're only creating these classes inside lib/
  exec ":cd ./lib"

  " Iterates over each namespace. If store/cart/item was entered, iterates
  " on store, cart and item, creating the subdirectories recursively if they
  " don't already exist.
  for i in l:module_names
    let l:filename = Strip(tolower(i))

    " If the current name is supposed to be a directory (e.g cart in
    " store/cart/item is supposed to be a file.
    if current_index != (len(l:module_names)-1)
      " creates directories recursively
      if !isdirectory(filename)
        exec ":!mkdir " . l:filename
      endif
      exec ":cd ./"   . l:filename

    " If the current name is supposed to be a file (e.g item is supposed
    " to be a file in store/cart/item)
    else
      " Creates the class file
      execute ":silent !touch " . l:filename . ".ex"
      " Opens it
      execute ":silent e " . l:filename . ".ex"
      " Populates it with the boilerplate code
      let l:module_code = ModuleFileString(l:module_names)
      execute ":silent normal cc" . l:module_code . "\<Esc>"
      " Saves the current file
      execute ":w"
    endif
    let current_index += 1
  endfor

  exec ":cd " . l:current_dir

  " CREATES THE TEST CODE

  " We're only creating these classes inside spec/lib/
  if isdirectory("test/lib")
    exec ":cd ./test/lib"
  else
    exec ":cd ./test"
  endif

  " Iterates over each namespace. If store/cart/item was entered, iterates
  " on store, cart and item, creating the subdirectories recursively if they
  " don't already exist.
  let current_index = 0
  for i in l:module_names
    let l:filename = Strip(tolower(i))

    " If the current name is supposed to be a directory (e.g cart in
    " store/cart/item is supposed to be a file.
    if current_index != (len(l:module_names)-1)
      " creates directories recursively
      if !isdirectory(filename)
        exec ":!mkdir " . l:filename
      endif
      exec ":cd ./"   . l:filename

    " If the current name is supposed to be a file (e.g item is supposed
    " to be a file in store/cart/item)
    else
      " Creates the class file
      execute ":silent !touch " . l:filename . "_test.exs"
      " Opens it in a horizontal split
      execute ":vsplit"
      execute ":wincmd l"
      execute ":e " . l:filename . "_test.exs"

      " Populates it with the boilerplate code
      let l:module_code = TestFileString(l:module_names)
      execute ":silent normal cc" . l:module_code . "\<Esc>"
      " Saves the current file
      execute ":w"
      execute ":wincmd h"
    endif
    let current_index += 1
  endfor

  exec ":cd " . l:current_dir
  execute ":redraw!"
endfunction

command! EX call ElixirGeneratorCreateModuleFile()
