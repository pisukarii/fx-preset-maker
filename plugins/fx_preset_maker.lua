-- FX Preset Maker by pisukari  (grandMA3 2.4 or later)
-- Copyright (c) 2026 pisukari
-- License: CC BY-ND 4.0  https://creativecommons.org/licenses/by-nd/4.0/
--   use and share freely with credit to pisukari; do not distribute modified versions
-- One plugin for the whole EFFECT MAKER screen.
--
--   Plugin "FX Preset Maker by pisukari"          asks for an All pool, makes the dimmer
--                                               presets and the EFFECT MAKER layout
--   Plugin "FX Preset Maker by pisukari" "LEFT"   direction buttons: LEFT RIGHT CENTEROUT
--                                               DOWN UP DIAGDOWN DIAGUP
--
-- What it makes
--   * 17 dimmer phaser presets (Dim Sinus / Chase / Snap Off / Snap On) in the empty
--     numbers of the chosen All pool, recorded from all patched fixtures (Fixture Thru;
--     the programmer is cleared before and after). A universal preset keeps its data on
--     a real fixture, so without patched fixtures only the layout is made.
--     Presets with the same name already in the pool are reused, never overwritten.
--   * the "EFFECT MAKER" layout, when the show has none:
--       SHAPES / DIMMER PHASER / PHASE + TAKE SEL 3D / DIRECTION / FX CONTROL / QUICK STOMP
--   Every object goes into the lowest empty numbers of its pool. Nothing is overwritten.
--
-- Icons needed in <gma3_library>/media/images:
--   shp_1..22, phm_45/90/180/360, dir_1..7, fx_1..17, fxm_1..17,
--   macw_19/20/23/26/27/28/29/30/55, macw_locate, macw_stompfocus, macw_take3d
--   (macw_54 only with CFG.RECALL_VIEW)

-- name of this plugin in the pool (the direction macros call it by name)
local SELF = select(1, ...)
if type(SELF) ~= "string" or SELF == "" then SELF = "FX Preset Maker by pisukari" end

----------------------------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------------------------
local CFG = {
  LAYOUT_NAME = "EFFECT MAKER", -- layout that is built / used
  OLD_NAMES   = { "FX MAKE" },  -- an existing layout with one of these names is used too
  START       = 1,              -- search for empty numbers from here
  SAVE_POOL   = 25,             -- preset pool SAVE FX stores into (All 5, never offered for dimmer presets)
  RECALL_NAME = "FX RECALL",    -- SAVE FX uses the layout with this name (created if missing)
  RECALL_VIEW = nil,            -- e.g. 15: adds an "FX RECALL" button running "View 15"
}

local function msg(text)
  Printf("FX Preset Maker: " .. text)
  pcall(MessageBox, { title = "FX Preset Maker by pisukari", message = text,
                      commands = { { value = 1, name = "OK" } } })
end

----------------------------------------------------------------------------------------
-- EFFECT MAKER layout content
----------------------------------------------------------------------------------------
local SAVE_FX = [[Lua "local q=string.char(34) local s=SelectedSequence() local sn=(s and s.name) or 'FX' local nm=TextInput('FX NAME (' .. sn .. ' + ...)','') if not nm or nm=='' then Printf('SAVE FX canceled: no name') return end local m=0 for _,c in ipairs(DataPool().PresetPools[%POOL%]:Children()) do if c.no>m then m=c.no end end local n=m+1 Cmd('Store Preset %POOL%.'..n..' /Selective /NoConfirmation') Cmd('Label Preset %POOL%.'..n..' '..q..sn..' '..nm..q) Cmd('Assign Preset %POOL%.'..n..' At Layout %LAYOUT%') local e=DataPool().Layouts[%LAYOUT%]:Count() local k=n-1 local a='Set Layout %LAYOUT%.'..e..' Property '..q Cmd(a..'Width'..q..' 180') Cmd(a..'Height'..q..' 120') Cmd(a..'PosX'..q..' '..(160+(k%7)*188)) Cmd(a..'PosY'..q..' '..(564-math.floor(k/7)*130)) Printf('SAVE FX: Preset %POOL%.'..n..' '..sn..' '..nm)"]]

