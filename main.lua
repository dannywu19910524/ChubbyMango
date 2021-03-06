
function init()
	panel_n    = lcutils.integer(lovecat.number.Panel.n, 5, 50)
	panel_size = lcutils.integer(lovecat.number.Panel.size, 1, 10)
	panel_move_delay = lovecat.number.Panel.move_delay * 0.03
	panel_y = love.window.getHeight() - lovecat.number.Panel.from_bottom * 50
	panel_thick = lovecat.number.Panel.thick * 20
	panel_grid_size = love.window.getWidth() / panel_n
	panel_friction = lovecat.number.Panel.friction * 1.1

	mango_radius = lovecat.number.Mango.radius * 30
	mango_min_speed_0 = lovecat.number.Mango.min_speed_0 * 700
	mango_time_speed = lovecat.number.Mango.time_speed * 30
	mango_damping = lovecat.number.Mango.damping * 0.1
	mango_restitution = lovecat.number.Mango.restitution * 1.1

	balls_number = lcutils.integer(lovecat.number.Balls.n, 5, 30)
	balls_friction = lovecat.number.Balls.friction * 1.1
	balls_max_radius = lovecat.number.Balls.max_radius * 30

	love.graphics.setBackgroundColor(HSV(unpack(lovecat.color.background)))
end

function clear_fixtures(body)
	foreach_fixture(body, function(x) x:destroy() end)
end

function foreach_fixture(body, func)
	for _, fixture in ipairs(body:getFixtureList()) do
		func(fixture)
	end
end

function load_balls(n, max_radius)
	collectgarbage("collect")
	Balls = {}
	Balls.radius = {}
	local sW, sH = love.window.getDimensions()
	math.randomseed(os.time())
	for i=1,n do
		rW = math.random()
		rH = math.random()*0.8
		rRadius = math.random() * max_radius / 2 + max_radius / 2
		ball_userdata = {}
		ball_userdata.id = i
		ball_userdata.name = 'ball'
		ball_userdata.type = 'static'
		ball_userdata.radius = rRadius
		ball_userdata.eat = false
		ball = {}
		ball.body = love.physics.newBody(world, sW*rW, sH*rH, 'static')
		ball.body:setUserData(ball_userdata)
		print(ball.body:getUserData().eat)
		ball.radius = rRadius
		Balls[i] = ball
	end
	collectgarbage("collect")
	return Balls
end

function foreach_balls(balls, func)
	for _,ball in ipairs(balls) do
		func(ball)
	end
end

function draw_ball(ball)
	love.graphics.setColor(HSV(unpack(lovecat.color.Balls.color)))
	local ball_body = ball.body
	if ball_body:isDestroyed() == false then
		local ball_x, ball_y = ball_body:getWorldCenter()
		local radius = ball.radius
		love.graphics.circle('fill', ball_x, ball_y, radius)
	end
end

function update_ball(ball)
	local ball_body = ball.body
	if ball_body:isDestroyed() == false then
		local radius = ball.radius
		local shape = love.physics.newCircleShape(radius)
		local fixture = love.physics.newFixture(ball_body, shape)
		foreach_fixture(ball_body, function(fixture)
			fixture:setFriction(balls_friction)
		end )
	end
end

function clear_ball(ball)
	if ball:isDestroyed() == false then
		clear_fixtures(ball)
		ball:destroy()
	end
end

function update_world()
	mango_body:setLinearDamping(mango_damping)

	clear_fixtures(mango_body)
	local shape = love.physics.newCircleShape(mango_radius + mango_add_radius)
	local fixture = love.physics.newFixture(mango_body, shape)

	clear_fixtures(panel_body)
	local shape = love.physics.newRectangleShape(panel_size*panel_grid_size, panel_thick)
	local fixture = love.physics.newFixture(panel_body, shape)

	foreach_balls(Balls, update_ball)

	foreach_fixture(mango_body, function(fixture)
		fixture:setRestitution(mango_restitution)
	end )

	foreach_fixture(panel_body, function(fixture)
		fixture:setFriction(panel_friction)
	end )

	mango_check_speed()
end

function mango_check_speed()
	local vx, vy = mango_body:getLinearVelocity()

	function fix_vel(v, min_v)
		if v < 0 then
			return math.min(v, -min_v)
		else
			return math.max(v, min_v)
		end
	end

	vx = fix_vel(vx, mango_min_speed)
	vy = fix_vel(vy, mango_min_speed)

	mango_body:setLinearVelocity(vx, vy)	
end

