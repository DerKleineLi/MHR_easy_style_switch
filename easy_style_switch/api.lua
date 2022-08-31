local ESS_api = {};

-- Global trigger flag
_ESS_update_flag = _ESS_update_flag or false;

-- update the state stored in mod, so that the switch function is consistent.
-- call this function whenever you change the SwtichActionMySet in game.
function ESS_api.update()
    _ESS_update_flag = true;
end

return ESS_api;