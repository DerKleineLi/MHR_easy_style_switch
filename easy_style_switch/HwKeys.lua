local HwKeys = {}

-- loading keycode dicts separate from main logic
local PadKeys = require("easy_style_switch.PadKeys");
local PlaystationKeys = require("easy_style_switch.PlaystationKeys");
local XboxKeys = require("easy_style_switch.XboxKeys");
local NintendoKeys = require("easy_style_switch.NintendoKeys");
local KeyboardKeys = require("easy_style_switch.KeyboardKeys");

HwKeys.hwKB = nil
HwKeys.hwPad = nil
HwKeys.padType = 0
HwKeys.padKeyLUT = XboxKeys
HwKeys.KeyboardKeys = KeyboardKeys
-- Button code to label decoder
function HwKeys.pad_btncode_to_label(keycode)
    label = ""

    if not keycode then
        return "None"
    end

    for k, v in pairs(PadKeys) do
        if keycode & k > 0 and HwKeys.padKeyLUT[PadKeys[k]] ~= nil then
            label = label .. HwKeys.padKeyLUT[PadKeys[k]] .. "+"
        end
    end

    if #label > 0 then
        return label:sub(0, -2)
    end
    return "None"
end

function HwKeys.get_keyboard()
    for k, v in pairs(KeyboardKeys) do  -- VERY DIRTY BUT get_trg doesn't work?
        if HwKeys.hwKB:call("getDown", k) then
            return k
        end
    end
    return 0
end

-- Internal Timer Functions
local get_delta_time = sdk.find_type_definition("via.Application"):get_method("get_FrameTimeMillisecond")
local timer = 0
local timerLen = 200 -- timer length in millisecs

local function timer_reset()
    timer = 0
end

local function timer_tick()
    -- timer tick function, returns true if timerLen has been reached
    timer = timer + get_delta_time:call(nil)
    if timer >= timerLen then
        timer_reset()
        return true
    end
    return false
end

local padBtnPrev = 0
function HwKeys.get_gamepad()
    local padBtnPressed = HwKeys.hwPad:call("get_on") -- get held buttons
    if padBtnPressed > 0 then -- if they press anything
        if padBtnPressed == padBtnPrev then -- is it a new combination?
            if timer_tick() then -- start timer, wait for it to finish
                padBtnPrev = 0
                return padBtnPressed -- timer ran out, update settings
            end
        else -- not a new combo
            padBtnPrev = padBtnPressed -- save this combo for a bit
            timer_reset()
        end
    end
    return 0
end

function HwKeys.setup()
    -- grabbing the keyboard manager    
    if not HwKeys.hwKB then
        HwKeys.hwKB = sdk.get_managed_singleton("snow.GameKeyboard"):get_field("hardKeyboard") -- getting hardware keyboard manager
    end
    -- grabbing the gamepad manager
    if not HwKeys.hwPad then
        HwKeys.hwPad = sdk.get_managed_singleton("snow.Pad"):get_field("hard") -- getting hardware keyboard manager
        if HwKeys.hwPad then
            HwKeys.padType = HwKeys.hwPad:call("get_DeviceKindDetails")
            if HwKeys.padType ~= nil then
                if HwKeys.padType < 10 then
                    padKeyLUT = XboxKeys
                elseif HwKeys.padType > 15 then
                    HwKeys.padKeyLUT = NintendoKeys
                else
                    HwKeys.padKeyLUT = PlaystationKeys
                end
            else
                HwKeys.padKeyLUT = XboxKeys -- defaulting to Xbox Keys
            end
        end
    end

end

return HwKeys