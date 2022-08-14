log.info("[easy_style_switch.lua] loaded")

local HwKeys = require("easy_style_switch.HwKeys");

-- load config
local cfg = json.load_file("easy_style_switch_settings.json")

cfg = cfg or {}
cfg.enabled = cfg.enabled or true
cfg.disable_move_switch = cfg.disable_move_switch or true
cfg.disable_buff_switch = cfg.disable_buff_switch or true
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
sdk.hook(changeReplaceAtkMyset,function(args)
    if cfg.disable_move_switch and cfg.enabled then
        return sdk.PreHookResult.SKIP_ORIGINAL
    else
        return sdk.PreHookResult.CALL_ORIGINAL
    end
end,function(retval) return retval; end)

-- local PlayerBase = sdk.find_type_definition("snow.player.PlayerBase");
-- local reflectReplaceAtkMyset = PlayerBase:get_method("reflectReplaceAtkMyset");
-- sdk.hook(reflectReplaceAtkMyset,function(args)
--     if cfg.disable_move_switch and cfg.enabled then
--         return sdk.PreHookResult.SKIP_ORIGINAL
--     else
--         return sdk.PreHookResult.CALL_ORIGINAL
--     end
-- end,function(retval) return retval; end)

-- hud hook
local inject_hook = false;
local SwitchActionSystem = sdk.find_type_definition("snow.data.SwitchActionSystem");
local getEquippedActionMySetDataList = SwitchActionSystem:get_method("getEquippedActionMySetDataList(snow.data.weapon.WeaponTypes, snow.data.SwitchActionEquipType)");
local getEquippedActionMySetDataList_args = nil;
local script_myset_id = nil;

local current_weapon = nil;
local base_0 = nil;
local base_1 = nil;
local base_2 = nil;
local base_3 = nil;
local base_4 = nil;

local stored_Myset_id = nil;
local stored_0 = nil;
local stored_1 = nil;
local stored_2 = nil;
local stored_3 = nil;
local stored_4 = nil;

sdk.hook(getEquippedActionMySetDataList,function(args) 
    getEquippedActionMySetDataList_args = args;
    return sdk.PreHookResult.CALL_ORIGINAL;
end,function(retval) 
    if not inject_hook then return retval end
    -- log.debug("================")
    -- log.debug("args:")
    -- log.debug(sdk.to_int64(getEquippedActionMySetDataList_args[3]))
    -- log.debug(sdk.to_int64(getEquippedActionMySetDataList_args[4]))

    if stored_Myset_id ~= nil then
        if stored_Myset_id ~= sdk.to_int64(getEquippedActionMySetDataList_args[4]) then return retval end
        local mretval = sdk.to_managed_object(retval)
        mretval[0] = stored_0;
        mretval[1] = stored_1;
        mretval[2] = stored_2;
        mretval[3] = stored_3;
        mretval[4] = stored_4;
        local ptr = sdk.to_ptr(mretval)
        if ptr ~= nil then
            stored_Myset_id = nil;
            return ptr
        end
        return retval;
    end

    if script_myset_id ~= 2 then
        inject_hook = false;
        return retval
    end

    if current_weapon ~= sdk.to_int64(getEquippedActionMySetDataList_args[3]) then
        base_0 = nil;
        base_1 = nil;
        base_2 = nil;
        base_3 = nil;
        base_4 = nil;
        current_weapon = sdk.to_int64(getEquippedActionMySetDataList_args[3])
    end

    local gui_manager = sdk.get_managed_singleton("snow.gui.GuiManager");
    local guiHud_weaponTechniqueMyset = gui_manager:call("get_refGuiHud_WeaponTechniqueMySet");
    local current_gui_set_id = guiHud_weaponTechniqueMyset:get_field("currentEquippedMySetIndex"):get_field("_Value")
    if current_gui_set_id ~= sdk.to_int64(getEquippedActionMySetDataList_args[4]) then return retval end

    stored_Myset_id = current_gui_set_id;

    local mretval = sdk.to_managed_object(retval)
    stored_0 = mretval[0];
    stored_1 = mretval[1];
    stored_2 = mretval[2];
    stored_3 = mretval[3];
    stored_4 = mretval[4];

    -- log.debug("before")
    -- log.debug(mretval[0])
    -- log.debug(mretval[1])
    -- log.debug(mretval[2])
    -- log.debug(mretval[3])
    -- log.debug(mretval[4])

    if not base_0 then
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
    end

    mretval[0] = base_0 + cfg.switch_skill_1
    mretval[1] = base_1 + cfg.switch_skill_2
    mretval[2] = base_2 + cfg.switch_skill_3
    if cfg.switch_skill_4 <= 1 then
        mretval[3] = base_3 + cfg.switch_skill_4
    elseif cfg.switch_skill_4 == 2 then
        mretval[3] = base_2 + 2
    end
    mretval[4] = base_4 + cfg.switch_skill_5

    -- log.debug("after")
    -- log.debug(mretval[0])
    -- log.debug(mretval[1])
    -- log.debug(mretval[2])
    -- log.debug(mretval[3])
    -- log.debug(mretval[4])

    -- log.debug("stored:")
    -- log.debug(stored_0)
    -- log.debug(stored_1)
    -- log.debug(stored_2)
    -- log.debug(stored_3)
    -- log.debug(stored_4)

    local ptr = sdk.to_ptr(mretval)
    if ptr ~= nil then
        inject_hook = false;
        return ptr
    end

    return retval
end)


