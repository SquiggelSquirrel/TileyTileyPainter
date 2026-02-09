GridLayout
----
name :StringName
name_en :String (localise later?)

TileShape (tile_shapes.csv)
----
grid_layout :StringName
shape_id :int
polygon :Array(Vector2) (based on 1x1 dimensions)
neighbor_offsets :Array(Vector2)
neighbor_ids :Array(int) references shape_id
