local uevrDev    = require('libs/uevr_dev')
local ik         = require('libs/ik')
local uevrUtils  = require('libs/uevr_utils')
local controllers= require('libs/controllers')
local configui   = require('libs/configui')
local reticule   = require('libs/reticule')
local hands      = require('libs/hands')
local attachments= require('libs/attachments')
local input      = require('libs/input')
local flickerFixer = require('libs/flicker_fixer')
local animation  = require('libs/animation')
local montage    = require('libs/montage')
local pawn_module = require('libs/pawn')
local ui         = require('libs/ui')
local shf        = require('shf')
local melee      = require('melee')
local examine    = require('examine')

local isDeveloperMode = true

pawn_module.init(isDeveloperMode)
attachments.init(isDeveloperMode)
input.init(isDeveloperMode)
montage.init(isDeveloperMode)  -- enables dev montage tracker UI + registerMontageChangeCallback
uevrDev.init()
uevrUtils.setDeveloperMode(false)
ik.init(true, LogLevel.Info)
hands.enableConfigurationTool()

-- Disable UEVR movement/rotation overrides during cutscenes, attacks, death, etc.
-- shf.isVRInputDisabled() polls the game's own state methods and returns (bool, priority).
input.registerIsDisabledCallback(function()
    return shf.isVRInputDisabled()
end)

-- Wire hand animations into the IK rig and suppress native ApplyArmIK
-- once the PMC is live. shf.onIKMeshCreated handles both in one call.
local _ikMesh = nil  -- cached IK body mesh for weapon attachment

ik.registerOnMeshCreatedCallback(function(meshList, rig)
    shf.onIKMeshCreated(meshList, rig)
    _ikMesh = meshList and meshList[1]  -- cache for grip callback
    melee.setIKMesh(_ikMesh)            -- keep melee in sync for Claw hit detection
end)


-- ─────────────────────────────────────────────────────────────────────────────
-- Weapon attachment
-- ─────────────────────────────────────────────────────────────────────────────
local function getWeaponMesh()
    if uevrUtils.getValid(pawn) == nil then return nil end
    local weapon = pawn.CurrentWeapon
    if weapon == nil then return nil end
    return uevrUtils.getValid(weapon, {"WeaponMesh"})
end

