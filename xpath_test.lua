#!/usr/bin/tarantool

-- https://codebeautify.org/Xpath-Tester

local rapid = require "luarapidxml"
local xpath = require "app/xpath"
require 'app/utils'

local xml = [[
<root>
  <a index="1" value="first one">
    <b value="kiwi">
      <one value="foo">some text in foo</one>
      <one>some text</one>
    </b>
  </a>
  <a index="2">
    <c value="apple">
      <one value="bar">some text in bar</one>
      <one value="bar">some text in bar too</one>
      <two value="cheese" parent="c">
      </two>
    </c>
  </a>
  <a index="3" value="last one">
    <d value="banana">
      <one>some more text</one>
      <two value="foo" parent="d">
      </two>
      <two value="bar" parent="d">
      </two>
    </d>
  </a>
  <z>
    <x value="orange">
      <one>empty one</one>
      <two parent="x">
      </two>
    </x>
    <y>
      <two parent="y">
      </two>
      <two parent="y">
      </two>
    </y>
    <d> </d>
  </z>
</root>
]]

local xml_tree = rapid.decode(xml)

local tests = {

    --[[ DELIBERATE FAILURES
    {
		query = 'a',
		count = 3,
        results = {
            'b',
            'c',
            'd',
        },
	},

    {
		query = './a',
		count = 2,
	},
    --]]

	{
		query = '/root',
		count = 1,
		results = { 'root', },
	},

  {
		query = '//root',
		count = 1,
    results = { 'root', },
	},

	{
		query = 'root',
    count = 1,
    results = { 'root', },
	},

  {
		query = './root',
		count = 1,
		results = { 'root', },
	},

  {
		query = './/root',
    count = 1,
		results = { 'root', },
	},

  -- abstract document! WILL RETURN NULL!
  {
		query = '.',
		count = 0,
	},

	{
		query = '/root/a',
		count = 3,
		results = { 'a', 'a', 'a', }
	},

	{
		query = './a',
		count = 0
	},

	{
		query = '//a',
		count = 3,
    results = { 'a', 'a', 'a', }
	},

    {
		query = './/a',
    count = 3,
    results = { 'a', 'a', 'a', }
	},

  {
		query = '//a',
		count = 3,
    results = { 'a', 'a', 'a', }
	},

  {
		query = '/root/a/*',
		count = 3,
		results = { 'b', 'c', 'd', }
	},

  {
		query = './root/a/*',
		count = 3,
		results = { 'b', 'c', 'd', }
	},

	{
		query = './a/*',
		count = 0
	},

  {
		query = './/a/*',
		count = 3,
		results = {	'b', 'c', 'd', }
	},

	{
		query = '/root/a/@index',
		count = 3,
		results = { '1', '2', '3',	}
	},

	{
		query = './a/@index',
		count = 0
	},

	{
		query = '//a/@index',
		count = 3,
		results = { '1', '2', '3',	}
	},

  {
		query = '//a/@*',
		count = 5,
		results = { '1', 'first one', '2', '3', 'last one', }
	},

  {
		query = '//z//two',
		count = 3,
        results = { 'two', 'two', 'two', },
	},

  {
		query = '//z/*/two',
		count = 3,
        results = { 'two', 'two', 'two', },
	},

  {
		query = '//z//two/@parent',
		count = 3,
    results = { 'x', 'y', 'y', },
	},

  {
		query = './/d',
		count = 2,
        results = { 'd', 'd', },
	},

  {
		query = '/root/z/x/one/..',
		count = 1,
    results = { 'x', },
	},

  {
		query = '/root/z/x/one/../..',
		count = 1,
    results = { 'z', },
	},

  {
		query = '/root/a/*/one/../@value',
		count = 5,
    results = { 'kiwi', 'kiwi', 'apple', 'apple', 'banana', },
	},

  {
		query = '//a[1]/@value',
		count = 1,
		results = { 'first one',	}
	},

  {
		query = '//a[2]/@index',
		count = 1,
		results = { '2', }
	},

  {
		query = '//a[last()]/@value',
		count = 1,
		results = {	'last one', 	}
	},

  {
		query = '//a[@index="3"]/@value',
		count = 1,
    results = { 'last one', },
	},

  {
		query = '//a/*/one[@value="bar"]/text()',
		count = 2,
    results = {
      'some text in bar',
      'some text in bar too',
    },
	},

  {
		query = '//one/text()',
		count = 6,
    results = {
      'some text in foo',
      'some text',
      'some text in bar',
      'some text in bar too',
      'some more text',
      'empty one',
    },
	},

  {
		query = '//a/*/one[@value="foo"]',
		count = 1,
    results = {  'one', },
	},

  {
		query = '//a[d]/@index',
		count = 1,
    results = { '3',  },
	},

  {
		query = '//a/*[two]',
		count = 2,
    results = { 'c', 'd', },
	},

  {
		query = '//a/*[one="some text in foo"]',
		count = 1,
    results = { 'b' },
	},

  {
		query = '//a[@value and @index]/@index',
		count = 2,
    results = {'1', '3', },
	},

}

-- require("mobdebug").start()

function compare(a,b)
  return a < b
end

local failed_queries = {}

io.write('testing xpath.lua\n')
for _,test in ipairs(tests) do
	local failed = false
	local xpath_query = test.query

	local nodes = xpath.selectNodes(xml_tree, xpath_query)

	-- compare results count
	if #nodes ~= test.count then
		failed = true
	-- compare against expected resultss if there are any
	elseif test.results then
    table.sort(test.results, compare)
    local xpath_result = {}

		for _,n in pairs(nodes) do
			local node_result = n.tag or n
			xpath_result[#xpath_result] = n.tag or n
		end

    table.sort(xpath_result, compare)

    for i = 1,#xpath_result do
      if xpath_result[i] ~= test.results[i] then
    		failed = true
    	end
    end

	end

	if failed then
    print("[FAIL]", xpath_query, " EXPECTS=", test.count, ". RESULT: ", tdump(nodes))
    -- print("[FAIL]", xpath_query, " EXPECTS=", test.count)
--         -- failed_queries[#failed_queries+1] = xpath_query
	else
    print("[OK]", xpath_query)
	end
  print("--------------------------------------------------------------------")
end


-- for _,query in pairs(failed_queries) do
--     io.write('  ')
--     io.write(query)
--     io.write('\n')
-- end
