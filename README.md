# Shell Completions for Gleam

You can learn more about the Gleam programming language
[here](https://gleam.run/).


## Fish Completion

Some caveats:
- It is handwritten, so it may become outdated if Gleam CLI changes;
- I may have missed some subcommands and options;
- No completion for dynamic stuff (yet): hex packages, runnable modules;
- The `gleam.toml` parsing for dependencies completions is simplistic and may
  not work with unusually written files (on gleam version > 1.8 the script
  parses the output of `gleam deps tree` to get direct dependencies, so this is
  no longer an issue);
- It's my first fish completion, so there may be some mistakes;

To install save `gleam.fish` in `$XDG_CONFIG_HOME/fish/completions`
(usually `~/.config/fish/completions`)
or any other directory in `$fish_complete_path`

