-- TCP socket for Avantis communication
local tcp = TcpSocket.New()
local isConnected = false

-- MIDI Protocol Helper Functions

-- Convert dB to MIDI value (0x00 to 0x7F) according to Avantis protocol
function dbToMidiValue(db)
  -- Avantis range: -inf to +10dB mapped to 0x00 to 0x7F
  if db <= -60 then
    return 0x00  -- -inf
  elseif db >= 10 then
    return 0x7F  -- +10dB
  else
    -- Linear mapping from -60dB to +10dB -> 0x01 to 0x7F
    local normalizedDb = (db + 60) / 70  -- Normalize to 0-1 range
    return math.floor(normalizedDb * 126) + 1  -- Map to 0x01-0x7F
  end
end

-- Send MIDI bytes over TCP
function sendMidi(bytes)
  if tcp.IsConnected then
    local data = ""
    for i, byte in ipairs(bytes) do
      data = data .. string.char(byte)
    end
    tcp:Write(data)
    
    local debugPrint = Properties["Debug Print"].Value
    if debugPrint == "Tx" or debugPrint == "Tx/Rx" or debugPrint == "All" then
      local hexStr = ""
      for i, byte in ipairs(bytes) do
        hexStr = hexStr .. string.format("%02X ", byte)
      end
      print("TX: " .. hexStr)
    end
  end
end

-- Build mute message according to Avantis protocol
function buildMuteMessage(channelType, channelIndex, muteOn)
  local baseMidiChannel = Properties["Base MIDI Channel"].Value - 1  -- Convert to 0-based
  local midiChannel, noteNumber
  
  if channelType == "input" then
    midiChannel = baseMidiChannel
    noteNumber = channelIndex - 1  -- Convert to 0-based (CH = 00 to 3F for inputs 1-64)
  elseif channelType == "main" then
    midiChannel = baseMidiChannel + 4
    if channelIndex == 1 then
      noteNumber = 0x30  -- Main 1 (L)
    elseif channelIndex == 2 then
      noteNumber = 0x31  -- Main 2 (R)
    end
  end
  
  local status = 0x90 + midiChannel
  local velocity = muteOn and 0x7F or 0x3F
  
  -- Avantis mute protocol: NOTE ON with velocity followed by NOTE OFF
  return {status, noteNumber, velocity, status, noteNumber, 0x00}
end

-- Build fader NRPN message according to Avantis protocol
function buildFaderMessage(channelType, channelIndex, level)
  local baseMidiChannel = Properties["Base MIDI Channel"].Value - 1  -- Convert to 0-based
  local midiChannel, noteNumber
  
  if channelType == "input" then
    midiChannel = baseMidiChannel
    noteNumber = channelIndex - 1  -- Convert to 0-based
  elseif channelType == "main" then
    midiChannel = baseMidiChannel + 4
    if channelIndex == 1 then
      noteNumber = 0x30  -- Main 1 (L)
    elseif channelIndex == 2 then
      noteNumber = 0x31  -- Main 2 (R)
    end
  end
  
  local status = 0xB0 + midiChannel
  
  -- NRPN message for fader level (parameter ID 0x17)
  return {
    status, 0x63, noteNumber,    -- Select channel (MSB)
    status, 0x62, 0x17,          -- Parameter ID 0x17 (fader level)
    status, 0x06, level          -- Set value
  }
end

-- Build scene recall message
function buildSceneRecallMessage(sceneNumber)
  local baseMidiChannel = Properties["Base MIDI Channel"].Value - 1
  local status = 0xB0 + baseMidiChannel
  local programStatus = 0xC0 + baseMidiChannel
  
  -- Determine bank and scene within bank
  local bank = 0
  local sceneInBank = sceneNumber - 1
  
  if sceneNumber > 384 then
    bank = 3
    sceneInBank = sceneNumber - 385
  elseif sceneNumber > 256 then
    bank = 2
    sceneInBank = sceneNumber - 257
  elseif sceneNumber > 128 then
    bank = 1
    sceneInBank = sceneNumber - 129
  end
  
  -- Bank select + Program change
  return {
    status, 0x00, bank,           -- Bank select
    programStatus, sceneInBank    -- Program change
  }
end

-- Connection management
function connectToAvantis()
  local debugPrint = Properties["Debug Print"].Value
  if debugPrint == "Function Calls" or debugPrint == "All" then
    print("Connecting to Avantis at " .. Properties["IP Address"].Value .. ":" .. Properties["Port"].Value)
  end
  
  tcp:Connect(Properties["IP Address"].Value, Properties["Port"].Value)
end

