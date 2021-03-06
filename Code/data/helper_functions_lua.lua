
index_inputs = {"A","B","Y","X","Left","Right","Up","Down"}

index_outputs ={"Mario_x_pos","Mario_y_pos","camera_x", "camera_y",
"sprite1_number","sprite1_x_pos","sprite1_y_pos",
"sprite2_number","sprite2_x_pos","sprite2_y_pos",
"sprite3_number","sprite3_x_pos","sprite3_y_pos",
"sprite4_number","sprite4_x_pos","sprite4_y_pos",
"sprite5_number","sprite5_x_pos","sprite5_y_pos",
"sprite6_number","sprite6_x_pos","sprite6_y_pos",
"sprite7_number","sprite7_x_pos","sprite7_y_pos",
"sprite8_number","sprite8_x_pos","sprite8_y_pos",
"sprite9_number","sprite9_x_pos","sprite9_y_pos",
"sprite10_number","sprite10_x_pos","sprite10_y_pos",
"sprite11_number","sprite11_x_pos","sprite11_y_pos",
"sprite12_number","sprite12_x_pos","sprite12_y_pos"}
local u8 =  memory.read_u8
local s8 =  memory.read_s8
local w8 =  memory.write_u8
local u16 = memory.read_u16_le
local s16 = memory.read_s16_le
local w16 = memory.write_u16_le
local u24 = memory.read_u24_le
local s24 = memory.read_s24_le
local w24 = memory.write_u24_le
local u32 = memory.read_u32_le
local s32 = memory.read_s32_le
local w32 = memory.write_u32_le
local fmt = string.format

function signed16(num)
  local maxval = 32768
  if num < maxval then return num else return num - 2*maxval end
end

