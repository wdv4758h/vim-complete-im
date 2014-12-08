if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

function! DictComplete()

python << EOF

import vim
from os.path import expanduser
import cPickle as pickle
#import pickle
import sqlite3

line = vim.eval("getline('.')")
line_end = len(line)
start = int(vim.eval("col('.')")) - 1
end = start

# count start
while start > 0 and (line[start-1].isalpha() or line[start-1].isdigit()):
    start -= 1

# count end
while end < line_end and (line[end].isalpha() or line[end].isdigit()):
    end += 1

home = expanduser("~")
eat = False

table = "chewing"

if line.startswith(";"):
    table = "boshiamy"
    eat = True

# query

value = []
con = sqlite3.connect("{}/.vim/im-table.sqlite".format(home))
cur = con.cursor()
data = cur.execute("SELECT value FROM {} WHERE key=?".format(table), (line[start:end],)).fetchall()
for i in data:
    value.append(i[0])
cur.close()

if value:
    value = map(lambda x: x.encode('utf-8'), value) # for unicode in Python 2

    vim.command("call complete({}, {})".format(start+1-eat, value).decode('string_escape'))
    vim.command("return ''")

else:
    # do nothing, return space
    vim.command("return ' '")

EOF

endfunction

inoremap <space> <C-R>=DictComplete()<CR>
