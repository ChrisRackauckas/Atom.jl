edit(pkg) =
  isdir(Pkg.dir(pkg)) ?
    run(`atom $(Pkg.dir(pkg))`) :
    error("$pkg not installed")

isuntitled(p) = occursin(r"^(\.\\|\./)?untitled-[\d\w]+(:\d+)?$", p)

appendline(path, line) = line > 0 ? "$path:$line" : path

function realpath′(p)
  try
    ispath(p) ? realpath(p) : p
  catch e
    p
  end
end

function basepath(file)
  srcdir = joinpath(Sys.BINDIR,"..","..","base")
  releasedir = joinpath(Sys.BINDIR,"..","share","julia","base")
  normpath(joinpath(isdir(srcdir) ? srcdir : releasedir, file))
end

fullpath(path) =
  (isuntitled(path) || isabspath(path) ? path : basepath(path)) |> realpath′

function pkgpath(path)
  m = match(r"([^/\\]+[/\\]src[/\\].*)$", path)
  m == nothing ? basename(path) : m.captures[1]
end

expandpath(path) =
  isempty(path) ? (path, path) :
    path == "./missing" ? ("<unknown file>", path) :
      isuntitled(path) ? ("untitled", path) :
        !isabspath(path) ? (normpath(joinpath("base", path)), basepath(path)) :
          occursin(joinpath("julia", "stdlib"), path) ?
            begin
              p = last(split(path, joinpath("julia", "stdlib", "")))
              return (normpath(joinpath("stdlib", p)), normpath(joinpath(basepath(joinpath("..", "stdlib")), p)))
            end :
            (pkgpath(path), path)

function baselink(path, line)
  name, path = expandpath(path)
  name == "<unkown file>" ? span(".fade", "<unknown file>") :
                            link(path, line, Text(appendline(name, line)))
end
