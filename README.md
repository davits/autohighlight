# AutoHighlight

Automatically highlights word under cursor after given timeout.
Uses Vim's new timers feature introduced in version 7.4.1594.

Options
_______

### The `g:AH_timeout` option

This option sets timeout in milliseconds of cursor idle after which word under cursor is highlighted.

Default: `700`

```viml
let g:AH_timeout = 700
```

### The `g:AH_style` option

Sets style of highlighting.
Possible values are: (bold|italic|underlined).

Default: `'bold'`

```viml
let g:AH_style = 'bold'
```