package.path = "bizhawk/scripts/lib/?.lua" .. ";" .. package.path
local gui, input, joypad, emu, movie, memory, mainmemory, bit = gui, input, joypad, emu, movie, memory, mainmemory, bit
local WRAM = {
  -- I/O
  ctrl_1_1 = 0x0015,
  ctrl_1_2 = 0x0017,
  firstctrl_1_1 = 0x0016,
  firstctrl_1_2 = 0x0018,

  -- General
  game_mode = 0x0100,
  real_frame = 0x0013,
  effective_frame = 0x0014,
  timer_frame_counter = 0x0f30,
  RNG = 0x148d,
  RNG_input = 0x148b,
  timer = 0x0F31, -- 3 bytes, one for each digit
  level_paused = 0x13d4,
  sprite_data_pointer = 0x00CE, -- 3 bytes
  layer1_data_pointer = 0x0065, -- 3 bytes
  sprite_memory_header = 0x1692,
  lock_animation_flag = 0x009d, -- Most codes will still run if this is set, but almost nothing will move or animate.
  star_road_speed = 0x1df7,
  star_road_timer = 0x1df8,
  current_character = 0x0db3, -- #00 = Mario, #01 = Luigi
  exit_counter = 0x1F2E,
  event_flags = 0x1F02, -- 15 bytes (1 bit per exit)
  current_submap = 0x1F11,
  OW_tile_translevel = 0xD000, -- 0x800 bytes table
  OW_action_pointer = 0x13D9,
  OW_player_animation = 0x1F13, -- 2 bytes for Mario, 2 bytes for Luigi
  goal_exit_type = 0x141C,
  map16_table_low = 0xC800,
  map16_table_high = 0x1C800,

  -- Camera/Layers
  layer1_x_mirror = 0x001a,
  layer1_y_mirror = 0x001c,
  layer1_VRAM_left_up = 0x004d,
  layer1_VRAM_right_down = 0x004f,
  camera_x = 0x1462,
  camera_y = 0x1464,
  camera_left_limit = 0x142c,
  camera_right_limit = 0x142e,
  screen_mode = 0x005B,
  screens_number = 0x005d,
  hscreen_number = 0x005e,
  vscreen_number = 0x005f,
  vertical_scroll_flag_header = 0x1412,  -- #$00 = Disable; #$01 = Enable; #$02 = Enable if flying/climbing/etc.
  vertical_scroll_enabled = 0x13f1,
  camera_scroll_timer = 0x1401,
  layer2_x_nextframe = 0x1466,
  layer2_y_nextframe = 0x1468,

  -- Player
  x = 0x0094,
  y = 0x0096,
  previous_x = 0x00d1,
  previous_y = 0x00d3,
  x_sub = 0x13da,
  y_sub = 0x13dc,
  x_speed = 0x007b,
  x_subspeed = 0x007a,
  y_speed = 0x007d,
  direction = 0x0076,
  is_ducking = 0x0073,
  p_meter = 0x13e4,
  take_off = 0x149f,
  powerup = 0x0019,
  cape_spin = 0x14a6,
  cape_fall = 0x14a5,
  cape_interaction = 0x13e8,
  flight_animation = 0x1407,
  cape_gliding_index = 0x1408,
  diving_status = 0x1409,
  diving_status_timer = 0x14a4,
  player_animation_trigger = 0x0071,
  spinjump_flag = 0x140d,
  player_blocked_status = 0x0077,
  item_box = 0x0dc2,
  cape_x = 0x13e9,
  cape_y = 0x13eb,
  on_ground = 0x13ef,
  on_water = 0x0075,
  mario_score = 0x0f34,
  OW_x = 0x1f17,
  OW_y = 0x1f19,

  -- Yoshi
  yoshi_riding_flag = 0x187a,  -- #$00 = No, #$01 = Yes, #$02 = Yes, and turning around.
  yoshi_tile_pos = 0x0d8c,
  yoshi_in_pipe = 0x1419,
  
  -- Sprites
  sprite_status = 0x14c8,
  sprite_number = 0x009e,
  sprite_x_high = 0x14e0,
  sprite_x_low = 0x00e4,
  sprite_y_high = 0x14d4,
  sprite_y_low = 0x00d8,
  sprite_x_sub = 0x14f8,
  sprite_y_sub = 0x14ec,
  sprite_x_speed = 0x00b6,
  sprite_y_speed = 0x00aa,
  sprite_y_offscreen = 0x186c,
  sprite_OAM_xoff = 0x0304,
  sprite_OAM_yoff = 0x0305,
  sprite_swap_slot = 0x1861,
  sprite_phase = 0x00c2,
  sprite_misc_1504 = 0x1504,
  sprite_misc_1510 = 0x1510,
  sprite_misc_151c = 0x151c,
  sprite_misc_1528 = 0x1528,
  sprite_misc_1534 = 0x1534,
  sprite_stun_timer = 0x1540,
  sprite_player_contact = 0x154c,
  sprite_misc_1558 = 0x1558,
  sprite_sprite_contact = 0x1564,
  sprite_horizontal_direction = 0x157c,
  sprite_misc_1594 = 0x1594,
  sprite_x_offscreen = 0x15a0,
  sprite_misc_15ac = 0x15ac,
  sprite_being_eaten_flag = 0x15d0,
  sprite_OAM_index = 0x15ea,
  sprite_misc_1602 = 0x1602,
  sprite_misc_160e = 0x160e,
  sprite_index_to_level = 0x161a,
  sprite_misc_1626 = 0x1626,
  sprite_misc_163e = 0x163e,
  sprite_misc_187b = 0x187b,
  sprite_underwater = 0x164a,
  sprite_disable_cape = 0x1fe2,
  sprite_1_tweaker = 0x1656,
  sprite_2_tweaker = 0x1662,
  sprite_3_tweaker = 0x166e,
  sprite_4_tweaker = 0x167a,
  sprite_5_tweaker = 0x1686,
  sprite_6_tweaker = 0x190f,
  sprite_tongue_wait = 0x14a3,
  sprite_buoyancy = 0x190e,
  sprite_load_status_table = 0x1938, -- 128 bytes
  bowser_attack_timers = 0x14b0, -- 9 bytes

  -- Extended sprites
  extspr_number = 0x170b,
  extspr_x_high = 0x1733,
  extspr_x_low = 0x171f,
  extspr_y_high = 0x1729,
  extspr_y_low = 0x1715,
  extspr_x_speed = 0x1747,
  extspr_y_speed = 0x173d,
  extspr_suby = 0x1751,
  extspr_subx = 0x175b,
  extspr_table = 0x1765,
  extspr_table2 = 0x176f,

  -- Cluster sprites
  cluspr_flag = 0x18b8,
  cluspr_number = 0x1892,
  cluspr_x_high = 0x1e3e,
  cluspr_x_low = 0x1e16,
  cluspr_y_high = 0x1e2a,
  cluspr_y_low = 0x1e02,
  cluspr_timer = 0x0f9a,
  cluspr_table_1 = 0x0f4a,
  cluspr_table_2 = 0x0f72,
  cluspr_table_3 = 0x0f86,
  reappearing_boo_counter = 0x190a,

  -- Minor extended sprites
  minorspr_number = 0x17f0,
  minorspr_x_high = 0x18ea,
  minorspr_x_low = 0x1808,
  minorspr_y_high = 0x1814,
  minorspr_y_low = 0x17fc,
  minorspr_xspeed = 0x182c,
  minorspr_yspeed = 0x1820,
  minorspr_x_sub = 0x1844,
  minorspr_y_sub = 0x1838,
  minorspr_timer = 0x1850,

  -- Bounce sprites
  bouncespr_number = 0x1699,
  bouncespr_x_high = 0x16ad,
  bouncespr_x_low = 0x16a5,
  bouncespr_y_high = 0x16a9,
  bouncespr_y_low = 0x16a1,
  bouncespr_timer = 0x16c5,
  bouncespr_last_id = 0x18cd,
  turn_block_timer = 0x18ce,

  -- Quake sprites
  quakespr_number = 0x16cd,
  quakespr_x_high = 0x16d5,
  quakespr_x_low = 0x16d1,
  quakespr_y_high = 0x16dd,
  quakespr_y_low = 0x16d9,
  quakespr_timer = 0x18f8,

  -- Timer
  pipe_entrance_timer = 0x0088,
  score_incrementing = 0x13d6,
  fadeout_radius = 0x1433,
  peace_image_timer = 0x1492,
  end_level_timer = 0x1493,
  multicoin_block_timer = 0x186b,
  gray_pow_timer = 0x14ae,
  blue_pow_timer = 0x14ad,
  dircoin_timer = 0x190c,
  pballoon_timer = 0x1891,
  star_timer = 0x1490,
  animation_timer = 0x1496,
  invisibility_timer = 0x1497,
  fireflower_timer = 0x149b,
  yoshi_timer = 0x18e8,
  swallow_timer = 0x18ac,
  lakitu_timer = 0x18e0,
  spinjump_fireball_timer = 0x13e2,
  game_intro_timer = 0x1df5,
  pause_timer = 0x13d3,
  bonus_timer = 0x14ab,
  disappearing_sprites_timer = 0x18bf,
  message_box_timer = 0x1b89,

  -- Cheats
  frozen = 0x13fb,
  translevel_index = 0x13bf,
  level_flag_table = 0x1ea2,
  level_exit_type = 0x0dd5,
  midway_point = 0x13ce,
}

