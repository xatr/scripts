# dig a mineral vein/layer, add tiles as they are discovered

# reuses the dig mode (upstairs etc) of the selected tile

if df.cursor.x < 0
	puts "Place the game cursor on a tile to dig"
	throw :script_finished
end

tile = df.map_tile_at(df.cursor)
if tile.shape_basic != :Wall or tile.designation.hidden
	puts "Place the game cursor on an unmined, discovered tile"
	throw :script_finished
end

def digmat_watch(tile, digmode, tilelist)
	# watch the tile, expand mining operations when dug out
	tilelist << [tile.x, tile.y, tile.z]
	if tilelist.length == 1
		df.onupdate_register_once("digmat", 10) {
			tilelist.dup.each { |x, y, z|
				t = df.map_tile_at(x, y, z)
				if t.shape_basic != :Wall
					digmat_around(t, digmode, tilelist)
					tilelist.delete [x, y, z]
				end
			}
			tilelist.empty?
		}
	end
	tilelist.uniq!
end

def digmat_around(tile, digmode=tile.designation.dig, tilelist=[])
	digmode = :Default if digmode == :No
	[-1, 0, 1].each { |dz|
		next if digmode == :Default and dz != 0
		[-1, 0, 1].each { |dy|
			[-1, 0, 1].each { |dx|
				ntile = tile.offset(dx, dy, dz)
				next if not ntile
				next if ntile.designation.hidden
				next if ntile.designation.dig != :No
				next if ntile.shape_basic != :Wall
				next if not ntile.mat_info === tile.mat_info

				ntile.dig(digmode)
				digmat_watch(ntile, digmode, tilelist)
			}
		}
	}
end

digmat_around(tile)
