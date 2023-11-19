# neo-trim

`neo-trim` is a Neovim plugin written designed to highlight and trim trailing whitespace.

## Features

- Automatically trims trailing whitespace on saving files.
- Highlights trailing whitespace.
- Customizable: Exclude specific file types from trimming or diagnostics. Enable / Disable auto trimming.
- Easy to configure and use.

## Installation

Install `neo-trim` using your favorite package manager.

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'BusterWarn/neo-trim'
```

### [lazy](https://github.com/folke/lazy.nvim)

```vim
require('lazy').setup({
  {
    'BusterWarn/neo-trim',
    config = {
      auto_trim_on_write = false,
    },
  },
}, {})
```

## Usage

To use `neo-trim` with its default configuration, simply add the following line to your Neovim configuration:

```lua
require('neo_trim').setup()
```

## Configuration

`neo-trim` is configurable. You can set up the plugin with custom settings:

```lua
require('neo_trim').setup({
    exclude_diagnostics_for_languages = {"html", "markdown"}, -- File types to exclude from diagnostics
    exclude_auto_trimming_for_languages = {"cpp", "lua"}     -- File types to exclude from automatic trimming
})
```

### Options

- `exclude_diagnostics_for_languages`: A list of file types to exclude from trailing whitespace diagnostics.
  Default: `{}`
- `exclude_auto_trimming_for_languages`: A list of file types to exclude from automatic trailing whitespace trimming on save.
  Default: `{}`
- `trim_command_name`: If you want to change the command name for trimming, for some reason.
  Default: `"TrimWhitespace"`
- `auto_trim_on_write`: Trims whitespace whenever a write is done.
  Default: `true`

## Contributing

Contributions to `neo-trim` are welcome! Feel free to open issues for bugs or suggestions and submit pull requests for improvements.