local function read_screens()
  local screen_mode = u8(WRAM.screen_mode)
  local level_type = bit.check(screen_mode, 0) and "Vertical" or "Horizontal"
  
  local screens_number = u8(WRAM.screens_number)
  
  local hscreen_current = u8(WRAM.x + 1)
  local hscreen_number = u8(WRAM.hscreen_number) - (level_type == "Horizontal" and 1 or 0)
  
  local vscreen_current = u8(WRAM.y + 1)
  local vscreen_number = u8(WRAM.vscreen_number) - (level_type == "Vertical" and 1 or 0)

  return level_type, screens_number, hscreen_current, hscreen_number, vscreen_current, vscreen_number
end

function get_map16_value(x_game, y_game)
  local num_x = math.floor(x_game/16)
  local num_y = math.floor(y_game/16)
  if num_x < 0 or num_y < 0 then return end  -- 1st breakpoint

  local level_type, screens, _, hscreen_number, _, vscreen_number = read_screens()
  local max_x, max_y
  if level_type == "Horizontal" then
    max_x = 16*(hscreen_number + 1)
    max_y = 27
  else
    max_x = 32
    max_y = 16*(vscreen_number + 1)
  end

  if num_x > max_x or num_y > max_y then return end  -- 2nd breakpoint

  local num_id, kind, address
  if level_type == "Horizontal" then
    num_id = 16*27*math.floor(num_x/16) + 16*num_y + num_x%16
  else
    local nx = math.floor(num_x/16)
    local ny = math.floor(num_y/16)
    local n = 2*ny + nx
    num_id = 16*16*n + 16*(num_y%16) + num_x%16
  end
  if (num_id >= 0 and num_id <= 0x37ff) then
    address = fmt("$%4.X", WRAM.map16_table_low + num_id)
    kind = 256*u8(WRAM.map16_table_high + num_id) + u8(WRAM.map16_table_low + num_id)
  end

  if kind then return  num_x, num_y, kind, address end
