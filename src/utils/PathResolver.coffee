class PathResolver
  ###
  Class for resolving pseudo-path notation.
  Currently supported notations are:
    //ClassName
    <bundle>//ClassName
    /<absolutepath>//ClassName
  ###

  parsePathRaw: (path, bundleSpec = null) ->

    nameParts = path.split '//'
    throw new Error("Not more than one // is allowed in widget name specification: #{ path }!") if nameParts.length > 2
    if nameParts.length == 2
      ns = nameParts[0]
      relativePath = nameParts[1]

      bundleSpec += '../' if ns and bundleSpec

      if ns.indexOf('/') == 0
        bundleSpec = ns.substr(1)
      else
        throw new Error("Unknown bundle for widget: #{ path }") if not bundleSpec?
        if ns != ''
          bundleParts = bundleSpec.split '/'
          nsParts = ns.split '/'

          startJ = bundleParts.length - nsParts.length
          for i in [0..nsParts.length-1]
            bundleParts[startJ+i] = nsParts[i]

          bundleSpec = bundleParts.join '/'
    else
      throw new Error("Unknown path: #{ path }")

    bundle: bundleSpec
    relativePath: relativePath



module.exports = PathResolver
