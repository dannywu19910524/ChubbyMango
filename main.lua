require("maptool")
tilemap = getMap("assets/".."map3.json")
tilemap._X,tilemap._Y=0,0
tilemap._rot=0
tilemap._sx=1
tilemap._sy=1
quadtable = {}
function love.load()
	image=love.graphics.newImage("assets/" .. tilemap["tilesets"][1].image)
	makeQuad(tilemap)
	mainfont = love.graphics.newFont( 20 )
end

function love.draw()
	drawMap(tilemap,image)
	love.graphics.setFont(mainfont);
end