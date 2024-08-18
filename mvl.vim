vim9script
# MVL.vim: vim utily plugin for my vim-life
# Last Changed: 2024-08-03 Sat 21:12:15
# Maintainer: Tak Mutoh
# License: This files is placed in the public domain.

if exists("g:loaded_mvl")
	finish
endif
g:loaded_mvl = 1

## Scratch Buffer
def MakeScratchBuffer()
	var nnew = ':15new'
	if winheight(0) < 30
		nnew = ':new'
	endif
	silent! execute nnew 'scratch'
	setlocal buftype=nofile
	setlocal noswapfile
enddef

if !exists(":Scratch")
	command -nargs=0 Scratch :call MakeScratchBuffer()
endif

## Convert Full-width Number / Half-width Number
def ConvHZ(sw: number, line1: number, line2: number)
	var h = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
	var z = ['０', '１', '２', '３', '４', '５', '６', '７', '８', '９']

	var s: string
	for l in range(line1, line2)
		for i in range(10)
			if sw == 1
				s = substitute(getline(l), h[i], z[i], 'g')
			else
				s = substitute(getline(l), z[i], h[i], 'g')
			endif
			setline(l, s)
		endfor
	endfor
enddef

if !exists(":Zenkaku")
	command -nargs=0 -range Zenkaku :call ConvHZ(1, <line1>, <line2>)
endif

if !exists(":Hankaku")
	command -nargs=0 -range Hankaku :call ConvHZ(2, <line1>, <line2>)
endif

## Uniq
def DoUniq(line1: number, line2: number, flg_cnt: bool)
	var txt = []
	var cnt = {}

	for l in range(line1, line2)
		var k = getline(l)
		if has_key(cnt, k)
			cnt[k] += 1
		else
			add(txt, getline(l))
			cnt[k] = 1
		endif
	endfor

	var nr = bufwinnr('uniq_result')
	if nr > 0
		silent! execute ':' .. nr .. 'wincmd c'
	endif

	silent! execute ':new' 'uniq_result'
	setlocal buftype=nofile
	setlocal noswapfile

	if flg_cnt
		var n_txt = []
		for [k, v] in items(cnt)
			add(n_txt, printf("%10d ", v) .. k)
		endfor
		var sn_txt = reverse(sort(n_txt))
		for i in range(len(sn_txt))
			setline(i + 1, sn_txt[i])
		endfor
	else
		for i in range(len(txt))
			setline(i + 1, txt[i])
		endfor
	endif

enddef

if !exists(":Uniq")
	command -nargs=0 -range Uniq :call DoUniq(<line1>, <line2>, false)
endif

if !exists(":UniqCount")
	command -nargs=0 -range UniqCount :call DoUniq(<line1>, <line2>, true)
endif

## Cut
def CutCSV(line1: number, line2: number, ...cols: list<string>)
	var out = []
	for l in range(line1, line2)
		var records = split(getline(l), ',', 1)
		var s: string
		for i in range(len(cols))
			var c = str2nr(cols[i])
			s = s .. "," .. records[c - 1]
		endfor
		add(out, substitute(s, ",", "", ""))
	endfor

	var nr = bufwinnr('cut_result')
	if nr > 0
		silent! execute ':' .. nr .. 'wincmd c'
	endif

	silent! execute ':new' 'cut_result'
	setlocal buftype=nofile
	setlocal noswapfile

	for i in range(len(out))
		setline(i + 1, out[i])
	endfor
enddef

if !exists(":Cut")
	command -nargs=+ -range Cut :call CutCSV(<line1>, <line2>, <f-args>)
endif

