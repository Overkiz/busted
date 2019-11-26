local path = require 'pl.path'
local hasMoon, moonscript = pcall(require, 'moonscript')
local utils = require 'busted.utils'

return function()
  local loadOutputHandler = function(busted, output, options)
    local handlers = {}

    utils.copy_interpreter_args(options.arguments)
    local success, err = pcall(function()
      for word in output:gmatch("%a+") do
        if word:match('%.lua$') then
          table.insert(handlers, dofile(path.normpath(word)))
        elseif hasMoon and word:match('%.moon$') then
          table.insert(handlers, moonscript.dofile(path.normpath(word)))
        else
          table.insert(handlers, require('busted.outputHandlers.' .. word))
        end
      end
    end)

    if not success and err:match("module '.-' not found:") then
      success, err = pcall(function() handler = require(output) end)
    end

    if not success then
      busted.publish({ 'error', 'output' }, { descriptor = 'output', name = output }, nil, err, {})
      handler = require('busted.outputHandlers.' .. options.defaultOutput)
    end

    if options.enableSound then
      require 'busted.outputHandlers.sound'(options)
    end

    for _, handler in pairs(handlers) do
      handler(options):subscribe(options)
    end
  end

  return loadOutputHandler
end
