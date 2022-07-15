log.info("[easy_style_switch.lua] loaded")

local HwKeys = require("easy_style_switch.HwKeys");
HwKeys.setup();

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

local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
local gui_manager = sdk.get_managed_singleton("snow.gui.GuiManager");
-- local player_manager_type_def = sdk.find_type_definition("snow.player.PlayerManager");
-- local find_master_player_method = player_manager_type_def:get_method("findMasterPlayer");

-- log.debug(master_player:get_type_definition():get_full_name())
-- log.debug(master_player:get_address())

-- log.debug(player_replace_atk_myset_holder:get_type_definition():get_full_name())
-- log.debug(player_replace_atk_myset_holder:get_address())
-- local selected_myset_index = player_replace_atk_myset_holder:get_field("_SelectedMysetIndex");
-- log.debug(selected_myset_index:get_address())
-- snow.player.fsm.PlayerFsm2Action.start(via.behaviortree.ActionArg)
-- snow.player.fsm.PlayerFsm2ActionReplaceAtkMysetChange.start(via.behaviortree.ActionArg)
-- local player_fsm2_action_replace_atk_myset_change_type_def = sdk.find_type_definition("snow.player.fsm.PlayerFsm2ActionReplaceAtkMysetChange");
-- local start_method = player_fsm2_action_replace_atk_myset_change_type_def:get_method("start");
-- local PlayerBase = sdk.find_type_definition("snow.player.PlayerBase");
-- local reflectReplaceAtkMyset = PlayerBase:get_method("reflectReplaceAtkMyset");
-- local _ReplaceAtkMysetData = player_replace_atk_myset_holder:get_field("_ReplaceAtkMysetData");
-- local current_equipped_myset_index = guiHud_weaponTechniqueMyset:get_field("currentEquippedMySetIndex");

local PlayerReplaceAtkMysetHolder = sdk.find_type_definition("snow.player.PlayerReplaceAtkMysetHolder");
local changeReplaceAtkMyset = PlayerReplaceAtkMysetHolder:get_method("changeReplaceAtkMyset")

sdk.hook(changeReplaceAtkMyset,function(args)
    if cfg.disable_move_switch then
        return sdk.PreHookResult.SKIP_ORIGINAL
    else
        return sdk.PreHookResult.CALL_ORIGINAL
    end
end,function(retval) return retval; end)

local function switch_Myset(set_id)
    local master_player = player_manager:call("findMasterPlayer");
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
    if cfg.enabled then
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
        
        -- changed = imgui.button("switch")
        -- if changed then
        --     switch_Myset()
        -- end

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

        -- changed = imgui.button("debug")
        -- if changed then
        --     log.debug(sdk.to_int64(master_player:call("checkWeaponDraw", true)));
        -- end

        -- changed, value = imgui.slider_int("SetId", cfg.set_id, 0, 1)
        -- if changed then player_replace_atk_myset_holder:call("setSelectedMysetIndex", value) end
        imgui.tree_pop()
    end
)