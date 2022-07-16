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
cfg.keyboard_third = cfg.keyboard_third or 0
cfg.gamepad_btn = cfg.gamepad_btn or 0
cfg.gamepad_red = cfg.gamepad_red or 0
cfg.gamepad_blue = cfg.gamepad_blue or 0
cfg.gamepad_third = cfg.gamepad_third or 0
cfg.switch_skill_1 = cfg.switch_skill_1 or 0
cfg.switch_skill_2 = cfg.switch_skill_2 or 0
cfg.switch_skill_3 = cfg.switch_skill_3 or 0
cfg.switch_skill_4 = cfg.switch_skill_4 or 0
cfg.switch_skill_5 = cfg.switch_skill_5 or 0

cfg.keyboard_btn = math.floor(cfg.keyboard_btn)
cfg.keyboard_red = math.floor(cfg.keyboard_red)
cfg.keyboard_blue = math.floor(cfg.keyboard_blue)
cfg.keyboard_third = math.floor(cfg.keyboard_third)
cfg.gamepad_btn = math.floor(cfg.gamepad_btn)
cfg.gamepad_red = math.floor(cfg.gamepad_red)
cfg.gamepad_blue = math.floor(cfg.gamepad_blue)
cfg.gamepad_third = math.floor(cfg.gamepad_third)
cfg.switch_skill_1 = math.floor(cfg.switch_skill_1)
cfg.switch_skill_2 = math.floor(cfg.switch_skill_2)
cfg.switch_skill_3 = math.floor(cfg.switch_skill_3)
cfg.switch_skill_4 = math.floor(cfg.switch_skill_4)
cfg.switch_skill_5 = math.floor(cfg.switch_skill_5)

re.on_config_save(
    function()
        json.dump_file("easy_style_switch_settings.json", cfg)
    end
)

-- disable move switch
local PlayerReplaceAtkMysetHolder = sdk.find_type_definition("snow.player.PlayerReplaceAtkMysetHolder");
local changeReplaceAtkMyset = PlayerReplaceAtkMysetHolder:get_method("changeReplaceAtkMyset")
local PlayerBase = sdk.find_type_definition("snow.player.PlayerBase");
local reflectReplaceAtkMyset = PlayerBase:get_method("reflectReplaceAtkMyset");

sdk.hook(changeReplaceAtkMyset,function(args)
    if cfg.disable_move_switch and cfg.enabled then
        return sdk.PreHookResult.SKIP_ORIGINAL
    else
        return sdk.PreHookResult.CALL_ORIGINAL
    end
end,function(retval) return retval; end)

sdk.hook(reflectReplaceAtkMyset,function(args)
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
    -- log.debug(master_player:get_address())
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

    if set_id <= 1 then
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
    elseif set_id == 2 then
        -- switch to third style
        master_player:set_field("_replaceAttackTypeA", cfg.switch_skill_1)
        master_player:set_field("_replaceAttackTypeB", cfg.switch_skill_2)
        master_player:set_field("_replaceAttackTypeD", cfg.switch_skill_3)
        master_player:set_field("_replaceAttackTypeF", cfg.switch_skill_5)
        if cfg.switch_skill_4 <= 1 then
            master_player:set_field("_replaceAttackTypeC", cfg.switch_skill_4)
            master_player:set_field("_replaceAttackTypeE", 0)
        elseif cfg.switch_skill_4 == 2 then
            master_player:set_field("_replaceAttackTypeC", 0)
            master_player:set_field("_replaceAttackTypeE", 1)
        end
    end
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
        elseif (cfg.gamepad_third > 0 and HwKeys.hwPad:call("andTrg", cfg.gamepad_third)) or HwKeys.hwKB:call("getTrg", cfg.keyboard_third) then
            switch_Myset(2)
        end
    end
end)

-- Key setting
local setting_key_flag = 0;

local case_key_setting = {
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
        cfg.keyboard_third = 0
        key = HwKeys.get_keyboard()
        if key > 0 then
            cfg.keyboard_third = key
            setting_key_flag = 0
        end
    end, 
    [5] = function() 
        cfg.gamepad_btn = 0
        key = HwKeys.get_gamepad()
        if key > 0 then 
            cfg.gamepad_btn = key
            setting_key_flag = 0
        end 
    end, 
    [6] = function() 
        cfg.gamepad_red = 0
        key = HwKeys.get_gamepad()
        if key > 0 then 
            cfg.gamepad_red = key
            setting_key_flag = 0
        end 
    end, 
    [7] = function() 
        cfg.gamepad_blue = 0
        key = HwKeys.get_gamepad()
        if key > 0 then 
            cfg.gamepad_blue = key
            setting_key_flag = 0
        end 
    end, 
    [8] = function() 
        cfg.gamepad_third = 0
        key = HwKeys.get_gamepad()
        if key > 0 then 
            cfg.gamepad_third = key
            setting_key_flag = 0
        end 
    end, 
}

local function get_key_setting()
    if case_key_setting[setting_key_flag] then
        case_key_setting[setting_key_flag]()
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

        if imgui.tree_node("Key bindings") then

            if imgui.button("Keyboard switch: " .. HwKeys.KeyboardKeys[cfg.keyboard_btn]) then
                setting_key_flag = 1
            end

            if imgui.button("Keyboard red: " .. HwKeys.KeyboardKeys[cfg.keyboard_red]) then
                setting_key_flag = 2
            end

            if imgui.button("Keyboard blue: " .. HwKeys.KeyboardKeys[cfg.keyboard_blue]) then
                setting_key_flag = 3
            end

            if imgui.button("Keyboard third: " .. HwKeys.KeyboardKeys[cfg.keyboard_third]) then
                setting_key_flag = 4
            end
            
            if imgui.button("Gamepad switch: " .. HwKeys.pad_btncode_to_label(cfg.gamepad_btn)) then
                setting_key_flag = 5
            end

            if imgui.button("Gamepad red: " .. HwKeys.pad_btncode_to_label(cfg.gamepad_red)) then
                setting_key_flag = 6
            end

            if imgui.button("Gamepad blue: " .. HwKeys.pad_btncode_to_label(cfg.gamepad_blue)) then
                setting_key_flag = 7
            end

            if imgui.button("Gamepad third: " .. HwKeys.pad_btncode_to_label(cfg.gamepad_third)) then
                setting_key_flag = 8
            end

            imgui.tree_pop()
        
        else setting_key_flag = 0 end

        if imgui.tree_node("Third style") then
            changed, value = imgui.slider_int("Switch skill 1", cfg.switch_skill_1, 0, 1)
            if changed then cfg.switch_skill_1 = value end

            changed, value = imgui.slider_int("Switch skill 2", cfg.switch_skill_2, 0, 1)
            if changed then cfg.switch_skill_2 = value end

            changed, value = imgui.slider_int("Switch skill 3", cfg.switch_skill_3, 0, 1)
            if changed then cfg.switch_skill_3 = value end

            changed, value = imgui.slider_int("Switch skill 4", cfg.switch_skill_4, 0, 2)
            if changed then cfg.switch_skill_4 = value end

            changed, value = imgui.slider_int("Switch skill 5", cfg.switch_skill_5, 0, 1)
            if changed then cfg.switch_skill_5 = value end

            imgui.tree_pop()
        end

        imgui.tree_pop()
    end
)