
IDENTIFIER = "__event_emitter"

PREFIX_LISTENERS = "__listeners_"

LEN_PREFIX_LISTENERS = PREFIX_LISTENERS\len!

findOrCreateListenerTable = (self, event, useWeakReference)->
  keyEvent = "#{PREFIX_LISTENERS}#{event}"
  listenerTable = rawget self, keyEvent
  return listenerTable if type(listenerTable) == "table"    -- found

  listenerTable = {}
  setmetatable(listenerTable, __mode: 'k') if useWeakReference
  rawset self, keyEvent, listenerTable                      -- create
  return listenerTable

addListener = (self, event, listener)->
  assert type(self) == "table", "#{self} is not a table"
  useWeakReference = rawget(self, IDENTIFIER)
  assert(useWeakReference != nil, "self is not valid EventEmitter")

  listeners = findOrCreateListenerTable(self, event, useWeakReference)
  -- NOTE:
  -- 1. use rawset to skip metamethods
  -- 2. use listener as the key in order to let useWeakReference take effect
  rawset listeners, listener, true
  return self   -- chainable


once = (self, event, listener)->
  assert type(self) == "table", "#{self} is not a table"
  useWeakReference = rawget(self, IDENTIFIER)
  assert(useWeakReference != nil, "self is not valid EventEmitter")

  event = "#{event}:once"
  listeners = findOrCreateListenerTable(self, event, self[IDENTIFIER])
  rawset listeners, listener, true
  return self   -- chainable

removeListener = (self, event, listener)->
  print "[events::removeListener] self:#{self}, event:#{event}"
  assert type(self) == "table", "#{self} is not a table"
  useWeakReference = rawget(self, IDENTIFIER)
  assert(useWeakReference != nil, "self is not valid EventEmitter")

  keyEvent = "#{PREFIX_LISTENERS}#{event}"                       -- remove the listener from common list
  listeners = rawget self, keyEvent
  rawset listeners, listener, nil if listeners

  keyEvent = "#{PREFIX_LISTENERS}#{event}:once"                  -- remove the listener from once list
  listeners = rawget self, keyEvent
  rawset listeners, listener, nil if listeners

  return self   -- chainable

removeAllListeners = (self, event)->
  print "[events::removeAllListeners] self:#{self}, event:#{event}"
  assert type(self) == "table", "#{self} is not a table"
  assert(type(self) == "table" and rawget(self, IDENTIFIER) != nil, "self is not valid EventEmitter")

  if event != nil                                           -- when specified event
    keyEvent = "#{PREFIX_LISTENERS}#{event}"                       -- clean up common list
    rawset self, keyEvent, nil
    keyEvent = "#{PREFIX_LISTENERS}#{event}:once"                  -- clean up once list
    rawset self, keyEvent, nil
  else                                                      -- clean up all listeners
    listToRemove = {}
    for key in pairs self
      table.insert listToRemove, key if type(key) == "string" and key\sub(1, LEN_PREFIX_LISTENERS) == PREFIX_LISTENERS
    for key in *listToRemove
      rawset self, key, nil

  return self   -- chainable

emit = (self, event, ...)->
  --print "[events::emit] self:#{self}, event:#{event}"

  assert type(self) == "table", "#{self} is not a table"
  assert(type(self) == "table" and rawget(self, IDENTIFIER) != nil, "self is not valid EventEmitter")

  keyEvent = "#{PREFIX_LISTENERS}#{event}"                       -- call listeners
  listeners = rawget(self, keyEvent)
  if type(listeners) == "table"
    for listener in pairs listeners
      status, err = pcall(listener, ...)
      print "[events::#{self}::emit] err:#{err}" unless status

  keyEvent = "#{PREFIX_LISTENERS}#{event}:once"                  -- call listeners only once
  listeners = rawget self, keyEvent
  if type(listeners) == "table"
    for listener in pairs listeners
      status, err = pcall(listener, ...)
      print "[events::#{self}::emit] err:#{err}" unless status
  rawset self, keyEvent, nil

  return self   -- chainable

return {
  -- 向给定的 table 注入 EventEmitter 功能，如果没有提给定的 table 那么会创建一个新 table
  -- @param tbl target table
  -- @param useWeakReference, when true will using weak table to hold event listeners
  EventEmitter: (tbl, useWeakReference)->

    --print "[events::EventEmitter] tbl:#{tbl}, useWeakReference:#{useWeakReference}"

    tbl = {} unless type(tbl) == "table"

    return print "[events::EventEmitter] #{tbl} is already an EventEmitter" if tbl[IDENTIFIER] != nil

    rawset tbl, IDENTIFIER, (not not useWeakReference) -- mark the table as EventEmitterified

    tbl.on = addListener
    tbl.addListener = addListener
    tbl.once = once
    tbl.off = removeListener
    tbl.removeListener = removeListener
    tbl.removeAllListeners = removeAllListeners
    tbl.emit = emit
    return tbl
}



