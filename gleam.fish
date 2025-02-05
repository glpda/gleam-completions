# Fish Completions for Gleam

set -l commands add build check clean deps docs export fix format help hex lsp new publish remove run shell test update
set -l commands_with_help deps docs export hex
set -l targets erlang javascript
set -l runtimes nodejs deno bun

function __fish_gleam_project_root
    # get project root (parent dir with gleam.toml)
    for dir in (__fish_parent_directories (pwd --physical))
        if test -f $dir/gleam.toml
            echo $dir
            return 0
        end
    end
    return 1
end

function __fish_gleam_runnable_module
    # TODO list files under src and test with a main function
end

function __fish_gleam_deps_direct
    # 'gleam deps list' gives all dependencies but 'gleam remove' takes only
    # direct project dependencies listed in 'gleam.toml'
    if not set -l project_root (__fish_gleam_project_root)
        return 1
    end
    set -l current_table ''
    # does not properly escape "#" inside a string but it should not matter
    # since we only care about the keys (packages' names) and tables' names
    # and those should not contain any "#"
    string replace -r '#.*' '' <$project_root/gleam.toml | string trim \
    | while read -l line
        if string match -q '[*]' $line
            set current_table $line
        else if string match -q $current_table '[dependencies]' '[dev-dependencies]'
            set -f dependencies $dependencies \
            (string split -n -f1 "=" $line | string trim)
        end
    end
    printf '%s\n' $dependencies
    return 0
end

function __fish_gleam_deps_all
    # 'gleam deps list' gives an error when used outside a gleam project
    if set -l project_root (__fish_gleam_project_root)
        printf '%s\n' (gleam deps list | string split -f1 " ")
        return 0
    end
    return 1
end

function __fish_gleam_hex_packages
    # TODO list available hex packages
end

complete -c gleam --no-files

complete -c gleam -n __fish_use_subcommand -s V -l version -d 'Print version'

# Subcommands
complete -c gleam -n __fish_use_subcommand -a add     -d "Add new project dependencies"
complete -c gleam -n __fish_use_subcommand -a build   -d "Build the project"
complete -c gleam -n __fish_use_subcommand -a check   -d "Type check the project"
complete -c gleam -n __fish_use_subcommand -a clean   -d "Clean build artifacts"
complete -c gleam -n __fish_use_subcommand -a deps    -d "Work with dependency packages"
complete -c gleam -n __fish_use_subcommand -a docs    -d "Render HTML documentation"
complete -c gleam -n __fish_use_subcommand -a export  -d "Export from the Gleam project"
complete -c gleam -n __fish_use_subcommand -a fix     -d "Rewrite deprecated Gleam code"
complete -c gleam -n __fish_use_subcommand -a format  -d "Format source code"
complete -c gleam -n __fish_use_subcommand -a help    -d "Print help for the given subcommand(s)"
complete -c gleam -n __fish_use_subcommand -a hex     -d "Work with the Hex package manager"
complete -c gleam -n __fish_use_subcommand -a lsp     -d "Run the language server, to be used by editors"
complete -c gleam -n __fish_use_subcommand -a new     -d "Create a new project"
complete -c gleam -n __fish_use_subcommand -a publish -d "Publish the project to the Hex package manager"
complete -c gleam -n __fish_use_subcommand -a remove  -d "Remove project dependencies"
complete -c gleam -n __fish_use_subcommand -a run     -d "Run the project"
complete -c gleam -n __fish_use_subcommand -a shell   -d "Start an Erlang shell"
complete -c gleam -n __fish_use_subcommand -a test    -d "Run the project tests"
complete -c gleam -n __fish_use_subcommand -a update  -d "Update dependencies to their latest versions"

# Help
complete -c gleam -s h -l help -d 'Print help'
complete -c gleam -n "__fish_seen_subcommand_from help" -r -a "$commands"
complete -c gleam -n "__fish_seen_subcommand_from $commands_with_help" -a help -d "Print help"

# Compile: build check run test
complete -c gleam -n '__fish_seen_subcommand_from build check run test' -s t -l target -rf -a "$targets" -d "The platform to target"
complete -c gleam -n '__fish_seen_subcommand_from run test' -l runtime -rf -a "$runtimes" -d "The runtime to target"
complete -c gleam -n '__fish_seen_subcommand_from build; and not __fish_seen_subcommand_from docs' -l warnings-as-errors -d "Emit compile time warnings as errors"
complete -c gleam -n '__fish_seen_subcommand_from build run; and not __fish_seen_subcommand_from docs' -l no-print-progress -d "Don't print progress information"
complete -c gleam -n '__fish_seen_subcommand_from run' -s m -l module -rf -a '(__fish_gleam_runnable_module)' -d "The module to run"

