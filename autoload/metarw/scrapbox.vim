let s:save_cpo = &cpo
set cpo&vim

function! s:build_endpoint_url(resource)
  return printf('https://scrapbox.io/api/%s', a:resource)
endfunction

" TODO 
function! s:get_scrapbox_page(project, page)
  let resource = printf('%s/%s/text', a:project, a:page)
  let url = s:build_endpoint_url(resource)
  let res = webapi#http#get(url)

  if res.status == 200
    return webapi#json#decode(res.content)
  else
    return ['error', string(webapi#json#decode(res.content))]
  endif
endfunction

function! s:list_scrapbox_pages(project)
  let resource = printf('pages/%s', a:project)
  let url = s:build_endpoint_url(resource)
  let res = webapi#http#get(url)

  if res.status == 200
    let pages = get(webapi#json#decode(res.content), 'pages', [])
    let list = map(pages, '{"label": v:val.title, "fakepath": "scrapbox:" . a:project . "/" . v:val.title}')

    return ['browse', list]
  else
    return ['error', string(webapi#json#decode(res.content))]
  endif
endfunction

function! metarw#scrapbox#read(fakepath)
  let fragments = split(a:fakepath, 'scrapbox:')

  " FIXME 
  if len(fragments) < 1
    return ['error', printf('Unexpected fakepath: %s', string(fragments))]
  endif

  let paths = split(fragments[0], '/')
  if len(paths) == 2
    return ['error', 'not implemented']
  else
    return s:list_scrapbox_pages(paths[0])
  endif
endfunction 

" TODO
function! metarw#scrapbox#complete(arglead, cmdline, cursorpos)

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
