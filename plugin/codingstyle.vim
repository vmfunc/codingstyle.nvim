" Title:        codingstyle.nvim
" Description:  Epitech coding style for (neo)vim
" Maintainer:   hytracer <https://github.com/hytracer> 

function! codingstyle#CheckCStyle()
  " Get the path to the plugin directory
  let s:plugin_dir = fnamemodify(resolve(expand('<sfile>:p')), ':p:h')

  " Define the relative path to the JSON configuration file
  let config_file = s:plugin_dir . '/plugin/codingstyle.json'

  if !filereadable(config_file)
    echoerr "[CodingStyle]: Configuration file not found."
    return
  endif

  let config = json_decode(join(readfile(config_file), "\n"))

  " Get the current buffer content
  let lines = getline(1, '$')

  " Clear any previous signs with custom sign name
  call sign_unplace('*')

  " Define a custom sign for displaying style violation messages
  sign define CodingStyleSign text=● texthl=WarningMsg

  " Loop through the patterns array.
  for pattern_obj in config.patterns
    let pattern = pattern_obj.pattern
    let description = pattern_obj.description
    let correct_pattern = pattern_obj.correctPattern

    for j in range(0, len(lines) - 1)
      if match(lines[j], pattern) != -1 && match(lines[j], correct_pattern) == -1
        " Style violation detected, highlight the line or take some action
        call matchadd('Warning', '\%'.(j+1).'l')
        let sign_id = sign_place(0, '', 'CodingStyleSign', bufname(''), {'lnum': j+1, 'text': description})
        " echohl WarningMsg
        " echomsg "[CodingStyle]: " . description . " violation in line " . (j+1)
        " Add a comment on the right side of the line
        let comment = ' // [CodingStyle] ' . description
        let current_line = getline(j+1)
        let updated_line = current_line . comment
        call setline(j+1, updated_line)
      endif
    endfor
  endfor
  echomsg "[CodingStyle]: Lint complete, check signs/comments for more information."
endfunction

" Define a command to trigger the style checking.
command! CodingStyle call codingstyle#CheckCStyle()

