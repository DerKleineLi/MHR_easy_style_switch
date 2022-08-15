log.info("[easy_style_switch.lua] loaded")

-- ##########################################
-- load modules
-- ##########################################
local HwKeys = require("easy_style_switch.HwKeys");

-- ##########################################
-- script config
-- ##########################################
local cfg = json.load_file("easy_style_switch_settings.json")

cfg = cfg or {}
cfg.enabled = cfg.enabled or true
cfg.disable_move_switch = cfg.disable_move_switch or true
cfg.separate_buff_and_action_set = cfg.separate_buff_and_action_set or true
cfg.keyboard_btn = cfg.keyboard_btn or 0
cfg.keyboard_red = cfg.keyboard_red or 0
cfg.keyboard_blue = cfg.keyboard_blue or 0
cfg.keyboard_third = cfg.keyboard_third or 0
cfg.gamepad_btn = cfg.gamepad_btn or 0
cfg.gamepad_red = cfg.gamepad_red or 0
cfg.gamepad_blue = cfg.gamepad_blue or 0
cfg.gamepad_third = cfg.gamepad_third or 0
cfg.switch_action_0 = cfg.switch_action_0 or 0
cfg.switch_action_1 = cfg.switch_action_1 or 0
cfg.switch_action_2 = cfg.switch_action_2 or 0
cfg.switch_action_3 = cfg.switch_action_3 or 0
cfg.switch_action_4 = cfg.switch_action_4 or 0

cfg.keyboard_btn = math.floor(cfg.keyboard_btn)
cfg.keyboard_red = math.floor(cfg.keyboard_red)
cfg.keyboard_blue = math.floor(cfg.keyboard_blue)
cfg.keyboard_third = math.floor(cfg.keyboard_third)
cfg.gamepad_btn = math.floor(cfg.gamepad_btn)
cfg.gamepad_red = math.floor(cfg.gamepad_red)
cfg.gamepad_blue = math.floor(cfg.gamepad_blue)
cfg.gamepad_third = math.floor(cfg.gamepad_third)
cfg.switch_action_0 = math.floor(cfg.switch_action_0)
cfg.switch_action_1 = math.floor(cfg.switch_action_1)
cfg.switch_action_2 = math.floor(cfg.switch_action_2)
cfg.switch_action_3 = math.floor(cfg.switch_action_3)
cfg.switch_action_4 = math.floor(cfg.switch_action_4)

re.on_config_save(
    function()
        json.dump_file("easy_style_switch_settings.json", cfg)
    end
)

-- ##########################################
-- disable move switch
-- ##########################################
local PlayerReplaceAtkMysetHolder = sdk.find_type_definition("snow.player.PlayerReplaceAtkMysetHolder");
local changeReplaceAtkMyset = PlayerReplaceAtkMysetHolder:get_method("changeReplaceAtkMyset")
sdk.hook(changeReplaceAtkMyset,function(args)
    if cfg.disable_move_switch and cfg.enabled then
        return sdk.PreHookResult.SKIP_ORIGINAL
    else
        return sdk.PreHookResult.CALL_ORIGINAL
    end
end,function(retval) return retval; end)

local PlayerBase = sdk.find_type_definition("snow.player.PlayerBase");
local reflectReplaceAtkMyset = PlayerBase:get_method("reflectReplaceAtkMyset");
sdk.hook(reflectReplaceAtkMyset,function(args)
    if cfg.disable_move_switch and cfg.enabled then
        return sdk.PreHookResult.SKIP_ORIGINAL
    else
        return sdk.PreHookResult.CALL_ORIGINAL
    end
end,function(retval) return retval; end)

-- ##########################################
-- HUD hook
-- ##########################################

-- get the default action id
local SwitchActionSystem = sdk.find_type_definition("snow.data.SwitchActionSystem");
local getEquippedActionMySetDataList = SwitchActionSystem:get_method("getEquippedActionMySetDataList(snow.data.weapon.WeaponTypes, snow.data.SwitchActionEquipType)");
local getEquippedActionMySetDataList_args = nil;

