Notes
-----
lua-xpath is a simple XPath library to help stay sane while working with XML in Lua. 
It's adopted for rapidxml parser from original LuaExpat compatable version https://github.com/bkersten/lua-xpath

Not yet suppots predicates like: last(), position(), @val>=1, or

So next samples does NOT works: 
```xpath
//a[last()]/@value
//bookstore/book[last()-1]
/bookstore/book[position()<3]
/bookstore/book[price>35.00]
/bookstore/book[@price>=35.20 or @pages>600]
```

Common selectors with equal condition and " and " predicates works fine:
```xpath
//book
/bookstore/book/*
/bookstore//title
/bookstore/book/@*
//book[1]/title
//book[@price="100.00"]/@pages
/bookstore//*[@cover="100.00"]/text()
//book[rareElement]/@id
//book/*[description="some text in desc"]
//book[@price and @pages]/@id
```


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
