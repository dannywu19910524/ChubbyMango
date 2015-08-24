function test_level()
	local ans = {}
	for i=1, 20 do
		mango = {
			x=    math.random() * 4,
			y=    math.random() * 3,
			size= math.random() * lovecat.number.LevelTest.max_size,
			hue=  math.random() * 360,
		}
		table.insert(ans, mango)
	end
	return ans
end
