local EMPTY_VEC2 = Vector2.new(0, 0)
local EMPTY_VEC3 = Vector3.new(0, 0, 0)
local EMPTY_REG3 = Region3.new(EMPTY_VEC3, EMPTY_VEC3)
local EMPTY_COL3 = Color3.new(0, 0, 0)
local EMPTY_DATE = DateTime.fromUnixTimestampMillis(0)
local EMPTY_BCOL = BrickColor.new()

local INDEX_META = {}
INDEX_META.__index = function()
	return 0;
end

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
					out[#out+1] = 0
					out[#out+1] = 0
					out[#out+1] = 0
				else
					out[#out+1] = value.X
					out[#out+1] = value.Y
					out[#out+1] = value.Z
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
	[Color3] = {
		--Single
		{
			-- type
			'int32',
			-- default
			EMPTY_COL3,
			-- To Serialize
			function (schema, field, value)
				--// 255 * {2^16, 2^8, 2^0}
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
	},
	[DateTime] = {
		{
			-- Single
			'int53',
			EMPTY_DATE,
			-- To Serialize
			function (schema, field, value)
				return value.UnixTimestampMillis
			end,
			-- To Instance
			function(schema, field, value)
				if value == nil then
					return EMPTY_DATE
				end
				return DateTime.fromUnixTimestampMillis(value)
			end
		},
		{
			'int53[]',
			{},
			function (schema, field, value)
				local out = {}

				for _, v in ipairs(value) do
					out[#out+1] = v.UnixTimestampMillis
				end

				return out
			end,
			function(schema, field, value)
				local out = {}
				if value == nil or #value == 0 then
					return out
				end

				for _, n in ipairs(value) do
					out[#out+1] = DateTime.fromUnixTimestampMillis(n)
				end
				return out
			end
		}
	},
	[BrickColor] = {
		{
			'int32',
			EMPTY_BCOL,
			function (schema, field, value)
				return value.Number
			end,
			function (schema, field, value)
				return value and BrickColor.new(value) or EMPTY_BCOL
			end
		},
		{
			'int53[]',
			{},
			function (schema, field, value)
				local out = {}

				--// Since the highest value possible is 1032, which uses 11 bits, we can only store 4 BrickColor in 53 bits.
				--// Same algorithm as the RGB conversion.

				setmetatable(value, INDEX_META) --// Setting it to INDEX_META (which makes indexing empty field return 0 instead of raising an error.) to avoid long ternary statement

				for i = 1, #value, 4 do --// 2^33, 2^22, 2^11
					out[i] = value[i+3].Number * 8589934592 + value[i+2].Number * 4194304 + value[i+1].Number * 2048 + value[i].Number
				end

				setmetatable(value, nil)

				return out
			end,
			function (schema, field, value)
				local out = {}

				if value == nil or #value == 0 then
					return out
				end

				--// BrickColor index starts at 1, so we can assume 0 as it doesnt contain the value.
				local Decode = function(n, d)
					local Result = bit32.band(n/d, 0x7FF)

					if Result == 0 then
						return
					end

					out[#out+1] = BrickColor.new(Result)

					return true
				end

				for _, n in ipairs(value) do
					out[#out+1] = BrickColor.new(bit32.band(n, 0x7FF))

					--// Lazy evaluation made this work. (Kinda abuse)
					if Decode(n, 2048) and Decode(n, 4194304) and Decode(n, 8589934592) then

					end
				end

				return out
			end
		}
	}
}


return Converters