function disconnectFromAvantis()
  local debugPrint = Properties["Debug Print"].Value
  if debugPrint == "Function Calls" or debugPrint == "All" then
    print("Disconnecting from Avantis")
  end
  
  tcp:Disconnect()
end

-- TCP Event handlers
tcp.Connected = function(sock)
  isConnected = true
  Controls.Connected.Boolean = true
  Controls.Connect.Boolean = true
  
  local debugPrint = Properties["Debug Print"].Value
  if debugPrint ~= "None" then
    print("Connected to Avantis console")
  end
end

tcp.Disconnected = function(sock)
  isConnected = false
  Controls.Connected.Boolean = false
  Controls.Connect.Boolean = false
  
  local debugPrint = Properties["Debug Print"].Value
  if debugPrint ~= "None" then
    print("Disconnected from Avantis console")
  end
end

tcp.Error = function(sock, err)
  isConnected = false
  Controls.Connected.Boolean = false
  Controls.Connect.Boolean = false
  
  local debugPrint = Properties["Debug Print"].Value
  if debugPrint ~= "None" then
    print("TCP Error: " .. err)
  end
end

tcp.Data = function(sock, data)
  -- Handle incoming MIDI data (feedback from console)
  local debugPrint = Properties["Debug Print"].Value
  if debugPrint == "Rx" or debugPrint == "Tx/Rx" or debugPrint == "All" then
    local hexStr = ""
    for i = 1, #data do
      hexStr = hexStr .. string.format("%02X ", string.byte(data, i))
    end
    print("RX: " .. hexStr)
  end
end

-- Control event handlers
Controls.Connect.EventHandler = function()
  if Controls.Connect.Boolean then
    connectToAvantis()
  else
    disconnectFromAvantis()
  end
end

-- Input channel mute handlers
for i = 1, Properties["Input Channels"].Value do
  if Controls["Input_" .. i .. "_Mute"] then
    Controls["Input_" .. i .. "_Mute"].EventHandler = function()
      local muteMsg = buildMuteMessage("input", i, Controls["Input_" .. i .. "_Mute"].Boolean)
      sendMidi(muteMsg)
    end
  end
end

-- Input channel fader handlers
for i = 1, Properties["Input Channels"].Value do
  if Controls["Input_" .. i .. "_Fader"] then
    Controls["Input_" .. i .. "_Fader"].EventHandler = function()
      local level = dbToMidiValue(Controls["Input_" .. i .. "_Fader"].Value)
      local faderMsg = buildFaderMessage("input", i, level)
      sendMidi(faderMsg)
    end
  end
end

-- Master channel handlers
if Properties["Include Master"].Value then
  if Controls.Master_L_Mute then
    Controls.Master_L_Mute.EventHandler = function()
      local muteMsg = buildMuteMessage("main", 1, Controls.Master_L_Mute.Boolean)
      sendMidi(muteMsg)
    end
  end
  
  if Controls.Master_L_Fader then
    Controls.Master_L_Fader.EventHandler = function()
      local level = dbToMidiValue(Controls.Master_L_Fader.Value)
      local faderMsg = buildFaderMessage("main", 1, level)
      sendMidi(faderMsg)
    end
  end
  
  if Controls.Master_R_Mute then
    Controls.Master_R_Mute.EventHandler = function()
      local muteMsg = buildMuteMessage("main", 2, Controls.Master_R_Mute.Boolean)
      sendMidi(muteMsg)
    end
  end
  
  if Controls.Master_R_Fader then
    Controls.Master_R_Fader.EventHandler = function()
      local level = dbToMidiValue(Controls.Master_R_Fader.Value)
      local faderMsg = buildFaderMessage("main", 2, level)
      sendMidi(faderMsg)
    end
  end
end

-- Scene recall handler
if Properties["Include Scene Recall"].Value then
  if Controls.Scene_Recall then
    Controls.Scene_Recall.EventHandler = function()
      local sceneNumber = tonumber(Controls.Scene_Number.String)
      if sceneNumber and sceneNumber >= 1 and sceneNumber <= 500 then
        local sceneMsg = buildSceneRecallMessage(sceneNumber)
        sendMidi(sceneMsg)
        
        local debugPrint = Properties["Debug Print"].Value
        if debugPrint == "Function Calls" or debugPrint == "All" then
          print("Recalling scene " .. sceneNumber)
        end
      else
        local debugPrint = Properties["Debug Print"].Value
        if debugPrint ~= "None" then
          print("Invalid scene number: " .. (Controls.Scene_Number.String or "nil"))
        end
      end
    end
  end
end

-- Initialize connection state
Controls.Connected.Boolean = false
Controls.Connect.Boolean = false