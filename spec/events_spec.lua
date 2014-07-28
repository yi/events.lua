return describe("events tests", function()
  local events = nil
  setup(function()
    events = require("events")
  end)
  it("events should provide EventEmitter function", function()
    return assert.truthy(events.EventEmitter)
  end)
  it("EventEmitterify an existing table", function()
    local person = {
      name = "Johnny",
      age = "very old"
    }
    assert.are.equals(person, events.EventEmitter(person))
    assert.truthy(type(person.on) == "function")
    assert.truthy(type(person.addListener) == "function")
    assert.truthy(type(person.removeListener) == "function")
    assert.truthy(type(person.removeAllListeners) == "function")
    assert.truthy(type(person.once) == "function")
    assert.truthy(type(person.off) == "function")
    assert.truthy(type(person.emit) == "function")
    local handlers = {
      hello = function(who, howmany)
        print("[events_spec::hello] who:" .. tostring(who.name) .. ", " .. tostring(howmany) .. " times")
        return assert.are.equal(who, person)
      end,
      helloOnce = function(who, howmany)
        print("[events_spec::helloOnce] who:" .. tostring(who.name) .. ", " .. tostring(howmany) .. " times")
        return assert.are.equal(who, person)
      end,
      helloToRemove = function(who, howmany)
        print("[events_spec::helloToRemove] who:" .. tostring(who.name) .. ", " .. tostring(howmany) .. " times")
        return assert.are.equal(who, person)
      end,
      goodday = function(who, howmany)
        print("[events_spec::goodday] who:" .. tostring(who.name) .. ", " .. tostring(howmany) .. " times")
        return assert.are.equal(who, person)
      end
    }
    person:on("hello", handlers.hello)
    person:on("hello", handlers.helloToRemove)
    person:once("hello", handlers.helloOnce)
    person:on("goodday", handlers.goodday)
    person:emit("hello", person, 1)
    person:emit("hello", person, 2)
    person:off("hello", handlers.helloToRemove)
    person:emit("hello", person, 3)
    person:emit("goodday", person, 1)
    person:removeAllListeners("hello")
    person:emit("hello", person, 4)
    person:emit("goodday", person, 2)
    events.EventEmitter(person, true)
  end)
  return it("EventEmitterify an existing table by weak references", function()
    print("\n\n\n\n")
    local person = {
      name = "Walker",
      age = "long enough"
    }
    assert.are.equals(person, events.EventEmitter(person, true))
    assert.truthy(type(person.on) == "function")
    assert.truthy(type(person.addListener) == "function")
    assert.truthy(type(person.removeListener) == "function")
    assert.truthy(type(person.removeAllListeners) == "function")
    assert.truthy(type(person.once) == "function")
    assert.truthy(type(person.off) == "function")
    assert.truthy(type(person.emit) == "function")
    local handlers = {
      hello = function(who, howmany)
        print("[events_spec::hello] who:" .. tostring(who.name) .. ", " .. tostring(howmany) .. " times")
        return assert.are.equal(who, person)
      end,
      helloOnce = function(who, howmany)
        print("[events_spec::helloOnce] who:" .. tostring(who.name) .. ", " .. tostring(howmany) .. " times")
        return assert.are.equal(who, person)
      end,
      helloToRemove = function(who, howmany)
        print("[events_spec::helloToRemove] who:" .. tostring(who.name) .. ", " .. tostring(howmany) .. " times")
        return assert.are.equal(who, person)
      end,
      goodday = function(who, howmany)
        print("[events_spec::goodday] who:" .. tostring(who.name) .. ", " .. tostring(howmany) .. " times")
        return assert.are.equal(who, person)
      end
    }
    person:on("hello", handlers.hello)
    person:on("hello", handlers.helloToRemove)
    person:once("hello", handlers.helloOnce)
    person:on("goodday", handlers.goodday)
    person:emit("hello", person, 1)
    handlers.hello = nil
    collectgarbage("collect")
    person:emit("hello", person, 2)
    events.EventEmitter(person, true)
  end)
end)