attachments.registerOnGripUpdateCallback(function()
    local weaponMesh = getWeaponMesh()
    local rightHandComp = _ikMesh
    return weaponMesh, rightHandComp, "hand_r", nil, nil, nil, true
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Button swap: X (Reload) ↔ B (Dodge)
-- Must be registered at top-level script scope (not inside a require'd module).
-- ─────────────────────────────────────────────────────────────────────────────
local _blockX = false
local _blockB = false

uevr.sdk.callbacks.on_xinput_get_state(function(retval, user_index, state)
    if state == nil then return end

    if state.Gamepad.wButtons & 0x4000 ~= 0 and not _blockB then
        _blockX = true
        state.Gamepad.wButtons = state.Gamepad.wButtons & ~(XINPUT_GAMEPAD_X)
        state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_GAMEPAD_B
    else
        _blockX = false
    end

    if state.Gamepad.wButtons & 0x2000 ~= 0 and not _blockX then
        _blockB = true
        state.Gamepad.wButtons = state.Gamepad.wButtons & ~(XINPUT_GAMEPAD_B)
        state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_GAMEPAD_X
    else
        _blockB = false
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Melee collision config panel
-- Sliders live-update the runtime variables in melee.lua via melee.setConfig().
-- Values are auto-saved to data/shf_melee_config.json by configui.
-- ─────────────────────────────────────────────────────────────────────────────
local _MELEE_PREFIX = "shf_melee_"

configui.create({
    {
        panelLabel = "SHf Melee Config",
        saveFile   = "shf_melee_config",
        layout = {
            { widgetType = "text", label = "Collision Detection", wrapped = false },
            { widgetType = "spacing" },

            {
                widgetType   = "drag_float",
                id           = _MELEE_PREFIX .. "minSwingSpeed",
                label        = "Min Swing Speed  (UU/s)",
                speed        = 5.0,
                range        = { 50, 1200 },
                initialValue = 300.0,
            },
            { widgetType = "text", label = "  Tip speed required to check collision (300 = ~3 m/s)", wrapped = false },
            { widgetType = "spacing" },

            {
                widgetType   = "drag_float",
                id           = _MELEE_PREFIX .. "heavySpeed",
                label        = "Heavy Attack Speed  (UU/s)",
                speed        = 5.0,
                range        = { 100, 2000 },
                initialValue = 600.0,
            },
            { widgetType = "text", label = "  Above this triggers R2 (heavy). Below = R1 (light)", wrapped = false },
            { widgetType = "spacing" },

            { widgetType = "collapsing_header", label = "Advanced" },

            {
                widgetType   = "drag_float",
                id           = _MELEE_PREFIX .. "weaponLength",
                label        = "Weapon Tip Length  (UU)",
                speed        = 2.0,
                range        = { 10, 300 },
                initialValue = 80.0,
            },
            {
                widgetType   = "drag_float",
                id           = _MELEE_PREFIX .. "hitBuffer",
                label        = "Hit Buffer Radius  (UU)",
                speed        = 2.0,
                range        = { 0, 100 },
                initialValue = 15.0,
            },
            { widgetType = "text", label = "  Forgiveness margin added to each enemy's actual capsule radius", wrapped = false },
            {
                widgetType   = "drag_float",
                id           = _MELEE_PREFIX .. "hitHalfBuffer",
                label        = "Hit Buffer Half-Height  (UU)",
                speed        = 2.0,
                range        = { 0, 100 },
                initialValue = 15.0,
            },
            { widgetType = "text", label = "  Forgiveness margin added to each enemy's actual capsule half-height", wrapped = false },
            {
                widgetType   = "drag_float",
                id           = _MELEE_PREFIX .. "hitCooldown",
                label        = "Hit Cooldown  (sec)",
                speed        = 0.05,
                range        = { 0.1, 5.0 },
                initialValue = 0.8,
            },

            { widgetType = "spacing" },
            { widgetType = "text", label = "Claw Weapon", wrapped = false },
            {
                widgetType   = "drag_float",
                id           = _MELEE_PREFIX .. "clawTipOffset",
                label        = "Claw Tip Offset  (UU)",
                speed        = 1.0,
                range        = { -50, 150 },
                initialValue = 0.0,
            },
            { widgetType = "text", label = "  Projects collision point forward from hand_small_r along controller direction", wrapped = false },
            {
                widgetType   = "drag_float",
                id           = _MELEE_PREFIX .. "clawGTipOffset",
                label        = "Claw Large Tip Offset  (UU)",
                speed        = 1.0,
                range        = { -50, 150 },
                initialValue = 0.0,
            },
            { widgetType = "text", label = "  Projects collision point forward from index_01_large_r along controller direction", wrapped = false },

            { widgetType = "spacing" },
            { widgetType = "text", label = "Debug", wrapped = false },
            {
                widgetType   = "checkbox",
                id           = _MELEE_PREFIX .. "debugSphere",
                label        = "Show weapon tip sphere",
                initialValue = false,
            },
            { widgetType = "text", label = "  Shows exact point being tested for enemy overlap", wrapped = false },
        }
    }
})

-- Wire every slider to the live melee variables.
-- onCreateOrUpdate fires on first load (from saved JSON) AND on every drag.
local _meleeKeys = {
    "minSwingSpeed", "heavySpeed", "weaponLength",
    "hitBuffer", "hitHalfBuffer", "hitCooldown",
    "clawTipOffset", "clawGTipOffset",
}
for _, key in ipairs(_meleeKeys) do
    configui.onCreateOrUpdate(_MELEE_PREFIX .. key, function(value)
        melee.setConfig(key, value)
    end)
end

-- Debug sphere toggle
configui.onCreateOrUpdate(_MELEE_PREFIX .. "debugSphere", function(value)
    melee.setDebug(value)
end)