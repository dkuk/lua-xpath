Notes
-----
lua-xpath is a simple XPath library to help stay sane while working with XML in Lua. 
It's adopted for rapidxml parser from original LuaExpat compatable version https://github.com/bkersten/lua-xpath

Not yet suppots last() selector! So something like 
```xpath
//a[last()]/@value
```
will not return expected selection.

Dependencies
-------------
Works on parsed model over luaRapidXML data structure
https://github.com/tarantool/luarapidxml

Usage
------

```lua
local rapid = require "luarapidxml"
local xpath = require "xpath"

local xml = [[
<root>
    <node foo="bar">sample text</node>
    <node>other text</node>
</root>
]]

local xml_tree = rapid.decode(xml)

local nodes = xpath.selectNodes(xml_tree, '/root/node[@foo="bar"]/text()')
for _,val in ipairs(nodes) do
    print(val)
end
```

The output will be "sample text"