local current_weapon = nil;
local base_0 = nil;
local base_1 = nil;
local base_2 = nil;
local base_3 = nil;
local base_4 = nil;

sdk.hook(getEquippedActionMySetDataList,function(args) 
    if cfg.enabled then
        getEquippedActionMySetDataList_args = args;
    end
    return sdk.PreHookResult.CALL_ORIGINAL;
end,function(retval) 
    if cfg.enabled and current_weapon ~= sdk.to_int64(getEquippedActionMySetDataList_args[3]) then
        local mretval = sdk.to_managed_object(retval)
        local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
        local master_player = player_manager:call("findMasterPlayer");
        if not master_player then return retval end
        local player_replace_atk_myset_holder = master_player:get_field("_ReplaceAtkMysetHolder");
        player_replace_atk_myset_holder:call("setSelectedMysetIndex", current_gui_set_id);
        base_0 = mretval[0] - player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",0);
        base_1 = base_0 + 2;
        base_2 = mretval[2] - player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",3);
        base_3 = base_1 + 2;
        base_4 = base_2 + 3;
        player_replace_atk_myset_holder:call("setSelectedMysetIndex", current_set_id);
        current_weapon = sdk.to_int64(getEquippedActionMySetDataList_args[3]);
    end
    return retval
end)

-- helper functions
local function get_corrsponding_action_id_in_third_scroll(action_id)
    if not base_0 then return nil end
    local id_in_third_scroll = nil;
    if action_id>= base_0 and action_id<base_1 then
        -- switch action 0
        id_in_third_scroll = base_0 + cfg.switch_action_0;
    elseif action_id>= base_1 and action_id<base_3 then
        -- switch action 1
        id_in_third_scroll = base_1 + cfg.switch_action_1;
    elseif action_id>=base_2 and action_id < base_2+2 then
        -- switch action 2
        id_in_third_scroll = base_2 + cfg.switch_action_2;
    elseif (action_id>=base_3 and action_id<base_3+2) or action_id == base_2+2 then
        -- switch action 3
        if cfg.switch_action_3 <= 1 then
            id_in_third_scroll = base_3 + cfg.switch_action_3;
        elseif cfg.switch_action_3 == 2 then
            id_in_third_scroll = base_2 + 2;
        end
    elseif action_id>=base_4 and action_id < base_4+2 then
        -- switch action 4
        id_in_third_scroll = base_4 + cfg.switch_action_4;
    end
    return id_in_third_scroll;
end

local function is_weapon_drawn()
    local weapon_drawn = nil;
    local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
    local master_player = player_manager:call("findMasterPlayer");
    if not master_player then return nil end;
    weapon_drawn = master_player:call("isWeaponOn");
    return weapon_drawn;
end

-- show action name in third scroll
local DataShortcut = sdk.find_type_definition("snow.data.DataShortcut");
local getCommandHud = DataShortcut:get_method("getCommandHud(snow.data.DataDef.PlWeaponActionId)");
local getName = DataShortcut:get_method("getName(snow.data.DataDef.PlWeaponActionId)");

sdk.hook(getName,function(args)
    if cfg.enabled and script_myset_id == 2 and is_weapon_drawn() then
        local id_in_third_scroll = get_corrsponding_action_id_in_third_scroll(sdk.to_int64(args[2]));
        args[2] = sdk.to_ptr(id_in_third_scroll);
    end
    return sdk.PreHookResult.CALL_ORIGINAL
end, function(retval) return retval; end)

sdk.hook(getCommandHud,function(args)
    if cfg.enabled and script_myset_id == 2 and is_weapon_drawn() then
        local id_in_third_scroll = get_corrsponding_action_id_in_third_scroll(sdk.to_int64(args[2]));
        args[2] = sdk.to_ptr(id_in_third_scroll);
    end
    return sdk.PreHookResult.CALL_ORIGINAL
end, function(retval) return retval; end)