end

function read_inputs_from_file(filepath)
    inputs_raw = {}
    file = io.open(filepath, "rb")
    i = 0
    repeat 
    i = i+1
    inputs_raw[i] = file:read("*l")
    until i == #index_inputs
    inputs_processed = {}
    j = 1

    repeat 
    for word in string.gmatch(inputs_raw[j],"([^:]*)$") do 
        if word ~= "" then 
            word = string.sub(word,1,4)
            if word == "True" then
                inputs_processed[j] = true
            else 
                inputs_processed[j] = false
            end
        end
    end
    j = j+1
        
    until j == 9
    file:close()
    return inputs_processed
end

function write_outputs_to_file(filepath, outputs, index)
    file = io.open(filepath, "wb")
    i = 0
    repeat
        i = i+1
        if outputs[i] ~= nil then
            file:write(index[i],":",outputs[i],"\n")
        end
    until i == #index
    file:close()
end

function get_data()
    --Player data
    outputs = {}
    outputs[1] = s16(WRAM.x)  --Mario x-pos
    outputs[2] = s16(WRAM.y)  --Mario y-pos
    outputs[3] = u16(0x1462) --Camera x
    outputs[4] = u16(0x1464) --Camera y
    -- outputs[5] = u8(0x0019) --Powerup
    -- outputs[5] = s8(0x007b) --Mario X-Speed
    -- outputs[6] = s8(0x007d) --Mario Y-Speed
    -- outputs[7] = s8(0x0DBE) --Lives counter
    
    --Sprite data
    starting_index = 5
    max_sprites = 11 -- 12 is the max, minus one
    for slot = 0,max_sprites,1 do
        if u8(WRAM.sprite_status + slot) >= 8 then
            slot_number = u8(WRAM.sprite_number+slot)
            outputs[starting_index+(3*slot)] = slot_number --Sprite number
            outputs[starting_index+1+(3*slot)] =  signed16(256*u8(WRAM.sprite_x_high + slot) + u8(WRAM.sprite_x_low + slot)) --sprite pos x
            outputs[starting_index+2+(3*slot)] = signed16(256*u8(WRAM.sprite_y_high + slot) + u8(WRAM.sprite_y_low + slot)) --sprite pos y
            -- outputs[starting_index+3+(5*slot_id)] = u8(WRAM.sprite_x_speed+slot_id) --sprite speed x
            -- outputs[starting_index+4+(5*slot_id)] = u8(WRAM.sprite_y_speed+slot_id) --sprite speed y
            if slot_number == 0 then
                outputs[starting_index+(3*slot)] = -1
            end
        else
            outputs[starting_index+(3*slot)] = -1
            outputs[starting_index+1+(3*slot)] = 0
            outputs[starting_index+2+(3*slot)] = 0
        end
    end
    return outputs
