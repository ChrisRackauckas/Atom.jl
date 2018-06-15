module TreeViews

export hastreeview, numtreenodes, treenode, treelabel

getfield′(x, s) = isdefined(x, s) ? getfield(x, s) : "undef"


hastreeview(x) = false

numtreenodes(x) = length(fieldnames(typeof(x)))

treenode(x, i) = getfield′(x, fieldname(typeof(x), i))

treelabel(x, mime::MIME=MIME"text/plain"()) = sprint(show, mime, typeof(x))

treelabel(x, i::Int, mime::MIME=MIME"text/plain"()) = sprint(show, mime, fieldname(typeof(x), i))

treeview(d::Display, x) = error("not implemented for display $d")

end