-- ##########################################
-- switch function
-- ##########################################
local function switch_Myset(set_id)
    local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
    local gui_manager = sdk.get_managed_singleton("snow.gui.GuiManager");
    local master_player = player_manager:call("findMasterPlayer");
    if not master_player then return end
    local player_replace_atk_myset_holder = master_player:get_field("_ReplaceAtkMysetHolder");
    local current_set_id = player_replace_atk_myset_holder:call("getSelectedIndex");
    local guiHud_weaponTechniqueMyset = gui_manager:call("get_refGuiHud_WeaponTechniqueMySet");
    local current_gui_set_id = guiHud_weaponTechniqueMyset:get_field("currentEquippedMySetIndex"):get_field("_Value")

    if not set_id then
        if current_gui_set_id == 0 then
            set_id = 1
        else
            set_id = 0
        end
    end

    if script_myset_id ~= set_id then
        if set_id <= 1 then
            -- switch Myset
            player_replace_atk_myset_holder:call("setSelectedMysetIndex", set_id);
            master_player:set_field("_replaceAttackTypeA", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",0))
            master_player:set_field("_replaceAttackTypeB", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",1))
            master_player:set_field("_replaceAttackTypeC", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",2))
            master_player:set_field("_replaceAttackTypeD", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",3))
            master_player:set_field("_replaceAttackTypeE", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",4))
            master_player:set_field("_replaceAttackTypeF", player_replace_atk_myset_holder:call("getReplaceAtkTypeFromMyset",5))
            if cfg.separate_buff_and_action_set then
                player_replace_atk_myset_holder:call("setSelectedMysetIndex", current_set_id);
            end
            -- update hud
            guiHud_weaponTechniqueMyset:write_dword(0x118, set_id); -- guiHud_weaponTechniqueMyset:get_field("currentEquippedMySetIndex"):set_field("_Value", set_id);
        elseif set_id == 2 then
            -- switch to third style
            master_player:set_field("_replaceAttackTypeA", cfg.switch_action_0)
            master_player:set_field("_replaceAttackTypeB", cfg.switch_action_1)
            master_player:set_field("_replaceAttackTypeD", cfg.switch_action_2)
            master_player:set_field("_replaceAttackTypeF", cfg.switch_action_4)
            if cfg.switch_action_3 <= 1 then
                master_player:set_field("_replaceAttackTypeC", cfg.switch_action_3)
                master_player:set_field("_replaceAttackTypeE", 0)
            elseif cfg.switch_action_3 == 2 then
                master_player:set_field("_replaceAttackTypeC", 0)
                master_player:set_field("_replaceAttackTypeE", 1)
            end
        end
        script_myset_id = set_id;
    end
end

-- ##########################################
-- key listening
-- ##########################################
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

-- ##########################################
-- key binding
-- ##########################################
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

-- ##########################################
-- reframework UI
-- ##########################################
re.on_draw_ui(
    function() 
        if not imgui.tree_node("Easy style switch") then return end

        get_key_setting()

        local changed, value = imgui.checkbox("Enabled", cfg.enabled)
        if changed then cfg.enabled = value end

        local changed, value = imgui.checkbox("Disable move switch", cfg.disable_move_switch)
        if changed then cfg.disable_move_switch = value end

        local changed, value = imgui.checkbox("Separate buff and action set", cfg.separate_buff_and_action_set)
        if changed then cfg.separate_buff_and_action_set = value end

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
            changed, value = imgui.slider_int("Switch action 1", cfg.switch_action_0, 0, 1)
            if changed then cfg.switch_action_0 = value end

            changed, value = imgui.slider_int("Switch action 2", cfg.switch_action_1, 0, 1)
            if changed then cfg.switch_action_1 = value end

            changed, value = imgui.slider_int("Switch action 3", cfg.switch_action_2, 0, 1)
            if changed then cfg.switch_action_2 = value end

            changed, value = imgui.slider_int("Switch action 4", cfg.switch_action_3, 0, 2)
            if changed then cfg.switch_action_3 = value end

            changed, value = imgui.slider_int("Switch action 5", cfg.switch_action_4, 0, 1)
            if changed then cfg.switch_action_4 = value end

            imgui.tree_pop()
        end

        imgui.tree_pop()
    end
)