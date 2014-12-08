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

if line.startswith(";"):
    table = pickle.load(open("{}/.vim/im-table/boshiamy_table.p".format(home), "rb"))
    eat = True
else:
    table = pickle.load(open("{}/.vim/im-table/chewing_table.p".format(home), "rb"))

value = table.get(line[start:end])

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
