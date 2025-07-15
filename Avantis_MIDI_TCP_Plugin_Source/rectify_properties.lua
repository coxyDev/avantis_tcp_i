-- Validate Base MIDI Channel doesn't exceed maximum
if props["Base MIDI Channel"].Value > 12 then
  props["Base MIDI Channel"].Value = 12
elseif props["Base MIDI Channel"].Value < 1 then
  props["Base MIDI Channel"].Value = 1
end

-- Validate Input Channels
if props["Input Channels"].Value > 64 then
  props["Input Channels"].Value = 64
elseif props["Input Channels"].Value < 1 then
  props["Input Channels"].Value = 1
end