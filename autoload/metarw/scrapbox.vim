let s:save_cpo = &cpo
set cpo&vim

function! s:build_endpoint_url(resource)
  return printf('https://scrapbox.io/api/%s', a:resource)
endfunction

function! s:parse_incomplete_fakepath(fakepath)
  let fragments = split(a:fakepath, 'scrapbox:')

  " FIXME 
  if len(fragments) < 1
    echoerr printf('Unexpected fakepath: %s', a:fakepath)
    throw 'metarw:scrapbox'
  endif

  let _ = {}

  let paths = split(fragments[0], '/')
  if len(paths) == 2
    let _.project = paths[0]
    let _.page = paths[1]
    let _.page_given_p = !0
  else
    let _.project = paths[0]
    let _.page = ''
    let _.page_given_p = 0
  endif
  return _
endfunction
 
function! s:get_scrapbox_page(_)
  let resource = printf('pages/%s/%s/text', a:_.project, a:_.page)
  let url = s:build_endpoint_url(resource)
  let res = webapi#http#get(url)

  if res.status == 200
    return ['read', {-> res.content}]
  else
    return ['error', string(webapi#json#decode(res.content))]
  endif
endfunction

function! s:list_scrapbox_pages(_)
  let resource = printf('pages/%s', a:_.project)
  let url = s:build_endpoint_url(resource)
  let res = webapi#http#get(url)

  if res.status == 200
    let pages = get(webapi#json#decode(res.content), 'pages', [])
    let list = map(pages, '{"label": v:val.title, "fakepath": "scrapbox:" . a:_.project . "/" . v:val.title}')

    return ['browse', list]
  else
    return ['error', string(webapi#json#decode(res.content))]
  endif
endfunction

function! metarw#scrapbox#read(fakepath)
  let _ = s:parse_incomplete_fakepath(a:fakepath)

  if _.page_given_p
    return s:get_scrapbox_page(_)
  else
    return s:list_scrapbox_pages(_)
  endif
endfunction 

" TODO
function! metarw#scrapbox#complete(arglead, cmdline, cursorpos)

endfunction

function! metarw#scrapbox#write(fakepath, line1, line2, append_p)
  return ['error', 'Writing to Scrapbox is not supported']
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
