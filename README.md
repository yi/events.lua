# events.lua

An event emitter implementation in lua, api similar to [NodeJS's events](http://nodejs.org/api/events.html)

## 如何使用  Usage

``` coffee

events = require "events"

person =
  name: "Johnny"
  age: "very old"

events.EventEmitter(person)   -- make person an EventEmitter

handlers =
  hello: (who, howmany)->
    print "[events_spec::hello] who:#{who.name}, #{howmany} times"
    assert.are.equal who, person

  helloOnce: (who, howmany)->
    print "[events_spec::helloOnce] who:#{who.name}, #{howmany} times"
    assert.are.equal who, person

  helloToRemove: (who, howmany)->
    print "[events_spec::helloToRemove] who:#{who.name}, #{howmany} times"
    assert.are.equal who, person

  goodday: (who, howmany)->
    print "[events_spec::goodday] who:#{who.name}, #{howmany} times"
    assert.are.equal who, person

person\on "hello", handlers.hello
person\on "hello", handlers.helloToRemove
person\once "hello", handlers.helloOnce
person\on "goodday", handlers.goodday

person\emit "hello", person, 1      -- will fire: hello, helloToRemove, helloOnce
person\emit "hello", person, 2      -- will fire: hello, helloToRemove

person\off "hello", handlers.helloToRemove
person\emit "hello", person, 3      -- will fire: hello

person\emit "goodday", person, 1    -- fire goodday
person\removeAllListeners "hello"

person\emit "hello", person, 4      -- fire no-one
person\emit "goodday", person, 2    -- fire goodday

events.EventEmitter person, true    --should output: [events::EventEmitter] table: 0x7fc142d70500 is already an EventEmitter


```

## 支持回调方法的弱引用，简化析构 Weak Reference Support

```coffee

person =
  name: "Walker"
  age: "long enough"

events.EventEmitter(person, true)   -- (WEAK KEY) make person an EventEmitter

handlers =
  hello: (who, howmany)->
    print "[events_spec::hello] who:#{who.name}, #{howmany} times"
    assert.are.equal who, person

  helloOnce: (who, howmany)->
    print "[events_spec::helloOnce] who:#{who.name}, #{howmany} times"
    assert.are.equal who, person

  helloToRemove: (who, howmany)->
    print "[events_spec::helloToRemove] who:#{who.name}, #{howmany} times"
    assert.are.equal who, person

person\on "hello", handlers.hello
person\on "hello", handlers.helloToRemove
person\once "hello", handlers.helloOnce
person\on "goodday", handlers.goodday

person\emit "hello", person, 1      -- will fire: hello, helloToRemove, helloOnce

handlers.hello = nil
collectgarbage "collect"            -- handlers.hello should be gced
person\emit "hello", person, 2      -- only fire: helloToRemove

```




## Test

Test specs are written in [moonscript](http://www.moonscript.com/) on [busted](https://github.com/Olivine-Labs/busted)

To run tests, do:

```sh
busted -v spec/
```





