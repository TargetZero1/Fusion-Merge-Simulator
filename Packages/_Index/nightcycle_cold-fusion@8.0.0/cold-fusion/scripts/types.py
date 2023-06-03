import io
import requests
import json
import os

API_DUMP_URL = "https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.json"
API = requests.get(url = API_DUMP_URL, params = {}).json()
CLASS_API = API["Classes"]
ENUM_API = API["Enums"]

FILTERS = [
	"VideoFrame",
	"PluginGui",
	"AdGui",
	"TextureGuiExperimental",
	"CanvasGroup",
	"TextBox",
	"UITableLayout",
	"UIPageLayout",
	"UITextSizeConstraint",
	"BillboardGui",
	"LayerCollector"
]

ROOTS = [
	# "Accoutrement",
	# "Attachment",
	# "Atmosphere",
	# "BaseWrap",
	# "Beam",
	# "BodyMover",
	# "Camera",
	# "CharacterAppearance",
	# "Clouds",
	# "Constraint",
	# "FaceInstance",
	# "FaceControls",
	# "Fire",
	# "GuiBase2d",
	# "Highlight",
	# "Humanoid",
	# "HumanoidDescription",
	# "IKControl",
	# "Light",
	# "Lighting",
	# "MaterialVariant",
	# "PVInstance",
	# "PathfindingLink",
	# "PathfindingModifier",
	# "ParticleEmitter",
	# "Plugin",
	# "Player",
	# "PostEffect",
	# "ProximityPrompt",
	# "Sky",
	# "Smoke",
	# "Sound",
	# "SoundEffect",
	# "SoundGroup",
	# "Sparkles",
	# "SurfaceAppearance",
	# "Team",
	# "Trail",
	# "UIBase",
	# "ValueBase",
	# "WeldConstraint"
]

DEBUG_PATH = "scripts/api.json"

enums = []
for enum_data in ENUM_API:
	enums.append(enum_data["Name"])

exported_classes = []
registry = []
classes = {}
class_events = {}
class_properties = {}

for class_data in CLASS_API:
	classes[class_data["Name"]] = class_data
	is_ancestor = False
	for child_data in CLASS_API:
		if child_data["Superclass"] == class_data["Name"]:
			is_ancestor = True

	if is_ancestor == False:
		is_deprecated = False
		if "Tags" in class_data:
			tag_data = class_data["Tags"]
			if "Deprecated" in tag_data and class_data["Superclass"] != "BodyMover":
				is_deprecated = True
		if class_data["Name"] == "RocketPropulsion":
			is_deprecated = True
			
		if is_deprecated == False:
			exported_classes.append(class_data["Name"])

def formatValueType(val: str):
	if val == "bool":
		return "boolean"
	elif val == "Content" or val == "BinaryString":
		return "string"
	elif val == "float" or val == "int" or val == "int64" or val == "double":
		return "number"
	elif val == "Dictionary":
		return "{[any]: any}"
	elif val == "Array":
		return "{[number]: any}"
	elif val in enums:
		return "Enum."+val
	else:
		return val

def writeType(class_name: str, format_children: bool):
	if not class_name in registry and not class_name in FILTERS:
		registry.append(class_name)

		for class_data in CLASS_API:
			if class_data["Name"] == class_name:
				properties = {}
				events = {}
				
				for member_data in class_data["Members"]:
					is_safe = True
					if "Tags" in member_data:
						tag_data = member_data["Tags"]
						if ("Deprecated" in tag_data and class_data["Superclass"] != "BodyMover") or ("ReadOnly" in tag_data) or ("Hidden" in tag_data) or ("NotScriptable" in tag_data):
							is_safe = False
						
					if " " in member_data["Name"]:
						is_safe = False

					if is_safe:
						if member_data["MemberType"] == "Property":
							properties[member_data["Name"]] = member_data["ValueType"]["Name"]
						elif member_data["MemberType"] == "Event":								
							params = []
							param_index = 0
							for param_data in member_data["Parameters"]:
								params.append({
									"Name": param_data["Name"],
									"Type": param_data["Type"]["Name"]
								})
								# params[param_data["Name"]] = param_data["Type"]["Name"]
							events[member_data["Name"]] = params
				
				if len(properties) > 0:
					class_properties[class_name] = properties
				else:
					class_properties[class_name] = class_data["Superclass"]

				if len(events) > 0:
					class_events[class_name] = events
				else:
					class_events[class_name] = class_data["Superclass"]

				writeType(class_data["Superclass"], False)
				if class_name != "Instance" and format_children:
					for child_data in CLASS_API:
						if child_data["Superclass"] == class_name:
							writeType(child_data["Name"], format_children)


for class_name in ROOTS:
	writeType(class_name, True)

if os.path.exists(DEBUG_PATH):
	os.remove(DEBUG_PATH)
debugWriter = io.open(DEBUG_PATH, "w")
debugWriter.write(json.dumps(class_events, indent=4))
debugWriter.close()

OUT_PATH = "src/InstanceTypes.lua"
if os.path.exists(OUT_PATH):
	os.remove(OUT_PATH)

writer = io.open(OUT_PATH, "w")

writer.write("""--!strict
type State<T> = {
	_Value: T,
	Get: (self: any) -> T,
}
type CanBeState<T> = State<T> | T""")
def getFirstAncestor(class_name: str, class_dict: dict):
	if class_name in class_dict:
		class_data = class_dict[class_name]
		if type(class_data) == str:
			return getFirstAncestor(classes[class_name]["Superclass"], class_dict)
		else:
			return class_name
	return None

