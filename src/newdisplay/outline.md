## API

Juno 1.0 makes full use of Base's display system instead of relying on Media.jl's
`render` methods. This makes it possible to support custom display in Juno without
any dependencies but also introduces some minor restrictions.

### Inline Display
This is only relevant for results displayed in the editor (e.g. when evaluating
a single line of code via `C-Enter`). Juno only supports to types of display
styles here, with `Plain Text` as the default:

#### Trees
Trees are defined by a simple API provided by TreeViews.jl and will be displayed
as a collapsible inline widget.

By default (i.e. if `treenode(x,i)` is not overloaded for the type in question),
Trees are displayed recursively.

TreeViews.jl API:

- `hastreeview(x)`
- `numtreenodes(x)`
- `treenode(x, i)`
- `treelabel(x, i)`
- `treelabel(x)`

#### Plain Text
If `hastreeview(x)` returns `false` for the type to be displayed, Juno falls back
to rendering plain text output provided by
```
show(IOContext(io, limit = true), MIME"text/plain"(), x)
```
If the string printed by that method contain line breaks, the result will be
rendered as a Tree with the output's first line as the header and the rest as it's
only node.

### Plot Pane Display
If the type to be displayed has `show` methods defined for `image/*` mimetypes,
then the type instance will be automatically be displayed in  the plot pane.
Limited customization is available via the `IOContext` passed to the `show`
methods, which provides the `juno_colors` and `juno_plotsize` entries:

- `juno_colors`:
  - `Dict{String, UInt32}` which provides certain colors from the current Atom
     color theme, e.g. `string`, `background` or `keyword`.
- `juno_plotsize`:
  - Array that contains the width and height of the plotpane in pixels.

For more extensive customization it is also possible to define a `show` method
for the `application/juno+plotpane` or `application/juno+plotpane-webview`
mimetypes. These are very similar to `text/html` with regard to the expected
output, but specific to Juno. The former mimetype should be used in almost all
cases since it will result in more performant display, but does *not* allow
embedded javascript. `application/juno+plotpane-webview` will render the provided
HTML in a `webview` container separate from Atom and can thus be used for truly
interactive display of Plots etc.



---------





Displays:
  - JunoEditorDisplay
  - JunoPlotPaneDisplay

Mimes:
  - mime"application/juno-inline" -> inline
  - mime"text/plain" -> inline

  - mime"application/juno-plot" -> plotpane
  - mime"text/html" -> plotpane
  - mime"image/xxx" -> plotpane
