local CurrentPage = PageNames[props["page_index"].Value]
local inputChannels = props["Input Channels"].Value
local includeMaster = props["Include Master"].Value
local includeScenes = props["Include Scene Recall"].Value

if CurrentPage == "Control" then
  -- Connection status
  table.insert(graphics,{
    Type = "GroupBox",
    Text = "Connection",
    Fill = {240,240,240},
    StrokeWidth = 1,
    Position = {5,5},
    Size = {150,60}
  })
  
  layout["Connect"] = {
    PrettyName = "Connection~Connect",
    Style = "Button",
    Position = {15,25},
    Size = {60,25},
    ButtonStyle = "Toggle",
    Color = {0,150,0}
  }
  
  layout["Connected"] = {
    PrettyName = "Connection~Status",
    Style = "Led",
    Position = {85,32},
    Size = {20,10},
    OffColor = {150,0,0},
    OnColor = {0,150,0}
  }
  
  -- Input channels
  local channelsPerRow = 8
  local rows = math.ceil(inputChannels / channelsPerRow)
  local channelWidth = 50
  local channelHeight = 100
  local startY = 75
  
  for i = 1, inputChannels do
    local row = math.floor((i-1) / channelsPerRow)
    local col = (i-1) % channelsPerRow
    local x = 10 + col * (channelWidth + 5)
    local y = startY + row * (channelHeight + 10)
    
    -- Channel strip background
    table.insert(graphics,{
      Type = "GroupBox",
      Text = "CH" .. i,
      Fill = {250,250,250},
      StrokeWidth = 1,
      Position = {x,y},
      Size = {channelWidth,channelHeight}
    })
    
    -- Mute button
    layout["Input_" .. i .. "_Mute"] = {
      PrettyName = "Inputs~CH" .. i .. " Mute",
      Style = "Button",
      Position = {x+5,y+20},
      Size = {channelWidth-10,20},
      ButtonStyle = "Toggle",
      Color = {200,50,50}
    }
    
    -- Fader
    layout["Input_" .. i .. "_Fader"] = {
      PrettyName = "Inputs~CH" .. i .. " Fader",
      Style = "Fader",
      Position = {x+15,y+45},
      Size = {20,50}
    }
  end
  
  -- Master section
  if includeMaster then
    local masterY = startY + rows * (channelHeight + 10) + 20
    
    table.insert(graphics,{
      Type = "GroupBox",
      Text = "Master",
      Fill = {230,230,250},
      StrokeWidth = 2,
      Position = {10,masterY},
      Size = {150,channelHeight}
    })
    
    -- Master L
    layout["Master_L_Mute"] = {
      PrettyName = "Master~L Mute",
      Style = "Button",
      Position = {20,masterY+20},
      Size = {40,20},
      ButtonStyle = "Toggle",
      Color = {200,50,50}
    }
    
    layout["Master_L_Fader"] = {
      PrettyName = "Master~L Fader",
      Style = "Fader",
      Position = {30,masterY+45},
      Size = {20,50}
    }
    
    -- Master R
    layout["Master_R_Mute"] = {
      PrettyName = "Master~R Mute",
      Style = "Button",
      Position = {90,masterY+20},
      Size = {40,20},
      ButtonStyle = "Toggle",
      Color = {200,50,50}
    }
    
    layout["Master_R_Fader"] = {
      PrettyName = "Master~R Fader",
      Style = "Fader",
      Position = {100,masterY+45},
      Size = {20,50}
    }
  end
  
  -- Scene recall section
  if includeScenes then
    local sceneY = includeMaster and (startY + rows * (channelHeight + 10) + channelHeight + 40) or (startY + rows * (channelHeight + 10) + 20)
    
    table.insert(graphics,{
      Type = "GroupBox",
      Text = "Scene Recall",
      Fill = {250,250,230},
      StrokeWidth = 1,
      Position = {10,sceneY},
      Size = {200,60}
    })
    
    table.insert(graphics,{
      Type = "Text",
      Text = "Scene:",
      Position = {20,sceneY+25},
      Size = {40,16},
      FontSize = 12
    })
    
    layout["Scene_Number"] = {
      PrettyName = "Scene~Number",
      Style = "Text",
      Position = {65,sceneY+25},
      Size = {60,20}
    }
    
    layout["Scene_Recall"] = {
      PrettyName = "Scene~Recall",
      Style = "Button",
      Position = {135,sceneY+25},
      Size = {60,20},
      Color = {0,100,200}
    }
  end
  
elseif CurrentPage == "Setup" then
  -- Configuration display (read-only info)
  table.insert(graphics,{
    Type = "GroupBox",
    Text = "Connection Settings",
    Fill = {240,240,240},
    StrokeWidth = 1,
    Position = {10,10},
    Size = {300,120}
  })
  
  table.insert(graphics,{
    Type = "Text",
    Text = "IP Address: " .. props["IP Address"].Value,
    Position = {20,35},
    Size = {200,16},
    FontSize = 12
  })
  
  table.insert(graphics,{
    Type = "Text",
    Text = "Port: " .. props["Port"].Value,
    Position = {20,55},
    Size = {200,16},
    FontSize = 12
  })
  
  table.insert(graphics,{
    Type = "Text",
    Text = "Base MIDI Channel: " .. props["Base MIDI Channel"].Value,
    Position = {20,75},
    Size = {200,16},
    FontSize = 12
  })
  
  table.insert(graphics,{
    Type = "Text",
    Text = "Input Channels: " .. props["Input Channels"].Value,
    Position = {20,95},
    Size = {200,16},
    FontSize = 12
  })
end