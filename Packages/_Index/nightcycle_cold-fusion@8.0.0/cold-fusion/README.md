# Cold Fusion
A wrapper for Fusion built up to promote quick, readable, and memory safe implementation of UI components.

# Fuse
In order to prevent memory leaks, a state constructor needs to be made. This is called a fuse and may optionally have a maid passed to it during its construction. When a fuse is destroyed all signals, constructed instances, and tweens are disconnected.

```lua
-- require package
local ColdFusion = require(path.to.package)

-- unpack workspace
local fuse = ColdFusion.fuse()
local _new = _fuse.new
local _bind = _fuse.bind
local _clone = _fuse.clone
local _import = _fuse.import
local _Value = _fuse.Value
local _Computed = _fuse.Computed

local Position = _Value(UDim2.fromScale(0.5,0.5))

local frame = _new("Frame")({
	Name = "Test",
	Position = Position:Tween(0.5),
})

local destSignal
destSignal = frame.Destroying:Connect(function()
	destSignal:Disconnect()
	-- cleans up everything constructed by the fuse + signals + tweens
	fuse:Destroy()
end)
```

# States
At the core of Cold Fusion and Fusion is the state. In Cold Fusion it's reduced to two states: ValueState and State.


## ValueState
A value state allows you to store and change inputs into a state system. 

```lua
local fuse = ColdFusion.fuse()
local _Value = _fuse.Value

local Position = _Value(UDim2.fromScale(0.5,0.5))

-- changes inner value, triggering any connections
Position:Set(UDim2.fromScale(0.25,0.25))

-- setting it to the same value won't trigger a change
Position:Set(UDim2.fromScale(0.25,0.25))

-- you can read a state
print(Position:Get()) --should print UDim2.fromScale(0.25, 0.25)

```

## State
A state is read-only, often solved for as underlying parameters change. The most simple version of it is the _Computed state.

```lua
local fuse = ColdFusion.fuse()
local _Value = _fuse.Value

local ViewportSize = _Value(Vector2.new(1200, 800))

-- to bind a state, pass it as a parameter following the processor function. 
-- it should properly typecheck the first dozen parameters to the underlying state
local Position = _Computed(function(vSize: Vector2): UDim2
	return UDim2.fromOffset(vSize.X, vSize.Y)
end, ViewportSize)

ViewportSize:Set(Vector2.new(600, 400)) -- triggers Position to recalculate, now with a value of UDim2.fromOffset(600, 400)
```

## Helper Functions
This is where Cold Fusion really sets itself apart from the original Fusion library. Both States and ValueStates have all of these functions.

### Destroy
If you want to clean up just a single state, you can do that.
```lua
	local State = _Value("ABC")
	State:Destroy()
```

### Animation
A lot of front-end instances require animation to look nice, with Cold Fusion this has never been easier.

```lua
	local TransitionDuration = _Value(1)
	local TweenStyle = _Value(Enum.EasingStyle.Quad)
	local Position = _Value(UDim2.fromScale(0.5,0.5))
	
	-- You can add all the tween info parameters if you like.
	-- Any parameter can be a state if you like
	local TweenPosition = Position:Tween(
		TransitionDuration,
		TweenStyle,
		Enum.EasingDirection.InOut,
		0,
		false,
		0
	)

	-- or not lol, the default is 0.2 duration, quad style, and in-out direction.
	local QuickTweenPosition = Position:Tween()

	-- you can even make tweens of tweens,
	local MegaQuickTweenPosition = Position:Tween():Tween()

	-- if you want something a bit more dynamic, springs are also available
	local SpringSpeed = _Value(10)

	-- due to how memory is automatically tracked with Cold-Fusion, you can set-up single-use tweens/springs if you like, such as for a parameter of a function.
	local PositionSpring = Position:Spring(
		SpringSpeed:Tween(), -- speed
		5 -- damping ratio
	)

	-- These states can be used as the input for a computed state, which will update whenever any of the parameter states do.
	local AveragePosition = _Computed(function(springPos: UDim2, tweenPos: UDim2)
		local xOffset = (springPos.X.Offset +  tweenPos.X.Offset)/2
		local yOffset = (springPos.Y.Offset +  tweenPos.Y.Offset)/2
		local xScale = (springPos.X.Scale +  tweenPos.X.Scale)/2
		local yScale = (springPos.Y.Scale +  tweenPos.Y.Scale)/2
		return UDim2.new(xScale, xOffset, yScale, yOffset)
	end, PositionSpring, TweenPosition)
```

