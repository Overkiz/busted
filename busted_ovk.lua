--- This file is supposed to be require'd right after 'busted.runner':
---   [...]
---   require 'busted.runner'() -- require and launch busted things.
---   require 'busted_ovk'(x)   -- where x is a ":"-separated string of import paths
---   [...]

-----------------------------------
--- Code coverage and profiling ---
-----------------------------------
__prof__ = { enabled = (os.getenv("LUATESTS_DO_PROFILE") == "1") }
if __prof__.enabled then
  __prof__.currentFile = debug.getinfo(3, 'S').short_src -- get caller path
  os.execute("mkdir -p profiles; rm -f luacov.* profiles/prof_" .. __prof__.currentFile .. '_*')
  __prof__.class = require 'lulip'
elseif os.getenv("LUATESTS_DO_COVERAGE") == "1" then
  os.execute("rm -f luacov.*")
  require 'luacov'
end

-----------------------------------------------------
--- Custom path(s) to add to the lua import dirs  ---
-----------------------------------------------------
return function(path)
  if type(path) == "string" and #path > 0 then
    local ffi = require("ffi")
    ffi.cdef("int setenv(const char *envname, const char *envval, int overwrite);")
    ffi.C.setenv("LUA_IMPORT_PATH", path, 0)
  end
  require "ovk_import"; local _i_ = import; _G.import = function(...) pcall(_i_, ...) end
  import "Overkiz.utilities"
end

