table.insert(props, {
  Name = "IP Address",
  Type = "string",
  Value = "192.168.1.100"
})

table.insert(props, {
  Name = "Port",
  Type = "integer",
  Min = 1,
  Max = 65535,
  Value = 51325
})

table.insert(props, {
  Name = "Base MIDI Channel",
  Type = "integer",
  Min = 1,
  Max = 12,
  Value = 12
})

table.insert(props, {
  Name = "Input Channels",
  Type = "integer",
  Min = 1,
  Max = 64,
  Value = 32
})

table.insert(props, {
  Name = "Include Master",
  Type = "boolean",
  Value = true
})

table.insert(props, {
  Name = "Include Scene Recall",
  Type = "boolean",
  Value = true
})

table.insert(props, {
  Name = "Debug Print",
  Type = "enum",
  Choices = {"None", "Tx/Rx", "Tx", "Rx", "Function Calls", "All"},
  Value = "None"
})