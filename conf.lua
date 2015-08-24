package.path = 'lib/?.lua;?.txt;' .. package.path

lovecat = require 'lovecat'
-- lovecat = require 'lovecat-saved'
require 'cupid'

function love.conf(t)
  t.title = "Chubby Mango!"
  -- t.window.width=600
  -- t.window.height=600
end
