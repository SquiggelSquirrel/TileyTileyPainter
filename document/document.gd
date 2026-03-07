class_name Document
extends Resource

var save_version :String = "0.0.0"
var atlases :Array[Atlas] = []
var layers :Array[Layer] = []
var has_unsaved_changes := true
var save_path :String
