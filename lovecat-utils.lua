local lcutils = {}

function lcutils.integer(x, a, b)
	return a + math.floor((b-a) * x)
end

return lcutils