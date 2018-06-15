# include("../display/display.jl")

include("./TreeViews.jl")

struct JunoDisplay <: Display end

struct JunoEditorInput
  x::Any
end

Base.Multimedia.pushdisplay(JunoDisplay())

plotpaneioctxt(io::IO) = IOContext(io, juno_plotsize = Juno.plotsize(), juno_colors = Juno.syntaxcolors())

function displayinplotpane(x)
  didDisplay = true

  io = IOBuffer()
  if mimewritable("image/png", x)
    show(plotpaneioctxt(io), "image/png", x)
    Juno.render(Juno.PlotPane(), HTML("<img src=\"data:image/png;base64,$(String(take!(io)))\">"))
  elseif mimewritable("application/juno+plotpane", x)
    show(plotpaneioctxt(io), "application/juno+plotpane", x)
    str = String(take!(io))
    Juno.render(Juno.PlotPane(), HTML(str))
  else
    didDisplay = false
  end
  didDisplay
end

# input from anywhere not the editor (e.g. REPL)
function Base.display(d::JunoDisplay, x)
  displayinplotpane(x)
  # need to be a bit more intelligent about finding the REPL display
  display(Base.Multimedia.displays[2], x)
end

# input from in-editor eval
function Base.display(d::JunoDisplay, wrapper::JunoEditorInput)
  x = wrapper.x
  displayinplotpane(x)

  TreeViews.hastreeview(x) ?
                  treeview(d, x) :
                  sprint(io -> show(IOContext(io, limit = true), MIME"text/plain"(), x))
end

function treeview(d::JunoDisplay, x)
  t =  Juno.Tree(TreeViews.treelabel(x, MIME"application/juno+inline"()),
                [SubTree(TreeViews.treelabel(x, i, MIME"application/juno+inline"()),
                 TreeViews.treenode(x, i)) for i in 1:TreeViews.numtreenodes(x)])

  Juno.render(Juno.Inline(), t)
end

treeview(d::JunoDisplay, x) = render(Inline(), x)



TreeViews.hastreeview(f::Function) = true
TreeViews.treelabel(f::Function, ::MIME"application/juno+inline") = isanon(f) ?
                                                                    span(".syntax--support.syntax--function", "λ") :
                                                                    span(".syntax--support.syntax--function", string(typeof(f).name.mt.name))
TreeViews.numtreenodes(f::Function) = isanon(f) ? 0 : 1
function TreeViews.treenode(f::Function, i)
  if i == 1
    [(Atom.CodeTools.hasdoc(f) ? [doc(f)] : [])..., methods(f)]
  end
end

TreeViews.treelabel(f::Function, i::Int, ::MIME"application/juno+inline") = HTML("Docs")

TreeViews.hastreeview(::Void) = true
TreeViews.treelabel(::Void, ::MIME"application/juno+inline") = icon("check")
