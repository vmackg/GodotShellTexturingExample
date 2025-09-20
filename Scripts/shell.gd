@tool
extends Node3D

@export_range(0, 100, 1) var TotalLayers :int = 48:
	set(v) : TotalLayers = v; call_deferred("Init")
@export_range(0, 1000) var Density :float    = 150.0:
	set(v) : Density = v;UpdateParam("Density")
@export_range(0, 10) var ShellLength :float  = 0.6:
	set(v) : ShellLength = v; UpdateParam("ShellLength")
@export_range(0, 10) var SpreadPow :float    = 0.7:
	set(v) : SpreadPow = v; UpdateParam("SpreadPow")
@export_color_no_alpha var ShellColor : Color = Color.GREEN:
	set(v) : ShellColorRGB = Vector3(v.r, v.g, v.b); ShellColor = v
@export var ShellMesh :Mesh = PlaneMesh.new():
	set(m): ShellMesh = m; call_deferred("Init")

var ShellColorRGB :Vector3 = Vector3(0, 1, 0):
	set(v) : ShellColorRGB = v; UpdateParam("ShellColorRGB")

const SHELL_SHADER :Shader = preload("res://Shaders/shell.gdshader")

var ShaderMat :ShaderMaterial = null


const ParamToUniform :Dictionary[String, String] = {
	"TotalLayers" : "uTotalLayers",
	"Density"     : "uDensity",
	"ShellLength" : "uShellLength",
	"SpreadPow"   : "uSpreadPow",
	"ShellColorRGB"  : "uColor"
}

func UpdateParam(id :String) -> void:
	if not id in ParamToUniform:
		push_error("Unknown Parameter for shader '" + id + "'")
		return
	
	for i in get_children():
		if not i is MeshInstance3D : 
			push_error("Unidentified child of " + name + ", name : " + i.name)
			continue
		
		var m :ShaderMaterial = i.material_overlay
		m.set_shader_parameter(ParamToUniform[id], get(id))
		
		
	pass

func Init() -> void:
	ShaderMat = ShaderMaterial.new()
	ShaderMat.shader = SHELL_SHADER
	
	ShaderMat.set_shader_parameter("uTotalLayers", TotalLayers)
	ShaderMat.set_shader_parameter("uLayerIndex", 0)
	ShaderMat.set_shader_parameter("uDensity", Density)
	ShaderMat.set_shader_parameter("uShellLength", ShellLength)
	ShaderMat.set_shader_parameter("uSpreadPow", SpreadPow)
	
	for i in get_children():
		i.queue_free()
	
	for i in range(TotalLayers):
		var inst :MeshInstance3D = MeshInstance3D.new()
		inst.mesh = ShellMesh
		
		var dmat :ShaderMaterial = ShaderMat.duplicate()
		dmat.set_shader_parameter("uLayerIndex", i)
		inst.material_overlay = dmat
		dmat.set_shader_parameter("uColor", ShellColorRGB)
		
		inst.name = name + "_Layer_" + str(i)
		
		self.add_child(inst)
		inst.owner = self
	pass
func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("Init")
	pass