### Table Iterators
This is useful for constructing a ton of instances off of data, as well as formatting the data. 
```lua

	-- Initial data input
	local Data = _Value({
		"A" = 1,
		"B" = 2,
		"C" = 3,
		"D" = 4,
		"E" = 5,
		"F" = 6,
	})

	-- triggers when either key or value changes, outputs a state with a table of doubled values
	local DoubleData = Data:ForPairs(function(key: string, value: number, maid: Maid)
		return key, value * 2 --always return a key and value for reliably solving behvaior
	end)

	-- triggers when a key changes, outputs a state with a table of lowercase keys
	local LowerData = Data:ForKeys(function(key: string, maid: Maid)
		return string.lower(key) --always return something for reliably solving behvaior
	end)

	-- alternatively you can bind the running of the function to a new value
	-- by constructing a fuse with the maid you can construct and clean-up components with changes
	Data:ForValues(function(value: number, maid: Maid)
		local fuse = ColdFusion.fuse(maid)
		local textLabel = fuse.new("TextLabel")({
			Text = tostring(value),
		})
		return value --always return something for reliably solving behvaior
	end)
```
It's important to note that if you update Data in the above example with a completely new table, it will run the processor for every key/value. If you :Get(), change the table, then :Set() however it will only update for the relevant changes. This can be much faster, especially when constructing UI for each change.

### Connect	
Sometimes you just want to use a state like a signal, so the :Connect function allows you to do just that.
```lua
	local State = _Value(5)
	local connectionCleanUp = State:Connect(function(current: number, previous: number?)
		print(previous, "->", current) 
	end)

	task.wait(10)
	connectionCleanUp() --removes connection

```
It does return a clean-up function which will disconnect the signal, however the fuse constructor is also tracking it so unless you want to clean it up early you can just ignore it.

### Read	
This is a useful function for when your value is a more complex datatype. It allows you to read a property of an instance.
```lua
	local Input = _Value(Vector3.new(1,0,0))
	local XProperty = Input:Read("X") --the key parameter can be a state if desired
	Input:Set(Vector3.new(2,0,0))
	print(XProperty:Get()) --prints 2
```
Important thing to note, this does not update when the underlying property updates - this is just about reading the property at the time the state's value updates.

### Miscellaneous Operations
They're all quite similar, and all of them can use either a state or regular data-type as the second parameter.
```lua
	local A = _Value(5)
	local B = _Value(3)
	local Pi = _Value(math.pi)

	-- Math
	local Sum = A:Add(B) -- value of 8
	local Difference = A:Subtract(1) -- value of 4
	local Product = B:Multiply(Difference) -- value of 12
	local Quotient = Product:Divide(6) --value of 2
	local Round = Pi:Round() --value of 3
	
	-- String
	local AStr = A:ToString() -- value of "5"
	local Caps = Label:Upper() -- value of "NUMBER 5"
```

# Import
Sometimes it's useful to be able to standardize inputs to states, this function allows for that:
```lua
-- these might not be states
local a = "A"
local b = _Value("B")

-- these are both states
local A: State<string> = _import(a)
local B: State<string> = _import(b)

```

# Instance Operations
In order to make most of these state objects, you need to be able to interact with the Roblox Instance classes.

## Methods
There are three major ways to connect to an instance: "new", "bind", and "clone".

### New
New allows you to construct a new instance from the class name.
```lua
	local Position = _Value(UDim2.fromScale(0.5,0.5))
	local frame = _new("Frame")({
		Name = "Frame",
		Position = Position:Tween(),
	})
```
Any instances created are cleaned up when fuse is destroyed. If the instance is destroyed the signals are disconnected.

### Bind
Bind allows you to connect to a pre-existing asset. This is called "Hydrate" in Fusion.
```lua
	local Color = _Value(Color3.new(0,0,0))
	local Lighting = game:GetService("Lighting")
	_bind(Lighting)({
		OutdoorAmbiemt = Color:Tween(10),
	})
```
Unlike the "new" constructor, when the fuse is deleted the instance is not deleted.

### Clone
Clone is useful for when you have a template instance. Like "new" it when the fuse is destroyed it will clean up the constructed instance, however excluding that it functions identical to bind.
```lua
local template: ParticleEmitter 

local Light = _Value(1)
local particle = _clone(template)({
	LightEmission = Light:Tween(),
})
```

