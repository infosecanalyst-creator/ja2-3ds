#!/usr/bin/env python3
"""docs/manual.txt -> src/sgp/n3ds/N3DS_Manual.h   ('# Chapter' starts a chapter, '== Title' a page)"""
import sys, json
src, dst = sys.argv[1], sys.argv[2]
pages, chapters, cur = [], [], None
for raw in open(src, encoding='utf-8').read().splitlines():
    if raw.startswith('# '):
        chapters.append([raw[2:].strip(), len(pages)]); continue
    if raw.startswith('== '):
        cur = [raw[3:].strip(), []]; pages.append(cur); continue
    if cur is not None: cur[1].append(raw.rstrip())
for t, lines in pages:
    while lines and not lines[-1]: lines.pop()
    assert len(lines) <= 25, (t, len(lines))
    for l in lines: assert len(l) <= 49 and all(32 <= ord(c) < 127 for c in l), (t, l)
q = lambda s: json.dumps(s)
out = ['// Generated from docs/manual.txt by tools/gen_manual.py -- edit the .txt', '#pragma once',
       'struct N3DSManualPage { const char* title; int n; const char* lines[25]; };',
       'static const N3DSManualPage kN3DSManual[] = {']
for t, lines in pages:
    out.append('  { %s, %d, { %s } },' % (q(t), len(lines), ', '.join(q(l) for l in lines) or '0'))
out.append('};')
out.append('static const int kN3DSManualPages = %d;' % len(pages))
out.append('struct N3DSManualChapter { const char* name; int page; };')
out.append('static const N3DSManualChapter kN3DSManualChapters[] = {')
out += ['  { %s, %d },' % (q(n), p) for n, p in chapters]
out.append('};')
out.append('static const int kN3DSManualChapterCount = %d;' % len(chapters))
open(dst, 'w').write('\n'.join(out) + '\n')
print(len(pages), 'pages,', len(chapters), 'chapters')
