local weapon_actions = {}

weapon_actions.id_table = {
    {{1,2},{5,6},{85,86},{3,4,87},{88,89}}, -- Great Sword
    {{25,26},{29,30},{105,106},{27,28,107},{108,109}}, -- Hammer
    {{41,42},{39,40},{115,116},{37,38,117},{118,119}}, -- Lance
    {{15,16},{13,14},{95,96},{17,18,97},{98,99}}, -- Short Sword
    {{69,70},{67,68},{140,141},{71,72,142},{143,144}}, -- Light Bow Gun
    {{73,74},{77,78},{145,146},{75,76,147},{148,149}}, -- Heavy Bow Gun
    {{19,20},{21,22},{100,101},{23,24,102},{103,104}}, -- Dual Blades
    {{7,8},{11,12},{90,91},{9,10,92},{93,94}}, -- Long Sword
    {{31,32},{33,34},{110,111},{36,35,112},{113,114}}, -- Horm
    {{43,44},{47,48},{120,121},{45,46,122},{123,124}}, -- Gun Lance
    {{81,82},{79,80},{150,151},{83,84,152},{153,154}}, -- Bow
    {{49,50},{51,52},{125,126},{53,54,129},{128,127}}, -- Slash Axe
    {{57,58},{55,56},{130,131},{59,60,132},{133,134}}, -- Charge Axe
    {{61,62},{63,64},{135,136},{65,66,137},{138,139}} -- Insect Glaive
}

weapon_actions.player_weapon_type_to_weapon_type = {
    0, 11, 7, 4, 5, 1, 9, 2, 3, 6, 8, 12, 13, 10
}

weapon_actions.length_slot = {2,2,2,3,2}

return weapon_actions;