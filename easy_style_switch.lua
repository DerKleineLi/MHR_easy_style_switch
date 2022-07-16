log.info("[easy_style_switch.lua] loaded")

local HwKeys = require("easy_style_switch.HwKeys");

-- load config
local cfg = json.load_file("easy_style_switch_settings.json")

cfg = cfg or {}
cfg.enabled = cfg.enabled or true
cfg.disable_move_switch = cfg.disable_move_switch or true
cfg.keyboard_btn = cfg.keyboard_btn or 0
cfg.keyboard_red = cfg.keyboard_red or 0
cfg.keyboard_blue = cfg.keyboard_blue or 0
cfg.gamepad_btn = cfg.gamepad_btn or 0
cfg.gamepad_red = cfg.gamepad_red or 0
cfg.gamepad_blue = cfg.gamepad_blue or 0

cfg.keyboard_btn = math.floor(cfg.keyboard_btn)
cfg.keyboard_red = math.floor(cfg.keyboard_red)
cfg.keyboard_blue = math.floor(cfg.keyboard_blue)
cfg.gamepad_btn = math.floor(cfg.gamepad_btn)
cfg.gamepad_red = math.floor(cfg.gamepad_red)
cfg.gamepad_blue = math.floor(cfg.gamepad_blue)

re.on_config_save(
    function()
        json.dump_file("easy_style_switch_settings.json", cfg)
    end
)

-- local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
-- local gui_manager = sdk.get_managed_singleton("snow.gui.GuiManager");

local PlayerReplaceAtkMysetHolder = sdk.find_type_definition("snow.player.PlayerReplaceAtkMysetHolder");
local changeReplaceAtkMyset = PlayerReplaceAtkMysetHolder:get_method("changeReplaceAtkMyset")

sdk.hook(changeReplaceAtkMyset,function(args)
    if cfg.disable_move_switch and cfg.enabled then
        return sdk.PreHookResult.SKIP_ORIGINAL
    else
        return sdk.PreHookResult.CALL_ORIGINAL
    end
end,function(retval) return retval; end)

local function switch_Myset(set_id)
    local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
    local gui_manager = sdk.get_managed_singleton("snow.gui.GuiManager");
    local master_player = player_manager:call("findMasterPlayer");
    if not master_player then return end
    local player_replace_atk_myset_holder = master_player:get_field("_ReplaceAtkMysetHolder");

    if not set_id then
        local current_set_id = player_replace_atk_myset_holder:call("getSelectedIndex");
        if current_set_id == 0 then
            set_id = 1
        else
            set_id = 0
        end
    end
    -- switch Myset
    player_replace_atk_myset_holder:call("setSelectedMysetIndex", set_id);
    master_player:set_field("_replaceAttackTypeA", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",0))
    master_player:set_field("_replaceAttackTypeB", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",1))
    master_player:set_field("_replaceAttackTypeC", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",2))
    master_player:set_field("_replaceAttackTypeD", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",3))
    master_player:set_field("_replaceAttackTypeE", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",4))
    master_player:set_field("_replaceAttackTypeF", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",5))

    -- update hud
    local guiHud_weaponTechniqueMyset = gui_manager:call("get_refGuiHud_WeaponTechniqueMySet");
    guiHud_weaponTechniqueMyset:write_dword(0x118, set_id);
end

re.on_frame(function()
    if cfg.enabled and HwKeys.setup() then
        -- Listening for Anim skip key press
        if (cfg.gamepad_btn > 0 and HwKeys.hwPad:call("andTrg", cfg.gamepad_btn)) or HwKeys.hwKB:call("getTrg", cfg.keyboard_btn) then
            switch_Myset()
        elseif (cfg.gamepad_red > 0 and HwKeys.hwPad:call("andTrg", cfg.gamepad_red)) or HwKeys.hwKB:call("getTrg", cfg.keyboard_red) then
            switch_Myset(0)
        elseif (cfg.gamepad_blue > 0 and HwKeys.hwPad:call("andTrg", cfg.gamepad_blue)) or HwKeys.hwKB:call("getTrg", cfg.keyboard_blue) then
            switch_Myset(1)
        end
    end
end)

local setting_key_flag = 0;

local function get_key_setting()
    local case = {
        [1] = function() 
            cfg.keyboard_btn = 0
            key = HwKeys.get_keyboard()
            if key > 0 then
                cfg.keyboard_btn = key
                setting_key_flag = 0
            end
        end, 
        [2] = function() 
            cfg.keyboard_red = 0
            key = HwKeys.get_keyboard()
            if key > 0 then
                cfg.keyboard_red = key
                setting_key_flag = 0
            end
        end, 
        [3] = function() 
            cfg.keyboard_blue = 0
            key = HwKeys.get_keyboard()
            if key > 0 then
                cfg.keyboard_blue = key
                setting_key_flag = 0
            end
        end, 
        [4] = function() 
            cfg.gamepad_btn = 0
            key = HwKeys.get_gamepad()
            if key > 0 then 
                cfg.gamepad_btn = key
                setting_key_flag = 0
            end 
        end, 
        [5] = function() 
            cfg.gamepad_red = 0
            key = HwKeys.get_gamepad()
            if key > 0 then 
                cfg.gamepad_red = key
                setting_key_flag = 0
            end 
        end, 
        [6] = function() 
            cfg.gamepad_blue = 0
            key = HwKeys.get_gamepad()
            if key > 0 then 
                cfg.gamepad_blue = key
                setting_key_flag = 0
            end 
        end, 
    }
    if case[setting_key_flag] then
        case[setting_key_flag]()
    end
end

re.on_draw_ui(
    function() 
        if not imgui.tree_node("Easy style switch") then return end

        get_key_setting()

        local changed, value = imgui.checkbox("Enabled", cfg.enabled)
        if changed then cfg.enabled = value end

        local changed, value = imgui.checkbox("Disable move switch", cfg.disable_move_switch)
        if changed then cfg.disable_move_switch = value end

        if imgui.button("Keyboard switch: " .. HwKeys.KeyboardKeys[cfg.keyboard_btn]) then
            setting_key_flag = 1
        end

        if imgui.button("Keyboard red: " .. HwKeys.KeyboardKeys[cfg.keyboard_red]) then
            setting_key_flag = 2
        end

        if imgui.button("Keyboard blue: " .. HwKeys.KeyboardKeys[cfg.keyboard_blue]) then
            setting_key_flag = 3
        end
        
        if imgui.button("Gamepad switch: " .. HwKeys.pad_btncode_to_label(cfg.gamepad_btn)) then
            setting_key_flag = 4
        end

        if imgui.button("Gamepad red: " .. HwKeys.pad_btncode_to_label(cfg.gamepad_red)) then
            setting_key_flag = 5
        end

        if imgui.button("Gamepad blue: " .. HwKeys.pad_btncode_to_label(cfg.gamepad_blue)) then
            setting_key_flag = 6
        end

        imgui.tree_pop()
    end
)