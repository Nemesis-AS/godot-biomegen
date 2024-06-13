extends TileMap

#@export var world_size: Vector2i = Vector2i(144, 81)
#@export var world_size: Vector2i = Vector2i(1000, 1000)

@export var tile_size: Vector2i = Vector2i(8, 8)
@export var chunk_size: Vector2i = Vector2i(16, 16)
@export var view_distance: int = 12 #2

@export var CAMERA: Camera2D

const BIOMES: Array = [
	# ALTITUDE: -1 to -0.5
	[
		[
			# HUMIDITY: -1 to -0.5
			"Frozen Ocean",
			# HUMIDITY: 0.5 to 0
			"Frozen Ocean",
			# HUMIDITY: 0 to 0.5
			"Frozen Ocean",
			# HUMIDITY: 0.5 to 1
			"Frozen Ocean",
		],
		# -0.5 to 0
		[
			# HUMIDITY: -1 to -0.5
			"Frozen Ocean",
			# HUMIDITY: 0.5 to 0
			"Frozen Ocean",
			# HUMIDITY: 0 to 0.5
			"Ocean",
			# HUMIDITY: 0.5 to 1
			"Ocean",
		],
		# 0 to 0.5
		[
			# HUMIDITY: -1 to -0.5
			"Ocean",
			# HUMIDITY: 0.5 to 0
			"Ocean",
			# HUMIDITY: 0 to 0.5
			"Ocean",
			# HUMIDITY: 0.5 to 1
			"Ocean",
		],
		# 0.5 to 1
		[
			# HUMIDITY: -1 to -0.5
			"Ocean",
			# HUMIDITY: 0.5 to 0
			"Ocean",
			# HUMIDITY: 0 to 0.5
			"Ocean",
			# HUMIDITY: 0.5 to 1
			"Ocean",
		]
	],
	# ALTITUDE: -0.5 to 0
	[
		# TEMP: -1 to -0.5
		[
			# HUMIDITY: -1 to -0.5
			"Taiga",
			# HUMIDITY: 0.5 to 0
			"Taiga",
			# HUMIDITY: 0 to 0.5
			"Taiga",
			# HUMIDITY: 0.5 to 1
			"Taiga",
		],
		# TEMP:  -0.5 to 0
		[
			# HUMIDITY: -1 to -0.5
			"Plains",
			# HUMIDITY: 0.5 to 0
			"Plains",
			# HUMIDITY: 0 to 0.5
			"Plains",
			# HUMIDITY: 0.5 to 1
			"Plains",
		],
		# TEMP:  0 to 0.5
		[
			# HUMIDITY: -1 to -0.5
			"Desert",
			# HUMIDITY: 0.5 to 0
			"Plains",
			# HUMIDITY: 0 to 0.5
			"Plains",
			# HUMIDITY: 0.5 to 1
			"Swamp",
		],
		# TEMP:  0.5 to 1
		[
			# HUMIDITY: -1 to -0.5
			"Desert",
			# HUMIDITY: 0.5 to 0
			"Savanna",
			# HUMIDITY: 0 to 0.5
			"Swamp",
			# HUMIDITY: 0.5 to 1
			"Swamp",
		]
	],
	# ALTITUDE: 0 to 0.5
	[
		# TEMP: -1 to -0.5 
		[
			# HUMIDITY: -1 to -0.5
			"Taiga",
			# HUMIDITY: 0.5 to 0
			"Taiga",
			# HUMIDITY: 0 to 0.5
			"Plains",
			# HUMIDITY: 0.5 to 1
			"Taiga",
		],
		# TEMP: -0.5 to 0
		[
			# HUMIDITY: -1 to -0.5
			"Taiga",
			# HUMIDITY: 0.5 to 0
			"Forest",
			# HUMIDITY: 0 to 0.5
			"Plains",
			# HUMIDITY: 0.5 to 1
			"Forest",
		],
		# 0 to 0.5
		[
			# HUMIDITY: -1 to -0.5
			"Savanna",
			# HUMIDITY: 0.5 to 0
			"Savanna",
			# HUMIDITY: 0 to 0.5
			"Plains",
			# HUMIDITY: 0.5 to 1
			"Forest",
		],
		# 0.5 to 1
		[
			# HUMIDITY: -1 to -0.5
			"Desert",
			# HUMIDITY: 0.5 to 0
			"Savanna",
			# HUMIDITY: 0 to 0.5
			"Swamp",
			# HUMIDITY: 0.5 to 1
			"Swamp",
		]
	],
	# ALTITUDE: 0.5 to 1
	[
		[
			# HUMIDITY: -1 to -0.5
			"Snowy Taiga",
			# HUMIDITY: 0.5 to 0
			"Snowy Taiga",
			# HUMIDITY: 0 to 0.5
			"Snowy Taiga",
			# HUMIDITY: 0.5 to 1
			"Snowy Taiga",
		],
		# -0.5 to 0
		[
			# HUMIDITY: -1 to -0.5
			"Snowy Taiga",
			# HUMIDITY: 0.5 to 0
			"Snowy Taiga",
			# HUMIDITY: 0 to 0.5
			"Forest",
			# HUMIDITY: 0.5 to 1
			"Forest",
		],
		# 0 to 0.5
		[
			# HUMIDITY: -1 to -0.5
			"Savanna",
			# HUMIDITY: 0.5 to 0
			"Savanna",
			# HUMIDITY: 0 to 0.5
			"Swamp",
			# HUMIDITY: 0.5 to 1
			"Swamp",
		],
		# 0.5 to 1
		[
			# HUMIDITY: -1 to -0.5
			"Desert",
			# HUMIDITY: 0.5 to 0
			"Savanna",
			# HUMIDITY: 0 to 0.5
			"Swamp",
			# HUMIDITY: 0.5 to 1
			"Swamp",
		]
	]
]