end

function set_inputs(inputs_processed)
    input = {}
    i = 0
    repeat
        i = i +1 
        input[index_inputs[i]] = inputs_processed[i]
    until i == #index_inputs
    joypad.set(input,1)
end

function reset_game(current_level)
    start_level(current_level)
    reset_file = io.open("reset","wb")
    reset_file:write("1")
    --file:close()
end

function get_tile_data()
    map_tiles = {}
    index_tiles={}
    cam_x = u16(0x1462) --Camera x
    cam_y = u16(0x1464) --Camera y

    cam_x = (math.floor(cam_x/16))*16
    cam_y = (math.floor(cam_y/16))*16
    i = 0
    -- check for solid blocks if needed: if kind >= 0x111 and kind <= 0x16d or kind == 0x2b then
    for current_x = 8, 248,16 do 
        for current_y = 8, 216, 16 do
            i = i+1
            _,_,kind,_=get_map16_value(current_x+cam_x,current_y+cam_y) 
            x = tostring(math.floor((current_x)/16))
            y= tostring(math.floor((current_y)/16))
            coordinate = x .. "-" .. y
            table.insert(index_tiles,i,coordinate)
            table.insert(map_tiles,i, kind)
        end
    end
    
    return map_tiles,index_tiles
end

function check_for_player_death()
    state = u8(0x0071)
    if state == 9 then
        return true
    else
        return false
    end
end

function calculate_reward(prior_position) 
    _, number_screens,_,_,_,_ = read_screens()
    level_length=(number_screens+1)*512
    position = (s16(0x94)+u16(0x1462))/level_length
    reward = (position - prior_position)*1000000
    return reward, position
end

function start_level(current_level)
    savestate.loadslot(current_level) 
end

function wait_for_python()
    file = io.open("waiting","wb")
    file:write("1")  --1 = python is executing code, 0 = lua and emulator
    file:close()
    file = io.open("waiting","rb")
    int = file:read()
    while int == "1" do
        file:seek("set",0)
        int = file:read()
        
    end
    file:close()
end

function check_for_level_end()
    finished = u8(WRAM.end_level_timer)== 100
    return finished
end

--Main Game Lopp

function start_game() 
    current_level = 1
    start_level(current_level)

    running = true
    prior_position = 0
    while running do
        --current_level = math.random(9)
        outputs = get_data()
        write_outputs_to_file("outputs",outputs, index_outputs)

        map_data,index_tiles = get_tile_data()
        write_outputs_to_file("map16", map_data, index_tiles)
        
        wait_for_python()
        
        inputs = read_inputs_from_file("inputs")
        
        set_inputs(inputs)
        emu.frameadvance()
        set_inputs(inputs)
        emu.frameadvance()
        set_inputs(inputs)
        emu.frameadvance()
        set_inputs(inputs)
        emu.frameadvance()
       
        
        if check_for_player_death() then
            reset_game(current_level)
            reward = -5000
            prior_position = 0
            write_outputs_to_file("rewards",{reward}, {"reward"})

        elseif check_for_level_end() then
            reset_game(current_level)
            reward = 5000
            prior_position = 0
            write_outputs_to_file("rewards",{reward}, {"reward"})
            
        else    
            reward,prior_position = calculate_reward(prior_position)
            write_outputs_to_file("rewards",{reward}, {"reward"})
        end
    end
end

start_game()