## Structure
Beyond just basic properties you can also set children, events, and attributes. Fusion accomplishes this with unique keys, however I have opted to do a slightly more streamlined approach.

Here's an example of what it all looks like in action:
```lua

local IsButtonA = _Value(false)

local buttonA = _new("TextButton")({
	Name = "A",
	Events = { -- connects functions to events
		Activated = function()
			print("A")
		end,
	}
})
local buttonB = _new("TextButton")({
	Name = "B",
	Events = { -- connects functions to events
		Activated = function()
			print("B")
		end,
	}
})

local frame = _new("Frame")({
	Name = "Frame",
	BackgroundColor3 = Color3.new(0,0,0),
	Children = { --parents the children instances to the current instance
		_new("UICorner")({
			CornerRadius = UDim.new(0,0),
		}),
		_Computed(function(isA: boolean): TextButton
			if isA then
				return buttonA
			else
				return buttonB
			end
		end, IsButtonA)
	} :: {[number]: any},
	Attributes = { -- writes an attribute based on the state
		IsButtonA = IsButtonA,
	},
})

```
When useful I swapped out unique symbols for string keys with a dictionary value.

### Children
The children table works pretty similarly to the normal fusion table, with the exception of allowing for the children table to be a state itself. I might do this eventually, but to be honest I've never used that pattern across my dozens if not hundreds of components written. Like fusion instances can be replaced with states. I recommend not constructing the instances within those states for memory usage reasons, however that is up to you.

One thing to note though is the typechecker seems to really want arrays to all be of the same type. No matter what I put in the custom type here I can't get it to enforce the typing onto the table itself. This means if one child is a generic "Instance" type and another is a "GuiObject", it will error. You can get this error to go away with variations of  ":: {[number]: any}".

### Events
The event table also removes the symbol based manner or organizing in favor of a single table. The functions are keyed to the event they're bound to. These do need to be functions, not states, and the entire table also needs to remain a table, not a state. The parameters of the event will be passed into the function. These functions should never return anything.

### Attributes
For the sake of debugging / communicating with other systems, you can have attibute friendly value containing states set an attribute when they update. This is currently a read only set-up, it will not allow you to change a ValueState when an attribute is changed by another script. I'm not sure if I'll change this later, however for now I've not found that functionality necessary.

## Things I Didn't Carry Over
There are some features of fusion that I did not carry over to the current version of Cold Fusion. You might not agree with these decisions, they are opinionated and biased towards my own workflow, however I am relatively content with them for now. If you really need one of these features before I decide to add them you're welcome to fork the repo.

### OnChange / OnAttributeChange / Out / AttributeOut
This is an area which I am split on. Quite often I wish to know the AbsoluteSize / Position of a GuiObject. Unfortunately though, the absolute values (and position / cframe values for base parts) don't reliably fire the changed event. This is a Roblox issue, not a Fusion one. As a result, whenever I need these values I usually just have to set up a RenderStepped event that updates a ValueState each frame. It's not ideal, but it's the only viable option.

Beyond that though, I rarely desire to know the value of an instance property. I also do find the unidirectional design pattern where the configuration table is completely focused on rendering an internal state to be cleaner than allowing for it to also define internal state. That being said, I can imagine use cases which would benefit from this feature being re-implemented. I however am in no rush to do so. 

### Ref
I understand that the vision for fusion is to render an entire component in a single tree, and this allows for the easy referencing of components deep within that tree. In my experience though these super deep trees are harder to read / make sense of. It feels like the table equivalent of when someone writes a for loop on a single line. Being able to assign sub-sections of the component to variables is a positive in my experience, not a negative. Because of that I've chosen not to include this for the sake of keeping my components readable.


### Cleanup
As one of the core goals of this wrapper was to automate memory tracking and clean-up, this symbol is no longer as useful as it once was. 

# Conclusion
This is a framework I developed entirely for my own uses, however you are welcome to use it. Here are some directions I hope to further explore with it:
- Performant instance-specific property / event autocomplete with Luau-LSP
- Establish compatibility with Fusion
- Incorporate my CurveUtil package into the tween / spring functions to allow for lerping of more datatypes.
- Document and publish Cold Fusion components as an accessory library.
- Keep the Fusion foundation up-to-date with the main library.
- Optionally delay computations a frame to avoid redundant processing when multiple parameters change in the same frame.

Thank you for reading! Hope you enjoy