const BIOME_KEYS: Dictionary = {
	"Ocean": Vector2i(0, 0),
	"Frozen Ocean": Vector2i(1, 0),
	"Plains": Vector2i(2, 0),
	"Taiga": Vector2i(3, 0),
	"Forest": Vector2i(4, 0),
	"Desert": Vector2i(5, 0),
	"Snowy Taiga": Vector2i(6, 0),
	"Savanna": Vector2i(7, 0),
	"Swamp": Vector2i(8, 0),
}

var alt_noise: FastNoiseLite = FastNoiseLite.new()
var temp_noise: FastNoiseLite = FastNoiseLite.new()
var hum_noise: FastNoiseLite = FastNoiseLite.new()

var prev_chunks: Dictionary = {}
var generated_chunks: Dictionary = {}

func _ready() -> void:
	randomize()
	
	var map_seed = randi()
	_initialize_noise(map_seed)
	generate_world(CAMERA.get_target_position())
	
	if CAMERA:
		CAMERA.update_map.connect(_on_update_map)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		return
	
	if event is InputEventKey:
		match event.keycode:
			KEY_R:
				var map_seed = randi()
				_initialize_noise(map_seed)
				generate_world(CAMERA.get_target_position())

func _initialize_noise(map_seed: int) -> void:
	alt_noise.seed = map_seed
	temp_noise.seed = map_seed * 2
	hum_noise.seed = map_seed * 3

func generate_world(ref: Vector2) -> void:
	# Mark current chunks as previous
	prev_chunks = generated_chunks
	generated_chunks = {}
	
	# Get the chunk the camera is in
	var ref_coord = Vector2i(int(ref.x / (chunk_size.x * tile_size.x)), int(ref.y / (chunk_size.y * tile_size.y)))
	
	# Determine which chunks to generate
	for y in range(-view_distance, view_distance):
		for x in range(-view_distance, view_distance):
			var chunk_coord = Vector2i(
				ref_coord.x + x,
				ref_coord.y + y
			)
			
			if prev_chunks.has(chunk_coord):
				generated_chunks[chunk_coord] = 1
				prev_chunks.erase(chunk_coord)
				continue
			
			generate_chunk(chunk_coord)
	
	# Clear chunks previously generated that are outside view distance
	for coord in prev_chunks:
		clear_chunk(coord)

func generate_chunk(chunk_coord: Vector2i) -> void:
	var offset = Vector2(chunk_coord.x * chunk_size.x, chunk_coord.y * chunk_size.y)
	
	for ry in range(chunk_size.y):
		var y = offset.y + ry
		for rx in range(chunk_size.x):
			var x = offset.x + rx
			
			var alt = alt_noise.get_noise_2d(x, y)
			var temp = temp_noise.get_noise_2d(x, y)
			var hum = hum_noise.get_noise_2d(x, y)
			
			var biome = get_biome(alt, temp, hum)
			var biome_coord = BIOME_KEYS[biome]
			
			self.set_cell(0, Vector2i(x, y), 0, biome_coord)
	
	generated_chunks[chunk_coord] = 1

func clear_chunk(chunk_coord: Vector2i) -> void:
	var offset = Vector2(chunk_coord.x * chunk_size.x, chunk_coord.y * chunk_size.y)
	
	for ry in range(chunk_size.y):
		var y = offset.y + ry
		for rx in range(chunk_size.x):
			var x = offset.x + rx
			
			self.erase_cell(0, Vector2i(x, y))

func get_biome(altitude: float, temperature: float, humidity: float) -> String:
	var alt_key = int((altitude / 0.5) + 2)
	var temp_key = int((temperature / 0.5) + 2)
	var hum_key = int((humidity / 0.5) + 2)
	
	return BIOMES[alt_key][temp_key][hum_key]

func _on_update_map(new_pos: Vector2) -> void:
	generate_world(new_pos)