# Dependencies: add deps remove update
complete -c gleam -n '__fish_seen_subcommand_from add' -l dev -rf -a '(__fish_gleam_hex_packages)'
complete -c gleam -n '__fish_seen_subcommand_from add' -rf -a '(__fish_gleam_hex_packages)'
complete -c gleam -n '__fish_seen_subcommand_from deps' -a list     -d "List all dependency packages"
complete -c gleam -n '__fish_seen_subcommand_from deps' -a download -d "Download all dependency packages"
complete -c gleam -n '__fish_seen_subcommand_from deps' -a update   -d "Update dependencies to their latest versions"
complete -c gleam -n '__fish_seen_subcommand_from remove' -rf -a '(__fish_gleam_deps_direct)'
complete -c gleam -n '__fish_seen_subcommand_from update' -rf -a '(__fish_gleam_deps_all)'

# Publish: hex publish
complete -c gleam -n '__fish_seen_subcommand_from hex' -a retire   -d "Retire a release from Hex"
complete -c gleam -n '__fish_seen_subcommand_from hex' -a unretire -d "Un-retire a release from Hex"
complete -c gleam -n '__fish_seen_subcommand_from hex' -a revert   -d "Revert a release from Hex"
complete -c gleam -n '__fish_seen_subcommand_from retire' -r -a '(__fish_gleam_hex_packages)'
complete -c gleam -n '__fish_seen_subcommand_from revert' -l package -rf -a '(__fish_gleam_hex_packages)'
complete -c gleam -n '__fish_seen_subcommand_from revert' -l version -rf
complete -c gleam -n '__fish_seen_subcommand_from publish; and not __fish_seen_subcommand_from docs' -l replace
complete -c gleam -n '__fish_seen_subcommand_from publish; and not __fish_seen_subcommand_from docs' -s y -l yes

# docs
complete -c gleam -n '__fish_seen_subcommand_from docs' -a build   -d "Render HTML docs locally"
complete -c gleam -n '__fish_seen_subcommand_from docs' -a publish -d "Publish HTML docs to HexDocs"
complete -c gleam -n '__fish_seen_subcommand_from docs' -a remove  -d "Remove HTML docs from HexDocs"
complete -c gleam -n '__fish_seen_subcommand_from docs; and __fish_seen_subcommand_from build' -l open -d "Open in a browser after rendering"
complete -c gleam -n '__fish_seen_subcommand_from docs; and __fish_seen_subcommand_from remove' -l package -rf -d "The name of the package"
complete -c gleam -n '__fish_seen_subcommand_from docs; and __fish_seen_subcommand_from remove' -l version -rf -d "The version of the docs to remove"

# export
complete -c gleam -n '__fish_seen_subcommand_from export' -a erlang-shipment    -d "Precompiled Erlang, suitable for deployment"
complete -c gleam -n '__fish_seen_subcommand_from export' -a hex-tarball        -d "A bundled tarball, suitable for publishing to Hex"
complete -c gleam -n '__fish_seen_subcommand_from export' -a javascript-prelude -d "The JavaScript prelude module"
complete -c gleam -n '__fish_seen_subcommand_from export' -a typescript-prelude -d "The TypeScript prelude module"
complete -c gleam -n '__fish_seen_subcommand_from export' -a package-interface  -d "Information on the modules in JSON format"
complete -c gleam -n '__fish_seen_subcommand_from package-interface' -l out -r -F  -d "The path to write the JSON file to"

# format
complete -c gleam -n '__fish_seen_subcommand_from format; and __fish_not_contain_opt stdin' -F
complete -c gleam -n '__fish_seen_subcommand_from format' -l stdin -d "Read source from STDIN"
complete -c gleam -n '__fish_seen_subcommand_from format' -l check -d "Check if inputs are formatted without changing them"

# new
complete -c gleam -n '__fish_seen_subcommand_from new' -l name -r -d "Name of the project"
complete -c gleam -n '__fish_seen_subcommand_from new' -l template -rf -a "$targets" -d "The template to use"
complete -c gleam -n '__fish_seen_subcommand_from new' -l skip-git    -d "Skip git initialization"
complete -c gleam -n '__fish_seen_subcommand_from new' -l skip-github -d "Skip creation of .github/* files"


