
describe "events tests", ->

  events = nil

  setup ->
    events = require "events"
    return

  it "events should provide EventEmitter function", ->
    assert.truthy(events.EventEmitter)

  it "EventEmitterify an existing table", ->

    person =
      name: "Johnny"
      age: "very old"

    assert.are.equals person, events.EventEmitter(person)
    assert.truthy(type(person.on) == "function")
    assert.truthy(type(person.addListener) == "function")
    assert.truthy(type(person.removeListener) == "function")
    assert.truthy(type(person.removeAllListeners) == "function")
    assert.truthy(type(person.once) == "function")
    assert.truthy(type(person.off) == "function")
    assert.truthy(type(person.emit) == "function")

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

    person\emit "hello", person, 1
    person\emit "hello", person, 2

    person\off "hello", handlers.helloToRemove
    person\emit "hello", person, 3

    person\emit "goodday", person, 1
    person\removeAllListeners "hello"

    person\emit "hello", person, 4
    person\emit "goodday", person, 2

    events.EventEmitter person, true    --should output: [events::EventEmitter] table: 0x7fc142d70500 is already an EventEmitter
    return


  it "EventEmitterify an existing table by weak references", ->
    print "\n\n\n\n"
    person =
      name: "Walker"
      age: "long enough"

    assert.are.equals person, events.EventEmitter(person, true)
    assert.truthy(type(person.on) == "function")
    assert.truthy(type(person.addListener) == "function")
    assert.truthy(type(person.removeListener) == "function")
    assert.truthy(type(person.removeAllListeners) == "function")
    assert.truthy(type(person.once) == "function")
    assert.truthy(type(person.off) == "function")
    assert.truthy(type(person.emit) == "function")

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

    person\emit "hello", person, 1

    handlers.hello = nil                -- handlers.hello should be gced
    collectgarbage "collect"
    person\emit "hello", person, 2

    --person\off "hello", handlers.helloToRemove
    --person\emit "hello", person, 3

    --person\emit "goodday", person, 1
    --person\removeAllListeners "hello"

    --person\emit "hello", person, 4
    --person\emit "goodday", person, 2

    events.EventEmitter person, true    --should output: [events::EventEmitter] table: 0x7fc142d70500 is already an EventEmitter
    return





