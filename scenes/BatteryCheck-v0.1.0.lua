-- Version 0.1.0 --------------------------------------------
-- Author: Kamil Foltyński ----------------------------------
-- Setup mandatory parameters -------------------------------

local userID = {2} -- email to user
local threshold = 20 -- in %

-------------------------------------------------------------

function getLowBatteryDevices(threshold)

    local devices = hub.getDevicesID(
        {
            interface = "battery",
            enabled = true,
            visible = true
        }
    )
    local emailMsg = 'Devices with low battery:\n\n'

    if devices and type(devices) == "table" then
        for i, deviceId in ipairs(devices) do

            local device = api.get("/devices/" .. tostring(deviceId))
            if tonumber(device.properties.batteryLevel) <= tonumber(threshold) then

                emailMsg = emailMsg .. string.format(
                    "%s%%, ID: %s, %s, %s;\n",
                    device.properties.batteryLevel, device.id, device.name, fibaro.getRoomNameByDeviceID(deviceId)
                )
            end
        end
        return emailMsg
    else
        fibaro.debug("No devices found.")
    end
end

local out = getLowBatteryDevices(threshold)

if out then
    print(out)
    --hub.alert('email', userID, out, false, '')
    fibaro.call(userID, "sendEmail", "Fibaro: low battery!", out)
end
