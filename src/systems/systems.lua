local systems = {}

--Is this file needed? Are there just general systems functions we need or anything?


function systems:load()
    self.input = require("src.systems.input")
end


return systems