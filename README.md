# blog

Hi. This is the content and code for my blog.

Here's what it does, and the tools that make it possible:

- It uses the [GNU M4 macro processor](https://www.gnu.org/software/m4/m4.html) to expand pieces of markdown into HTML snippets.
- [Pandoc](https://pandoc.org/) was the easy choice for markdown conversion, also it makes it easy to [assign token classes!](https://pandoc.org/demo/example33/8.5-verbatim-code-blocks.html)
- And because I didn't want more pages, I used a little JS for tag filtering.
- I chose Lua to glue everything together cause it's light and simple. I also used [toml2lua](https://luarocks.org/modules/nexo-tech/toml2lua) and [luafilesystem](https://luarocks.org/modules/hisham/luafilesystem).
- Lastly, a silly bash script for builds: `sudo ./befuddle prod`
