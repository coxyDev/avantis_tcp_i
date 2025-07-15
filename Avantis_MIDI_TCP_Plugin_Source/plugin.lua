
-- Avantis MIDI TCP Plugin
-- Controls Mute and Fader for 64 Inputs + Mains L/R via TCP MIDI

-- Plugin-defined controls
tcp = TcpSocket.New()

function sendMidi(bytes)
  if tcp:IsConnected() then
    tcp:Write(string.char(table.unpack(bytes)))
  end
end

function buildMuteMessage(channelIndex, on)
  local base = Controls.BaseMidiChannel.Value
  local ch = channelIndex - 1
  local status = 0x90 + base
  local velocity = on and 0x7F or 0x3F
  return {status, ch, velocity, ch, 0x00}
end

function buildFaderNRPN(channelIndex, level)
  local base = Controls.BaseMidiChannel.Value
  local ch = channelIndex - 1
  local status = 0xB0 + base
  return {
    status, 0x63, ch,
    status, 0x62, 0x11,
    status, 0x06, level
  }
end

MuteControls = {}
FaderControls = {}

function InitControls()
  local n = Controls.InputChannels.Value
  for i = 1, n do
    MuteControls[i] = Controls.CreateToggle("Mute_" .. i, false)
    FaderControls[i] = Controls.CreateFloat("Fader_" .. i, 0.5)
  end
  if Controls.IncludeMaster.Value then
    MuteControls["Master"] = Controls.CreateToggle("Mute_Master", false)
    FaderControls["Master"] = Controls.CreateFloat("Fader_Master", 0.5)
  end
end

InitControls()

function Connect()
  tcp:Connect(Controls.IPAddress.String, Controls.Port.Value)
end

Controls.IPAddress.EventHandler = Connect
Controls.Port.EventHandler = Connect

for i, ctrl in pairs(MuteControls) do
  ctrl.EventHandler = function()
    local msg = buildMuteMessage(i == "Master" and 49 or i, ctrl.Boolean)
    sendMidi(msg)
  end
end

for i, ctrl in pairs(FaderControls) do
  ctrl.EventHandler = function()
    local level = math.floor(ctrl.Value * 127)
    local msg = buildFaderNRPN(i == "Master" and 49 or i, level)
    sendMidi(msg)
  end
end

tcp.Data = function(sock, data)
  -- Feedback parsing stub
end

Connect()
