local EMPTY_VEC2 = Vector2.new(0, 0)
local EMPTY_VEC3 = Vector3.new(0, 0, 0)
local EMPTY_REG3 = Region3.new(EMPTY_VEC3, EMPTY_VEC3)
local EMPTY_COL3 = Color3.new(0, 0, 0)

local Converters = {
	[Vector3] = {
		-- Single
		{
			-- type
			'double[]',
			-- default
			EMPTY_VEC3,
			-- To Serialize
			function (schema, field, value)
				local out = {}

				if typeof(value) ~= 'Vector3' then
					out[1] = 0
					out[2] = 0
					out[3] = 0
				else
					out[4] = value.X
					out[5] = value.Y
					out[6] = value.Z
				end

				return out
			end,
			-- To Instance
			function(schema, field, value)
				if value == nil then
					return EMPTY_VEC3
				end
				return Vector3.new(value[1], value[2], value[3])
			end
		},
		-- Array
		{
			-- type
			'double[]',
			-- default
			{},
			-- To Serialize
			function(schema, field, value)
				local out = {}

				for _, vec3 in ipairs(value) do
					if typeof(vec3) ~= 'Vector3' then
						out[#out+1] = 0
						out[#out+1] = 0
						out[#out+1] = 0
					else
						out[#out+1] = vec3.X
						out[#out+1] = vec3.Y
						out[#out+1] = vec3.Z
					end
				end

				return out
			end,
			-- To Instance
			function(schema, field, value)
				local out = {}
				if value == nil or #value == 0 then
					return out
				end

				for i = 1, #value, 3 do
					out[#out+1] = Vector3.new(value[i], value[i+1], value[i+2])
				end
				return out
			end
		}
	},
	[Region3] = {
		{
			-- type
			'double[]',
			-- default
			EMPTY_REG3,
			-- To Serialize
			function (schema, field, value)
				local out = {}

				if typeof(value) ~= 'Region3' then
					out[1] = 0
					out[2] = 0
					out[3] = 0
					out[4] = 0
					out[5] = 0
					out[6] = 0
				else
					local x1, y1, z1, x2, y2, z2

					do
						local Size = value.Size
						local CFrame = value.CFrame

						x1, y1, z1 = CFrame.X, CFrame.Y, CFrame.Z
						x2, y2, z2 = Size.X/2, Size.Y/2, Size.Z/2
					end

					out[1] = x1-x2
					out[2] = y1-y2
					out[3] = z1-z2
					out[4] = x1+x2
					out[5] = y1+y2
					out[6] = z1+z2
				end

				return out
			end,
			-- To Instance
			function(schema, field, value)
				if value == nil then
					return EMPTY_VEC3
				end
				return Region3.new(Vector3.new(value[1], value[2], value[3]), Vector3.new(value[4], value[5], value[6]))
			end
		},
		{
			-- type
			'double[]',
			-- default
			{},
			-- To Serialize
			function(schema, field, value)
				local out = {}

				for _, reg3 in ipairs(value) do
					if typeof(reg3) ~= 'Region3' then
						out[#out+1] = 0
						out[#out+1] = 0
						out[#out+1] = 0
						out[#out+1] = 0
						out[#out+1] = 0
						out[#out+1] = 0
					else
						local x1, y1, z1, x2, y2, z2

						do
							local Size = value.Size
							local CFrame = value.CFrame

							x1, y1, z1 = CFrame.X, CFrame.Y, CFrame.Z
							x2, y2, z2 = Size.X/2, Size.Y/2, Size.Z/2
						end

						out[#out+1] = x1-x2
						out[#out+1] = y1-y2
						out[#out+1] = z1-z2
						out[#out+1] = x1+x2
						out[#out+1] = y1+y2
						out[#out+1] = z1+z2
					end
				end

				return out
			end,
			-- To Instance
			function(schema, field, value)
				local out = {}
				if value == nil or #value == 0 then
					return out
				end

				for i = 1, #value, 6 do
					out[#out+1] = Region3.new(Vector3.new(value[i], value[i+1], value[i+2]), Vector3.new(value[i+3], value[i+4], value[i+5]))
				end
				return out
			end
		}
	},
	[Vector2] = {
		-- Single
		{
			-- type
			'double[]',
			-- default
			EMPTY_VEC2,
			-- To Serialize
			function (schema, field, value)
				local out = {}

				if typeof(value) ~= 'Vector2' then
					out[#out+1] = 0
					out[#out+1] = 0
				else
					out[#out+1] = value.X
					out[#out+1] = value.Y
				end

				return out
			end,
			-- To Instance
			function(schema, field, value)
				if value == nil then
					return EMPTY_VEC2
				end
				return Vector3.new(value[1], value[2])
			end
		},
		{
			-- type
			'double[]',
			-- default
			{},
			-- To Serialize
			function(schema, field, value)
				local out = {}

				for _, vec2 in ipairs(value) do
					if typeof(vec2) ~= 'Vector2' then
						out[#out+1] = 0
						out[#out+1] = 0
					else
						out[#out+1] = vec2.X
						out[#out+1] = vec2.Y
					end
				end

				return out
			end,
			-- To Instance
			function(schema, field, value)
				local out = {}
				if value == nil or #value == 0 then
					return out
				end

				for i = 1, #value, 2 do
					out[#out+1] = Vector3.new(value[i], value[i+1])
				end
				return out
			end
		}
	},
	[Color3] = {
		--Single
		{
			-- type
			'int32',
			-- default
			EMPTY_COL3,
			-- To Serialize
			function (schema, field, value)
				--// 255 (since Color3.R returns a scalar) * {2^16, 2^8, 2^0}
				return bit32.bor(value.R * 0xFF0000, value.G * 0xFF00, value.B * 0xFF)
			end,
			-- To Instance
			function(schema, field, value)
				if value == nil then
					return EMPTY_COL3
				end
				--// 2^16, 2^8, 2^0
				return Color3.fromRGB(bit32.band(value/65536, 0xFF), bit32.band(value/256, 0xFF), bit32.band(value, 0xFF))
			end
		},
		-- Array
		{
			--type
			'int32[]',
			-- default
			{},
			-- To serialize
			function(schema, field, value)
				local out = {}

				for _, col3 in ipairs(value) do
					if typeof(col3) ~= 'Color3' then
						out[#out+1] = 0
					else
						out[#out+1] = bit32.bor(value.R * 0xFF0000, value.G * 0xFF00, value.B * 0xFF)
					end
				end

				return out
			end,
			-- To Instance
			function(schema, field, value)
				local out = {}
				if value == nil or #value == 0 then
					return out
				end

				for _, n in ipairs(value) do
					out[#out+1] = Color3.fromRGB(bit32.band(n/65536, 0xFF), bit32.band(n/256, 0xFF), bit32.band(n, 0xFF))
				end
				return out
			end
		}
	}
}

return Converters