-- Locate: every feature group except Control back to its default, dimmer full, then
-- everything fades back out (knockout). Works for any fixture type.
local LOCATE_GROUPS = { "Position", "Gobo", "Color", "Beam", "Focus", "Shapers", "Video" }
local LOCATE = { 'Stomp' }
for _, g in ipairs(LOCATE_GROUPS) do
  LOCATE[#LOCATE + 1] = 'At Default FeatureGroup "' .. g .. '" Fade 1'
end
LOCATE[#LOCATE + 1] = { 'Attribute "Dimmer" At 100 Fade 1', 1.2 }
for _, g in ipairs({ "Dimmer", table.unpack(LOCATE_GROUPS) }) do
  LOCATE[#LOCATE + 1] = 'FeatureGroup "' .. g .. '" At Fade KnockOut'
end

-- {macro name, shape number}
local SHAPES = {
  { "SHP Sine", 1 }, { "SHP Linear", 2 }, { "SHP Ramp Up", 3 }, { "SHP Ramp Down", 4 }, { "SHP Snap", 5 },
  { "SHP Trapeze", 6 }, { "SHP Chase", 7 }, { "SHP Sine 1/2", 8 }, { "SHP Linear 1/2", 9 },
  { "SHP Ramp Up 1/2", 10 }, { "SHP Ramp Down 1/2", 11 }, { "SHP Snap 1/2", 12 }, { "SHP Strobe", 13 },
  { "SHP Circle", 14 }, { "SHP Circle Inverted", 15 }, { "SHP Eight", 16 }, { "SHP Eight Inverted", 17 },
  { "SHP Relative Sine", 18 }, { "SHP Flyout", 19 }, { "SHP Flyout Inverted", 20 }, { "SHP Wipe In", 21 },
  { "SHP Wipe Out", 22 },
}

-- buttons {macro name, icon file, macro lines, x, y, w, h}
local BUTTONS = {}
for i, s in ipairs(SHAPES) do
  local row, col = (i <= 11) and 0 or 1, (i - 1) % 11
  BUTTONS[#BUTTONS + 1] = { s[1], "shp_" .. s[2] .. ".png", { "At Shape " .. s[2] },
                            col * 130, 1084 - row * 130, 124, 124 }
end
local function add(name, icon, lines, x, y, w, h)
  BUTTONS[#BUTTONS + 1] = { name, icon, lines, x, y, w, h }
end
-- phase
add("PHASE 45",  "phm_45.png",  { "At Phase 0 Thru 45" },  960, 754, 230, 150)
add("PHASE 90",  "phm_90.png",  { "At Phase 0 Thru 90" },  1200, 754, 230, 150)
add("PHASE 180", "phm_180.png", { "At Phase 0 Thru 180" }, 960, 594, 230, 150)
add("PHASE 360", "phm_360.png", { "At Phase 0 Thru 360" }, 1200, 594, 230, 150)
-- selection grid = 3D stage positions (same as the 3D window's planar lasso; camera-independent)
add("TAKE SEL 3D", "macw_take3d.png", { 'Grid "Planar"' }, 960, 474, 470, 100)
-- direction (this plugin with a direction argument)
local DIRS = { { "FX LEFT", "LEFT" }, { "FX RIGHT", "RIGHT" }, { "FX CENTER OUT", "CENTEROUT" },
               { "FX TOP DOWN", "DOWN" }, { "FX BOTTOM UP", "UP" }, { "FX DIAG DOWN", "DIAGDOWN" },
               { "FX DIAG UP", "DIAGUP" } }
for i, d in ipairs(DIRS) do
  add(d[1], "dir_" .. i .. ".png", { 'Plugin "' .. SELF .. '" "' .. d[2] .. '"' }, (i - 1) * 210, 330, 200, 100)
end
-- FX control
add("Previous Step",    "macw_20.png", { "Previous Step" }, 0, 150, 280, 130)
add("SELECT ALL STEPS", "macw_55.png", { "Step 1 Thru" },   292, 150, 280, 130)
add("Next Step",        "macw_19.png", { "Next Step" },     584, 150, 280, 130)
add("SAVE FX",          "macw_26.png", "SAVE_FX", 876, 150, 280, 130)   -- lines filled in main()
add("Shuffle Selection","macw_23.png", { "Shuffle" },       1168, 150, 280, 130)
-- QUICK STOMP row: STOMP ALL, DIM, POS, COLOR, FOCUS, Locate
add("STOMP ALL",        "macw_30.png", { "Stomp" },         0, 0, 233, 100)
add("STOMP DIM",        "macw_27.png", { 'Stomp FeatureGroup "Dimmer"' },   243, 0, 233, 100)
add("STOMP POS",        "macw_29.png", { 'Stomp FeatureGroup "Position"' }, 486, 0, 233, 100)
add("STOMP COLOR",      "macw_28.png", { 'Stomp FeatureGroup "Color"' },    729, 0, 233, 100)
add("STOMP FOCUS",      "macw_stompfocus.png", { 'Stomp FeatureGroup "Focus"' }, 972, 0, 233, 100)
add("Locate",           "macw_locate.png", LOCATE,             1215, 0, 233, 100)
if CFG.RECALL_VIEW then
  add("FX RECALL", "macw_54.png", { "View " .. CFG.RECALL_VIEW }, 1168, -70, 280, 60)
end

-- text elements {text, x, y, w, h}
local TEXTS = {
  { "SHAPES", 0, 1214, 1430, 30 },
  { "DIMMER PHASER", 0, 914, 942, 30 },
  { "DIM SINUS", 0, 804, 150, 100 },
  { "CHASE", 0, 694, 150, 100 },
  { "SNAP OFF", 0, 584, 150, 100 },
  { "SNAP ON", 0, 474, 150, 100 },
  { "PHASE", 960, 914, 470, 30 },
  { "", 960, 582, 470, 4 },          -- divider between PHASE and TAKE SEL 3D
  { "DIRECTION", 0, 440, 1460, 30 },
  { "FX CONTROL", 0, 290, 1460, 30 },
  { "QUICK STOMP", 0, 108, 1460, 30 },
}

----------------------------------------------------------------------------------------
-- helpers
----------------------------------------------------------------------------------------
local function exists(ref)
  local ok, list = pcall(ObjectList, ref)
  return ok and list and #list > 0 or false
end

local function first(ref)
  local ok, list = pcall(ObjectList, ref)
  if ok and list then return list[1] end
end

local function q(s) return '"' .. s .. '"' end

-- load <file> from media/images into Image 3.<no>. The first Import of a file onPC has
-- not indexed yet can fail without creating the slot, so it is tried twice.
local function loadImage(no, file)
  for _ = 1, 2 do
    Cmd('Import Image Library ' .. q(file) .. ' At Image 3.' .. no)   -- creates the slot
    if exists("Image 3." .. no) then break end
  end
  Cmd('Set Image 3.' .. no .. ' Property "FileName" ' .. q(file))     -- loads the file
  local im = first("Image 3." .. no)
  local ok = im and tostring(im:Get("FileName")) == file
  if not ok then Printf("FX Preset Maker: image %s not found in media/images", file) end
  return ok
end

-- the lowest `count` empty numbers of a pool, e.g. free("Macro ", 45)
local function free(prefix, count, max)
  local out, no = {}, CFG.START
  while #out < count and no <= (max or 9999) do
    if not exists(prefix .. no) then out[#out + 1] = no end
    no = no + 1
  end
  return out
end

local function span(list)
  if #list == 0 then return "-" end
  local parts, a, b = {}, list[1], list[1]
  for i = 2, #list + 1 do
    local v = list[i]
    if v and v == b + 1 then b = v else
      parts[#parts + 1] = (a == b) and tostring(a) or (a .. "-" .. b)
      if v then a, b = v, v end
    end
  end
  return table.concat(parts, ", ")
end

----------------------------------------------------------------------------------------
-- build
----------------------------------------------------------------------------------------
local function build()
  local n = #BUTTONS

  -- 1. pick the lowest empty numbers
  local MAC = free("Macro ", n)
  local APP = free("Appearance ", n)
  local IMG = free("Image 3.", n, 1000)
  local LAY = free("Layout ", 2)
  if #MAC < n or #APP < n or #IMG < n or #LAY < 1 then
    msg(string.format("Stopped: not enough empty numbers (macros %d, appearances %d, images %d of %d)",
           #MAC, #APP, #IMG, n))
    return
  end
  local L = LAY[1]

  -- SAVE FX target: the existing layout named RECALL_NAME, or a new one
  local recall = first('Layout ' .. q(CFG.RECALL_NAME))
  local R
  if recall then
    R = recall.no
  else
    R = LAY[2] or (L + 1)
  end
  local saveFx = SAVE_FX:gsub("%%POOL%%", tostring(CFG.SAVE_POOL))
  saveFx = saveFx:gsub("%%LAYOUT%%", tostring(R))

  -- 2. images, appearances, macros
  for i, b in ipairs(BUTTONS) do
    local name, icon, lines = b[1], b[2], b[3]
    local img, app, mac = IMG[i], APP[i], MAC[i]
    if lines == "SAVE_FX" then lines = { saveFx } end

    loadImage(img, icon)

    Cmd('Store Appearance ' .. app .. ' ' .. q("FXM " .. name))
    Cmd('Set Appearance ' .. app .. ' Property "ImageMode" "Stretch" "BackAlpha" 0')
    Cmd('Assign Image 3.' .. img .. ' At Appearance ' .. app)

    Cmd('Store Macro ' .. mac .. ' ' .. q(name))
    local m = first("Macro " .. mac)
    if m then
      for _, l in ipairs(lines) do
        local cmd, wait = l, nil
        if type(l) == "table" then cmd, wait = l[1], l[2] end
        local ml = m:Append("MacroLine")
        ml:Set("Command", cmd)
        if wait then ml:Set("Wait", tostring(wait)) end
      end
    else
      Printf("FX Preset Maker: could not create Macro " .. mac)
    end
    Cmd('Assign Appearance ' .. app .. ' At Macro ' .. mac)
  end

  -- 3. layout
  Cmd('Store Layout ' .. L .. ' ' .. q(CFG.LAYOUT_NAME))
  local lay = first("Layout " .. L)
  if not lay then msg("Could not create Layout " .. L) return end

  local function place(e, x, y, w, h)
    Cmd('Set Layout ' .. L .. '.' .. e .. ' Property "PosX" ' .. x .. ' "PosY" ' .. y ..
        ' "PositionW" ' .. w .. ' "PositionH" ' .. h)
  end

  for i, b in ipairs(BUTTONS) do
    Cmd('Assign Macro ' .. MAC[i] .. ' At Layout ' .. L)
    local e = lay:Count()
    place(e, b[4], b[5], b[6], b[7])
    Cmd('Set Layout ' .. L .. '.' .. e .. ' Property "VisibilityObjectName" "Hidden"')
  end

  for _, t in ipairs(TEXTS) do
    lay:Append("Element")
    local e = lay:Count()
    place(e, t[2], t[3], t[4], t[5])
    Cmd('Set Layout ' .. L .. '.' .. e .. ' Property "CustomTextText" ' .. q(t[1]) .. ' "CustomTextSize" "24"')
  end

  -- 4. empty recall layout for SAVE FX
  if not recall then
    Cmd('Store Layout ' .. R .. ' ' .. q(CFG.RECALL_NAME))
  end

  Printf("EFFECT MAKER layout built: Layout %d (SAVE FX -> Layout %d)", L, R)
  Printf("  Macros %s", span(MAC))
  Printf("  Appearances %s", span(APP))
  Printf("  Images 3.%s", span(IMG))
  return lay
end

----------------------------------------------------------------------------------------
-- dimmer phaser presets
----------------------------------------------------------------------------------------
-- steps {absolute, width, transition}; sine steps get accel/decel -100
local S = 0.999999
-- {icon no (fx_n / fxm_n), name, x, y, steps, sine}
local PRESETS = {
  { 1,  "Dim Sinus",     160, 804, { { 100, 100, 100 }, { 0, 100, 100 } }, true },
  { 2,  "Dim Sinus 1/4", 318, 804, { { 100, 25, 100 },  { 0, 100, 25 } },  true },
  { 3,  "Dim Sinus 1/3", 476, 804, { { 100, 33, 100 },  { 0, 100, 33 } },  true },
  { 4,  "Dim Sinus 1/2", 634, 804, { { 100, 50, 100 },  { 0, 100, 50 } },  true },
  { 5,  "Chase",         160, 694, { { 100, 50, 0 },    { 0, 50, 0 } } },
  { 6,  "Chase 1/4",     318, 694, { { 100, 25, 0 },    { 0, 75, 0 } } },
  { 7,  "Chase 1/3",     476, 694, { { 100, 33, 0 },    { 0, 67, 0 } } },
  { 8,  "Snap Off",      160, 584, { { 100, 100, 100 }, { 0, S, 100 } } },
  { 9,  "Snap Off 80%",  318, 584, { { 100, 80, 100 },  { 0, 20, S } } },
  { 10, "Snap Off 60%",  476, 584, { { 100, 60, 100 },  { 0, 40, S } } },
  { 11, "Snap Off 40%",  634, 584, { { 100, 40, 100 },  { 0, 60, S } } },
  { 17, "Snap Off 20%",  792, 584, { { 100, 20, 100 },  { 0, 80, S } } },
  { 12, "Snap On",       160, 474, { { 100, S, 100 },   { 0, 100, 100 } } },
  { 13, "Snap On 80%",   318, 474, { { 100, S, 100 },   { 0, 100, 80 } } },
  { 14, "Snap On 60%",   476, 474, { { 100, S, 100 },   { 0, 100, 60 } } },
  { 15, "Snap On 40%",   634, 474, { { 100, S, 100 },   { 0, 100, 40 } } },
  { 16, "Snap On 20%",   792, 474, { { 100, S, 100 },   { 0, 100, 20 } } },
}
local PW, PH = 150, 100

local function freeNo(prefix, max)
  for no = CFG.START, max or 9999 do
    if not exists(prefix .. no) then return no end
  end
end

-- appearance <name> showing <file>; created (with its image) when missing
local function appearance(name, file)
  if exists('Appearance ' .. q(name)) then return end
  local img = nil
  for _, im in ipairs(ShowData().MediaPools.Images:Children()) do
    if im.filename == file or im.FileName == file then img = im.no; break end
  end
  if not img then
    img = freeNo("Image 3.", 1000)
    loadImage(img, file)
  end
  local app = freeNo("Appearance ")
  Cmd('Store Appearance ' .. app .. ' ' .. q(name))
  Cmd('Set Appearance ' .. app .. ' Property "ImageMode" "Stretch" "BackAlpha" 0')
  Cmd('Assign Image 3.' .. img .. ' At Appearance ' .. app)
end

-- dimmer ui channels of all patched fixtures (selects them all first); {} when none
local function selectDimmers()
  Cmd("ClearAll")
  Cmd("Fixture Thru")
  local chans = {}
  local sf = SelectionFirst()
  while sf do
    for _, ch in ipairs(GetUIChannels(sf) or {}) do
      local a = GetAttributeByUIChannel(ch)
      if a and tostring(a.name):upper() == "DIMMER" then chans[#chans + 1] = ch end
    end
    sf = SelectionNext(sf)
  end
  if #chans == 0 then Cmd("ClearAll") end
  return chans
end

-- store preset P.no from the selected fixtures: phaser on every dimmer channel
local function storeFromFixtures(P, no, p, chans)
  Cmd("ClearAll")
  Cmd("Fixture Thru")
  for _, ch in ipairs(chans) do
    local tb = { speed = 1, phase = 0, measure = 100 }
    for i, s in ipairs(p[5]) do
      local acc = p[6] and -100 or 0
      tb[i] = { absolute = s[1], width = s[2], trans = s[3], accel = acc, decel = acc,
                accel_type = 2, decel_type = 2 }
    end
    SetProgPhaser(ch, tb)
  end
  Cmd("Store Preset " .. P .. "." .. no .. " " .. q(p[2]) .. " /Universal /NoConfirmation")
end

-- which All pool: 21..25, nil when canceled
local function askPool()
  local cmds = {}
  for i = 1, 5 do
    -- the SAVE FX pool is not offered: dimmer presets and saved effects never mix
    if 20 + i ~= CFG.SAVE_POOL then
      local pool = DataPool().PresetPools[20 + i]
      local used = pool and #pool:Children() or 0
      cmds[#cmds + 1] = { value = 20 + i, name = "All " .. i .. "  (" .. used .. " used)" }
    end
  end
  cmds[#cmds + 1] = { value = 0, name = "Cancel" }
  local ok, r = pcall(MessageBox, {
    title = "FX Preset Maker by pisukari",
    message = "Which All pool gets the dimmer presets?\n17 presets are written into its empty numbers, in order.\nThey are recorded from all patched fixtures (the programmer is cleared).\n(All " .. (CFG.SAVE_POOL - 20) .. " is kept for SAVE FX.)",
    commands = cmds,
  })
  local v = ok and r and r.result
  if not v or v == 0 then return nil end
  return v
end

----------------------------------------------------------------------------------------
-- direction buttons:  Plugin "FX Preset Maker by pisukari" "LEFT" (RIGHT CENTEROUT DOWN UP DIAGDOWN DIAGUP)
-- Spreads the phase of every running phaser of the selection evenly in one direction,
-- whatever the selection grid looks like: grid gaps are ignored, the distinct positions
-- are spread over 0 .. 360 - 360/n so the first and the last never coincide.
-- MAtricks phase and X wings of the selection are cleared first.
----------------------------------------------------------------------------------------
local function ranks(values)
  local seen, list = {}, {}
  for _, v in ipairs(values) do
    if not seen[v] then seen[v] = true; list[#list + 1] = v end
  end
  table.sort(list)
  local r = {}
  for i, v in ipairs(list) do r[v] = i - 1 end
  return r, #list
end

local function norm(r, n)
  if n <= 1 then return 0 end
  return r / (n - 1)
end

-- t(xr, yr, nx, ny) -> position along the direction, 0 = head of the wave
local MODES = {
  RIGHT     = function(xr, yr, nx, ny) return norm(xr, nx) end,
  LEFT      = function(xr, yr, nx, ny) return 1 - norm(xr, nx) end,
  CENTEROUT = function(xr, yr, nx, ny) return math.abs(2 * norm(xr, nx) - 1) end,
  DOWN      = function(xr, yr, nx, ny) return norm(yr, ny) end,
  UP        = function(xr, yr, nx, ny) return 1 - norm(yr, ny) end,
  DIAGDOWN  = function(xr, yr, nx, ny) return (norm(xr, nx) + norm(yr, ny)) / 2 end,
  DIAGUP    = function(xr, yr, nx, ny) return (norm(xr, nx) + 1 - norm(yr, ny)) / 2 end,
}

local function clearMatricksPhase()
  for _, p in ipairs({ "PhaseFromX", "PhaseToX", "PhaseFromY", "PhaseToY", "XWings" }) do
    Cmd('Set Selection MAtricks "' .. p .. '" "None"')
  end
end

local function direction(mode)
  local fn = MODES[mode]
  if SelectionCount() == 0 then
    Printf("FX DIRECTION: nothing selected")
    return
  end

  -- read the selection grid
  local items, xs, ys = {}, {}, {}
  local sf, x, y = SelectionFirst()
  while sf do
    items[#items + 1] = { sf = sf, x = x, y = y }
    xs[#xs + 1] = x; ys[#ys + 1] = y
    sf, x, y = SelectionNext(sf)
  end
  local xr, nx = ranks(xs)
  local yr, ny = ranks(ys)

  -- position of each fixture along the direction, then distinct positions -> even steps
  local ts = {}
  for _, it in ipairs(items) do
    it.t = math.floor(fn(xr[it.x], yr[it.y], nx, ny) * 10000 + 0.5)
    ts[#ts + 1] = it.t
  end
  local tr, nt = ranks(ts)
  local step = 360 / math.max(nt, 1)

  clearMatricksPhase()

  local changed = 0
  for _, it in ipairs(items) do
    local phase = tr[it.t] * step
    for _, ch in ipairs(GetUIChannels(it.sf) or {}) do
      -- a running phaser = 2 or more steps (phaser_only=true returns no steps, so read the full form)
      local full = GetProgPhaser(ch, false)
      if full and #full >= 2 then
        -- write ONLY the phase: passing the table read back (masks, preset handles) breaks the programmer
        SetProgPhaser(ch, { phase = phase })
        changed = changed + 1
      end
    end
  end
  Printf("FX DIRECTION %s: %d fixtures, %d steps of %.1f deg, %d phaser channels", mode, #items, nt, step, changed)
end

----------------------------------------------------------------------------------------
-- presets + layout
----------------------------------------------------------------------------------------
local function maker()
  -- 1. ask the pool
  local P = askPool()
  if not P then Printf("FX Preset Maker: canceled") return end
  local pool = DataPool().PresetPools[P]

  -- 2. presets: reuse by name, else the next empty number
  local nos, made, failed = {}, 0, {}
  local byName = {}
  for _, c in ipairs(pool:Children()) do byName[tostring(c.name)] = c.no end
  local todo = 0
  for _, p in ipairs(PRESETS) do if not byName[p[2]] then todo = todo + 1 end end
  -- presets are recorded from all patched fixtures (a universal preset keeps its data on
  -- a real fixture, so a show without fixtures cannot hold them)
  local chans = (todo > 0) and selectDimmers() or {}
  local noFixtures = todo > 0 and #chans == 0
  local no = CFG.START
  for i, p in ipairs(PRESETS) do
    if byName[p[2]] then
      nos[i] = byName[p[2]]
    elseif not noFixtures then
      while exists("Preset " .. P .. "." .. no) do no = no + 1 end
      storeFromFixtures(P, no, p, chans)
      if exists("Preset " .. P .. "." .. no) then
        nos[i] = no; made = made + 1
      else
        failed[#failed + 1] = p[2]
      end
    end
  end
  if #chans > 0 then Cmd("ClearAll") end
  if #failed > 0 then
    msg("Could not create:\n" .. table.concat(failed, "\n"))
  end

  -- 3. pool icons
  for i, p in ipairs(PRESETS) do
    appearance("PFX " .. p[1], "fx_" .. p[1] .. ".png")
    appearance("PFXM " .. p[1], "fxm_" .. p[1] .. ".png")
    if nos[i] then
      local pr = first("Preset " .. P .. "." .. nos[i])
      if pr and (pr.appearance == nil or tostring(pr.appearance) == "") then
        Cmd('Assign Appearance ' .. q("PFX " .. p[1]) .. ' At Preset ' .. P .. '.' .. nos[i])
      end
    end
  end

  -- 4. layout: existing EFFECT MAKER (or old name), else build it
  local lay = first('Layout ' .. q(CFG.LAYOUT_NAME))
  for _, n in ipairs(CFG.OLD_NAMES) do
    if lay then break end
    lay = first('Layout ' .. q(n))
  end
  local built = false
  if not lay then
    lay = build()
    if not lay then return end
    built = true
  end
  local L = lay.no

  -- preset buttons already in the dimmer block: keep the chosen ones, remove the others
  -- (e.g. from an earlier run with another pool) so buttons never stack
  local slot, want = {}, {}
  for i, p in ipairs(PRESETS) do
    slot[p[3] .. "," .. p[4]] = true
    local pr = nos[i] and first("Preset " .. P .. "." .. nos[i])
    if pr then want[tostring(pr:Addr())] = true end
  end
  local onLayout, drop = {}, {}
  for idx, e in ipairs(lay:Children()) do
    local o = e.object
    if o and o:GetClass() == "Preset" then
      local a = tostring(o:Addr())
      if want[a] and not onLayout[a] then
        onLayout[a] = true
      elseif slot[tostring(e:Get("PosX")) .. "," .. tostring(e:Get("PosY"))] then
        drop[#drop + 1] = idx
      end
    end
  end
  for k = #drop, 1, -1 do Cmd("Delete Layout " .. L .. "." .. drop[k] .. " /NoConfirmation") end

  local placed = 0
  for i, p in ipairs(PRESETS) do
    local pr = nos[i] and first("Preset " .. P .. "." .. nos[i])
    if pr and not onLayout[tostring(pr:Addr())] then
      Cmd('Assign Preset ' .. P .. '.' .. nos[i] .. ' At Layout ' .. L)
      local e = lay:Count()
      local a = 'Set Layout ' .. L .. '.' .. e .. ' Property '
      Cmd(a .. '"PosX" ' .. p[3] .. ' "PosY" ' .. p[4] .. ' "PositionW" ' .. PW .. ' "PositionH" ' .. PH)
      Cmd(a .. '"Appearance" ' .. q("PFXM " .. p[1]))
      Cmd(a .. '"VisibilityObjectName" "Hidden" "VisibilityBar" "Hidden" "VisibilityIndicatorBar" "Hidden"')
      Cmd(a .. '"Action" "<Layout: SelectFixtures>"')
      placed = placed + 1
    end
  end

  local note = noFixtures and "\nNo fixture with a Dimmer is patched: patch fixtures, then run this plugin again." or ""
  msg(string.format("All %d (pool %d): %d presets created, %d placed.\nLayout %d %s%s%s",
      P - 20, P, made, placed, L, tostring(lay.name), built and " (new)" or "", note))
end

local function main(display, arg)
  local mode = tostring(arg or ""):upper():gsub("%s", "")
  if MODES[mode] then return direction(mode) end
  return maker()
end

return main