function love.load()
	require 'color'
	lcutils = require 'lovecat-utils'

	world = love.physics.newWorld()

	init()
	mango_min_speed = mango_min_speed_0

	panel_pos  = math.floor((panel_n - panel_size) / 2)
	panel_move_t = 0
	panel_body = love.physics.newBody(world)

	local sW, sH = love.window.getDimensions()

	wall_left = love.physics.newBody(world, -5, sH/2)
	local shape = love.physics.newRectangleShape(10, sH)
	local fixture = love.physics.newFixture(wall_left, shape)

	wall_right = love.physics.newBody(world, sW+5, sH/2)
	local shape = love.physics.newRectangleShape(10, sH)
	local fixture = love.physics.newFixture(wall_right, shape)

	wall_top = love.physics.newBody(world, sW/2, -5)
	local shape = love.physics.newRectangleShape(sW, 10)
	local fixture = love.physics.newFixture(wall_top, shape)

	-- wall_bottom = love.physics.newBody(world, sW/2, sH+5)
	-- local shape = love.physics.newRectangleShape(sW, 10)
	-- local fixture = love.physics.newFixture(wall_bottom, shape)
	mango_add_radius = 0
	mango_points = 0
	game_time = 0
	game_over = false

	mango_body = love.physics.newBody(world, sW/2, sH/2, 'dynamic')
	mango_body:setLinearVelocity(0.01, 0.01)
	mango_userdata = {}
	mango_userdata.name = 'mango'
	mango_userdata.type = 'dynamic'
	mango_body:setUserData(mango_userdata)

	panel_body = love.physics.newBody(world, (panel_pos+panel_size/2)*panel_grid_size, panel_y+panel_thick/2)
	local shape = love.physics.newRectangleShape(panel_size*panel_grid_size, panel_thick)
	local fixture = love.physics.newFixture(panel_body, shape)

	Balls = load_balls(balls_number, balls_max_radius)

	update_world()

	world:setCallbacks(nil, nil, preSolve, nil)

end

function preSolve(fa, fb, contact)
	mango_points = mango_add_radius
	fball, fmango = get_exact_fixture(fa, fb, 'ball', 'mango')
	if fball == nil or fmango == nil then
		return
	end
	if fball:isDestroyed() then
		contact:setEnabled(false)
		return
	end
	if fball:getShape():getRadius() < fmango:getShape():getRadius() + mango_add_radius then
		local r1 = fball:getShape():getRadius()
		local r2 = fmango:getShape():getRadius()
		--print(i, radius, fball:getBody(), mango_add_radius)
		fball:getBody():destroy()
		fball:destroy()
		contact:setEnabled(false)

		local userdata = fball:getBody():getUserData()
		if userdata ~=nil and userdata.eat == false then
			userdata.eat = true
			fball:getBody():setUserData(userdata)
			mango_add_radius = get_add_radius(r1,r2,mango_add_radius)
			
		end
	end
end

function get_add_radius(r1, r2, r3)
	local pow = 3.0
	result = math.pow(math.pow(r1,pow)+math.pow(r2+r3,pow),1/pow) - r2
	print(r1,r2,r3,result)
	return result
end

function get_exact_fixture(fa, fb, taga, tagb)
	if fa == nil or fb == nil then
		return nil, nil
	end
	local fa_userdata = fa:getBody():getUserData()
	local fb_userdata = fb:getBody():getUserData()
	if fa_userdata ~= nil and fb_userdata ~=nil and ( fa_userdata.name == taga) and (fb_userdata.name == tagb) then
		return fa, fb
	end
	if fa_userdata ~= nil and fb_userdata ~=nil and ( fa_userdata.name == tagb) and (fb_userdata.name == taga) then
		return fb, fa
	end
	return nil, nil
end

function clamp(x, a, b)
	return math.min(math.max(x, a), b)
end

function love.update(dt)
    lovecat.update(dt)

    collectgarbage()

    init()
    update_world()
    world:update(dt)

    panel_move_t = panel_move_t - dt

    if panel_move_t <= 0 then
    	if love.keyboard.isDown('left') then
    		panel_move_t = panel_move_delay
    		panel_pos = panel_pos - 1
    	end

    	if love.keyboard.isDown('right') then
    		panel_move_t = panel_move_delay
    		panel_pos = panel_pos + 1
    	end
    end

    panel_pos = clamp(panel_pos, 0, panel_n - panel_size)

    panel_body:setPosition((panel_pos+panel_size/2)*panel_grid_size, panel_y+panel_thick/2)

    local mangoX, mangoY = mango_body:getWorldCenter()
    if mangoY > love.window.getHeight() then
    	game_over = true
    end

	game_time = game_time + dt
	mango_min_speed = mango_min_speed_0 + game_time * mango_time_speed
end

function love.draw()
	love.graphics.setColor(HSV(unpack(lovecat.color.text_color)))
	love.graphics.print("points:"..mango_points, 10, 30)
	if game_over then
		love.graphics.print("game over", 10, 10)
	end

	love.graphics.setColor(HSV(unpack(lovecat.color.Panel.color)))
	love.graphics.rectangle('fill', panel_grid_size*panel_pos, panel_y, panel_grid_size*panel_size, panel_thick)

	love.graphics.setColor(HSV(unpack(lovecat.color.Mango.color)))
	local mango_x, mango_y = mango_body:getWorldCenter()
	love.graphics.circle('fill', mango_x, mango_y, mango_radius + mango_add_radius)
	
	foreach_balls(Balls,draw_ball)

end

function love.keypressed(key, isrepeat)
	if key == 'r' then
		local sW, sH = love.window.getDimensions()
		mango_body:setPosition(sW/2, sH/2)
		mango_body:setLinearVelocity(0.01, 0.01)
		mango_add_radius = 0
		game_over = false
		mango_points = 0
		game_time = 0
		mango_min_speed = mango_min_speed_0
		foreach_balls(Balls, clear_ball)
		load_balls(balls_number, balls_max_radius)
	end
end
