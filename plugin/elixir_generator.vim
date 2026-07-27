function! Strip(input_string)
  return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" Generates the module code
function! ModuleFileString(...)
  let l:module_names = a:1
  let l:camel_cased_module_names = []

  for i in l:module_names
    let l:tmp = substitute(Strip(i), '\%(^\|_\)\(.\)', '\u\1', 'g')
    call add(l:camel_cased_module_names, l:tmp)
  endfor

  let l:module_chain = join(l:camel_cased_module_names, ".")
  let l:code = "defmodule " . l:module_chain . " do\n"
  let l:code = l:code . "  @moduledoc false\n"
  let l:code = l:code . "end\n"

  return l:code
endfunction

" Generates the test code
function! TestFileString(...)
  let l:module_names = a:1
  let l:camel_cased_module_names = []

  for i in l:module_names
    let l:tmp = substitute(Strip(i), '\%(^\|_\)\(.\)', '\u\1', 'g')
    call add(l:camel_cased_module_names, l:tmp)
  endfor

  let l:module_chain = join(l:camel_cased_module_names, ".")
  let l:alias = camel_cased_module_names[-1]
  let l:code = "defmodule " . l:module_chain . "Test do\n"
  let l:code = l:code . "  use ExUnit.Case\n"
  let l:code = l:code . "  alias " . l:module_chain . "\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "  describe \"solution/2\" do\n"
  let l:code = l:code . "    test \"returns indices of two numbers that add up to target\" do\n"
  let l:code = l:code . "      assert " . l:alias . ".solution([1, 2, 3], 5) == [1, 2]\n"
  let l:code = l:code . "    end\n"
  let l:code = l:code . "  end\n"
  let l:code = l:code . "end\n"

  return l:code
endfunction

function! ElixirGeneratorCreateModuleFile()
  let l:module_name = input('Type the path (e.g store/cart/item): ')
  let l:current_dir = getcwd()
  let current_index = 0

  let l:module_names = split(module_name, "/")

  " CREATES THE PRODUCTION CODE
  exec ":cd ./lib"

  for i in l:module_names
    let l:filename = Strip(tolower(i))

    if current_index != (len(l:module_names)-1)
      if !isdirectory(filename)
        exec ":!mkdir " . l:filename
      endif
      exec ":cd ./"   . l:filename
    else
      execute ":silent e " . l:filename . ".ex"
      let l:module_code = ModuleFileString(l:module_names)
      execute ":silent %delete"
      call setline(1, split(l:module_code, "\n"))
      execute ":w"
    endif
    let current_index += 1
  endfor

  exec ":cd " . l:current_dir

  " CREATES THE TEST CODE
  if isdirectory("test/lib")
    exec ":cd ./test/lib"
  else
    exec ":cd ./test"
  endif

  let current_index = 0
  for i in l:module_names
    let l:filename = Strip(tolower(i))

    if current_index != (len(l:module_names)-1)
      if !isdirectory(filename)
        exec ":!mkdir " . l:filename
      endif
      exec ":cd ./"   . l:filename
    else
      execute ":silent e " . l:filename . "_test.exs"
      let l:module_code = TestFileString(l:module_names)
      execute ":silent %delete"
      call setline(1, split(l:module_code, "\n"))
      execute ":w"
    endif
    let current_index += 1
  endfor

  exec ":cd " . l:current_dir
  execute ":redraw!"
endfunction

command! EX call ElixirGeneratorCreateModuleFile()
