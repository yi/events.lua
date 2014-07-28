local IDENTIFIER = "__event_emitter"
local PREFIX_LISTENERS = "__listeners_"
local LEN_PREFIX_LISTENERS = PREFIX_LISTENERS:len()
local findOrCreateListenerTable
findOrCreateListenerTable = function(self, event, useWeakReference)
  local keyEvent = tostring(PREFIX_LISTENERS) .. "{event}"
  local listenerTable = rawget(self, keyEvent)
  if type(listenerTable) == "table" then
    return listenerTable
  end
  listenerTable = { }
  if useWeakReference then
    setmetatable(listenerTable, {
      __mode = 'k'
    })
  end
  rawset(self, keyEvent, listenerTable)
  return listenerTable
end
local addListener
addListener = function(self, event, listener)
  assert(type(self) == "table", tostring(self) .. " is not a table")
  local useWeakReference = rawget(self, IDENTIFIER)
  assert(useWeakReference ~= nil, "self is not valid EventEmitter")
  local listeners = findOrCreateListenerTable(self, event, useWeakReference)
  rawset(listeners, listener, true)
  return self
end
local once
once = function(self, event, listener)
  assert(type(self) == "table", tostring(self) .. " is not a table")
  local useWeakReference = rawget(self, IDENTIFIER)
  assert(useWeakReference ~= nil, "self is not valid EventEmitter")
  event = tostring(event) .. ":once"
  local listeners = findOrCreateListenerTable(self, event, self[IDENTIFIER])
  rawset(listeners, listener, true)
  return self
end
local removeListener
removeListener = function(self, event, listener)
  assert(type(self) == "table", tostring(self) .. " is not a table")
  local useWeakReference = rawget(self, IDENTIFIER)
  assert(useWeakReference ~= nil, "self is not valid EventEmitter")
  local keyEvent = tostring(PREFIX_LISTENERS) .. "{event}"
  local listeners = rawget(self, keyEvent)
  if listeners then
    rawset(listeners, listener, nil)
  end
  keyEvent = tostring(PREFIX_LISTENERS) .. "{event}:once"
  listeners = rawget(self, keyEvent)
  if listeners then
    rawset(listeners, listener, nil)
  end
  return self
end
local removeAllListeners
removeAllListeners = function(self, event)
  assert(type(self) == "table", tostring(self) .. " is not a table")
  assert(type(self) == "table" and rawget(self, IDENTIFIER) ~= nil, "self is not valid EventEmitter")
  if event ~= nil then
    local keyEvent = tostring(PREFIX_LISTENERS) .. "{event}"
    rawset(self, keyEvent, nil)
    keyEvent = tostring(PREFIX_LISTENERS) .. "{event}:once"
    rawset(self, keyEvent, nil)
  else
    local listToRemove = { }
    for key in pairs(self) do
      if type(key) == "string" and key:sub(1, LEN_PREFIX_LISTENERS) == PREFIX_LISTENERS then
        table.insert(listToRemove, key)
      end
    end
    for _index_0 = 1, #listToRemove do
      local key = listToRemove[_index_0]
      rawset(self, key, nil)
    end
  end
  return self
end
local emit
emit = function(self, event, ...)
  assert(type(self) == "table", tostring(self) .. " is not a table")
  return assert(type(self) == "table" and rawget(self, IDENTIFIER) ~= nil, "self is not valid EventEmitter")
end
return {
  EventEmitter = function(tbl, useWeakReference)
    if not (type(tbl) == "table") then
      tbl = { }
    end
    if tbl[IDENTIFIER] ~= nil then
      return print("[events::EventEmitter] " .. tostring(tbl) .. " is already an EventEmitter")
    end
    rawset(tbl, IDENTIFIER, useWeakReference)
    tbl.on = addListener
    tbl.addListener = addListener
    tbl.once = once
    tbl.off = removeListener
    tbl.removeListener = removeListener
    tbl.removeAllListeners = removeAllListeners
    tbl.emit = emit
    return tbl
  end
}
