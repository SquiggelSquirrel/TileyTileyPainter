Document (document.json)
----
save_version :String (int.int.int)
atlases :Array (atlas)
layers :Array (layer)

Atlas (atlases.csv)
----
atlas_id :int
position :Vect2i
tile_size :Vect2i
tile_margins :IntArray (top, right, bottom, left)
tile_spacing :Vect2i (horizontal/vertical)
grid_layout :StringName (needs to reference a grid layout config)

Tile (tiles.csv)
----
atlas_id :int
shape_id :int
position_in_atlas :Vector2i
size_in_atlas :Vector2i
animation_frame_count :int
animation_frame_durations :float
animation_columns :int

Layer (layers.csv) fat/thin
----
layer_id :int
name :String
type :Enum (Paint, Group, Clone, *Filter, *Vector) *tba
visible :Bool
parent_layer_id :int (file not model)

ImageLayer extends Layer (image_layers.csv)
----
mode :Enum (Normal, Mask, Add, Subtract, Multiply, Screen, AddLight, ScreenLight)
alpha_locked :Bool

PaintLayer extends ImageLayer (paint_layers.csv)
----
file :Image File
offset :Vector2i

GroupLayer extends ImageLayer
----
layers :Array (layer)

CloneLayer extends ImageLayer (clone_layers.csv)
----
source_layer :Layer
offset :Vector2i
