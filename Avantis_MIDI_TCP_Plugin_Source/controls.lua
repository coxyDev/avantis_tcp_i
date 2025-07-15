-- Connection controls
table.insert(ctrls, {
  Name = "Connect",
  ControlType = "Button",
  ButtonType = "Toggle",
  Count = 1,
  UserPin = true,
  PinStyle = "Both"
})

table.insert(ctrls, {
  Name = "Connected",
  ControlType = "Indicator",
  IndicatorType = "Led",
  Count = 1,
  UserPin = true,
  PinStyle = "Output"
})

-- Input channel controls
local inputChannels = props["Input Channels"].Value
for i = 1, inputChannels do
  -- Mute controls
  table.insert(ctrls, {
    Name = "Input_" .. i .. "_Mute",
    ControlType = "Button",
    ButtonType = "Toggle",
    Count = 1,
    UserPin = true,
    PinStyle = "Both"
  })
  
  -- Fader controls
  table.insert(ctrls, {
    Name = "Input_" .. i .. "_Fader",
    ControlType = "Knob",
    ControlUnit = "dB",
    Min = -60,
    Max = 10,
    Count = 1,
    UserPin = true,
    PinStyle = "Both"
  })
end

-- Master controls
if props["Include Master"].Value then
  table.insert(ctrls, {
    Name = "Master_L_Mute",
    ControlType = "Button",
    ButtonType = "Toggle",
    Count = 1,
    UserPin = true,
    PinStyle = "Both"
  })
  
  table.insert(ctrls, {
    Name = "Master_L_Fader",
    ControlType = "Knob",
    ControlUnit = "dB",
    Min = -60,
    Max = 10,
    Count = 1,
    UserPin = true,
    PinStyle = "Both"
  })
  
  table.insert(ctrls, {
    Name = "Master_R_Mute",
    ControlType = "Button",
    ButtonType = "Toggle",
    Count = 1,
    UserPin = true,
    PinStyle = "Both"
  })
  
  table.insert(ctrls, {
    Name = "Master_R_Fader",
    ControlType = "Knob",
    ControlUnit = "dB",
    Min = -60,
    Max = 10,
    Count = 1,
    UserPin = true,
    PinStyle = "Both"
  })
end

-- Scene recall controls
if props["Include Scene Recall"].Value then
  table.insert(ctrls, {
    Name = "Scene_Number",
    ControlType = "Text",
    Count = 1,
    UserPin = true,
    PinStyle = "Input"
  })
  
  table.insert(ctrls, {
    Name = "Scene_Recall",
    ControlType = "Button",
    ButtonType = "Trigger",
    Count = 1,
    UserPin = true,
    PinStyle = "Input"
  })
end