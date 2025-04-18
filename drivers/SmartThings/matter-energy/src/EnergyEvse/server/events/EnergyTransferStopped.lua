local data_types = require "st.matter.data_types"
local cluster_base = require "st.matter.cluster_base"
local TLVParser = require "st.matter.TLV.TLVParser"
local StructureABC = require "st.matter.data_types.base_defs.StructureABC"
local StateEnum = require "EnergyEvsetypes.StateEnum"
local EnergyTransferStoppedReasonEnum = require "EnergyEvsetypes.EnergyTransferStoppedReasonEnum"

local EnergyTransferStopped = {
  ID = 0x0003,
  NAME = "EnergyTransferStopped",
  base_type = data_types.Structure,
}

EnergyTransferStopped.field_defs = {
  {
    data_type = data_types.Uint32,
    field_id = 0,
    is_array = false,
    name = "session_id",
    is_nullable = false,
    is_optional = false,
  },
  {
    data_type = StateEnum,
    field_id = 1,
    is_array = false,
    name = "state",
    is_nullable = false,
    is_optional = false,
  },
  {
    data_type = EnergyTransferStoppedReasonEnum,
    field_id = 2,
    is_array = false,
    name = "reason",
    is_nullable = false,
    is_optional = false,
  },
  {
    data_type = data_types.Int64,
    field_id = 4,
    is_array = false,
    name = "energy_transferred",
    is_nullable = false,
    is_optional = false,
  },
}

function EnergyTransferStopped:augment_type(base_type_obj)
  local elems = {}
  for _, v in ipairs(base_type_obj.elements) do
    for _, field_def in ipairs(self.field_defs) do
      if field_def.field_id == v.field_id and not
        ((field_def.is_nullable or field_def.is_optional) and v.value == nil) then
        elems[field_def.name] = data_types.validate_or_build_type(v, field_def.data_type, field_def.field_name)
        elems[field_def.name].field_name = field_def.name
      end
    end
  end
  base_type_obj.elements = elems
end

function EnergyTransferStopped:read(device, endpoint_id)
  return cluster_base.read(
    device,
    endpoint_id,
    self._cluster.ID,
    nil, --attribute_id
    self.ID
  )
end

function EnergyTransferStopped:subscribe(device, endpoint_id)
  return cluster_base.subscribe(
    device,
    endpoint_id,
    self._cluster.ID,
    nil, --attribute_id
    self.ID
  )
end

function EnergyTransferStopped:build_test_event_report(
  device,
  endpoint_id,
  fields,
  status
)
  local data = {}
  data.elements = {}
  data.num_elements = 0
  setmetatable(data, StructureABC.new_mt({NAME = "EnergyTransferStoppedEventData", ID = 0x15}))
  for idx, field_def in ipairs(self.field_defs) do --Note: idx is 1 when field_id is 0
    if (not field_def.is_optional or not field_def.is_nullable) and not fields[field_def.name] then
      error("Missing non optional or non_nullable field: " .. field_def.name)
    elseif fields[field_def.name] then
      data.elements[field_def.name] = data_types.validate_or_build_type(fields[field_def.name], field_def.data_type, field_def.name)
      data.elements[field_def.name].field_id = field_def.field_id
      data.num_elements = data.num_elements + 1
    end
  end
  return cluster_base.build_test_event_report(
    device,
    endpoint_id,
    self._cluster.ID,
    self.ID,
    data,
    status
  )
end

function EnergyTransferStopped:deserialize(tlv_buf)
  local data = TLVParser.decode_tlv(tlv_buf)
  self:augment_type(data)
  return data
end

function EnergyTransferStopped:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

return EnergyTransferStopped