-- switch function
local function switch_Myset(set_id)
    local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
    local gui_manager = sdk.get_managed_singleton("snow.gui.GuiManager");
    local master_player = player_manager:call("findMasterPlayer");
    -- log.debug(master_player:get_address())
    if not master_player then return end
    local player_replace_atk_myset_holder = master_player:get_field("_ReplaceAtkMysetHolder");
    local current_set_id = player_replace_atk_myset_holder:call("getSelectedIndex");

    if not set_id then
        if current_set_id == 0 then
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
            if cfg.disable_buff_switch then
                player_replace_atk_myset_holder:call("setSelectedMysetIndex", current_set_id);
            end
            -- update hud
            local guiHud_weaponTechniqueMyset = gui_manager:call("get_refGuiHud_WeaponTechniqueMySet");
            -- guiHud_weaponTechniqueMyset:get_field("currentEquippedMySetIndex"):set_field("_Value", set_id);
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
        script_myset_id = set_id;
        -- update hud
        inject_hook = true;

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

        local changed, value = imgui.checkbox("Disable buff switch", cfg.disable_buff_switch)
        if changed then cfg.disable_buff_switch = value end

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

        if imgui.button("debug") then
            -- snow.data.DataShortcut.getName(snow.data.DataDef.PlWeaponActionId)
            -- snow.data.SwitchActionSystem.getEquippedActionMySetDataList(snow.data.weapon.WeaponTypes, snow.data.SwitchActionEquipType)
            local system_data_manager = sdk.get_managed_singleton("snow.data.SystemDataManager");
            local switch_action_system = system_data_manager:call("getSwitchActionSystem");
            local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
            local gui_manager = sdk.get_managed_singleton("snow.gui.GuiManager");
            local master_player = player_manager:call("findMasterPlayer");
            local weapon_data = master_player:call("getWeaponListData");
            local weapon_types = weapon_data:call("get_DtWeaponType");
            local player_replace_atk_myset_holder = master_player:get_field("_ReplaceAtkMysetHolder");
            local current_set_id = player_replace_atk_myset_holder:call("getSelectedIndex");
            local gui_manager = sdk.get_managed_singleton("snow.gui.GuiManager");
            local guiHud_weaponTechniqueMyset = gui_manager:call("get_refGuiHud_WeaponTechniqueMySet");
            local current_gui_set_id = guiHud_weaponTechniqueMyset:get_field("currentEquippedMySetIndex"):get_field("_Value")
            local player_weapon_type = master_player:get_field("_playerWeaponType");
            local action_data_list = switch_action_system:call("getEquippedActionMySetDataList(snow.data.weapon.WeaponTypes, snow.data.SwitchActionEquipType)", weapon_types, current_gui_set_id);
            -- local all_action_data_list = switch_action_system:call("get_ActiveActionDataList");
            -- local default_action_data_list = switch_action_system:call("getActionDataListForPlayer", player_weapon_type);
            -- local default_action_data_list = switch_action_system:call("getActionDataList(snow.player.PlayerWeaponType)", player_weapon_type);
            -- for i=0,13 do
            --     for j=0,4 do
            --         log.debug("(" .. i .. "," .. j .. "): " .. all_action_data_list[i][j]:call("get_ActionId"))
            --     end
            -- end
            log.debug(action_data_list:get_type_definition():get_full_name())
            for i=0,4 do
                log.debug(action_data_list[i]:get_field("value__"))
            end

        end

        imgui.tree_pop()
    end
)