switch_class_names = []
for class_name in class_properties:
	class_data = class_properties[class_name]

	if type(class_data) != str:
		if class_name in exported_classes:
			switch_class_names.append(class_name)

		writer.write("\n\ntype "+class_name+"Properties = {\n\t[string]: nil,")
		for k in class_data:
			writer.write("\n\t"+k+": CanBeState<"+formatValueType(class_data[k])+">?,")

		ancestor_name = getFirstAncestor(classes[class_name]["Superclass"], class_properties)
		if ancestor_name != None:
			writer.write("\n} & " + ancestor_name + "Properties")
		else:
			writer.write("\n}")

for class_name in class_events:
	class_data = class_events[class_name]

	if type(class_data) != str:
		if class_name in exported_classes:
			switch_class_names.append(class_name)

		writer.write("\n\ntype "+class_name+"Events = {\n\t[string]: nil,")

		for event_name in class_data:
			event_func = "(("
			param_index = 0
			for param in class_data[event_name]:
				param_index += 1
				if param_index > 1:
					event_func += ", "
				event_func += param["Name"]+": "+formatValueType(param["Type"])
			event_func += ") -> nil)"
			writer.write("\n\t"+event_name+": "+event_func+"?,")
		
		ancestor_name = getFirstAncestor(classes[class_name]["Superclass"], class_events)
		if ancestor_name != None:
			writer.write("\n} & " + ancestor_name + "Events")
		else:
			writer.write("\n}")


writer.write("\n\nexport type InstanceConstructor = (")

prop_count = 0
for class_name in switch_class_names:
	if prop_count == 0:
		writer.write("\n\t")
	else:
		writer.write("\n\t& ")
	writer.write("((className: \""+class_name+"\") -> (properties: {")

	if class_name in class_properties:
		if type(class_properties[class_name]) == str:
			writer.write("\n\t\tProperties: "+getFirstAncestor(class_name, class_properties)+"Properties?,")
		else:
			writer.write("\n\t\tProperties: "+class_name+"Properties?,")
	else:
		writer.write("\n\t\tProperties: {[string]: CanBeState<any>}?,")
	

	writer.write("\n\t\tChildren: {[number]: Instance}?,")
	
	if class_name in class_events:
		if type(class_events[class_name]) == str:
			writer.write("\n\t\tEvents: "+getFirstAncestor(class_name, class_events)+"Events?,")
		else:
			writer.write("\n\t\tEvents: "+class_name+"Events?,")
	else:
		writer.write("\n\t\tEvents: {[string]: () -> nil}?,")

	writer.write("\n\t\tAttributes: {[string]: CanBeState<any>}?,")
	writer.write("\n\t}) -> "+class_name+")")
	prop_count += 1
if len(switch_class_names) > 0:
	writer.write("""
& ((className: string) -> (properties: {
	[string]: CanBeState<any>,
	Children: {[number]: any}?,
	Events: {[string]: () -> nil}?,
	Attributes: {[string]: CanBeState<any>}?,
}) -> Instance)""")
else:
	writer.write("""
((className: string) -> (properties: {
	[string]: CanBeState<any>,
	Children: {[number]: any}?,
	Events: {[string]: () -> nil}?,
	Attributes: {[string]: CanBeState<any>}?,
}) -> Instance)""")

writer.write("\n)")

writer.write("\n\nexport type InstanceMounter = (")
prop_count = 0
for class_name in switch_class_names:
	if prop_count == 0:
		writer.write("\n\t")
	else:
		writer.write("\n\t& ")
	writer.write("((inst: "+class_name+") -> (properties: {")	

	writer.write("\n\t\tChildren: {[number]: CanBeState<Instance?>}?,")
	
	if class_name in class_events:
		if type(class_events[class_name]) == str:
			writer.write("\n\t\tEvents: "+getFirstAncestor(class_name, class_events)+"Events?,")
		else:
			writer.write("\n\t\tEvents: "+class_name+"Events?,")
	else:
		writer.write("\n\t\tEvents: {[string]: () -> nil}?,")

	writer.write("\n\t\tAttributes: {[string]: CanBeState<any>}?,")
	writer.write("\n\t}")
	if class_name in class_properties:
		if type(class_properties[class_name]) == str:
			writer.write(" & "+getFirstAncestor(class_name, class_properties)+"Properties")
		else:
			writer.write(" & "+class_name+"Properties")
	else:
		writer.write("\n\t\t[string]: CanBeState<any>?,")
	writer.write(") -> "+class_name+")")
	prop_count += 1
if len(switch_class_names) > 0:
	writer.write("""
& ((inst: Instance) -> (properties: {
	Children: {[number]: CanBeState<Instance?>}?,
	Events: {[string]: () -> nil}?,
	Attributes: {[string]: CanBeState<any>}?,
	[string]: CanBeState<any>,
}) -> Instance)""")

else:
	writer.write("""
((inst: Instance) -> (properties: {
	Children: {[number]: CanBeState<Instance?>}?,
	Events: {[string]: () -> nil}?,
	Attributes: {[string]: CanBeState<any>}?,
	[string]: CanBeState<any>,
}) -> Instance)""")

writer.write("\n)")

print(json.dumps(switch_class_names, indent=4))

writer.write("""
return {}
""")

writer.close()

# os.system("stylua "+OUT_PATH)