![Silent Hill F VR](https://raw.githubusercontent.com/letmein-vr/SHF_UEVR/main/screenshots/silenthillfvr.png)

---

## Credits
* **Praydog**: For creating [UEVR](https://github.com/praydog/UEVR) and making these mods possible!
* **jbusfield**: For the incredible helper libs framework used as the basis for this project (https://github.com/jbusfield/uevrlib).
* **joeyhodge**: For his amazing work getting *SHf* and other Unreal games working with UEVR.

---

## Features
* **Full 1st Person 6DOF**: Complete motion control support.
* **Visible Body**: Includes a visible torso and arms (legs coming soon).
* **Full Two Bone IK**: Realistic arm movement and positioning.
* **Articulated Hands**: Fully animated hands with grips that adapt to your equipped weapon.
* **Collision-Based Melee**: Physical combat interactions.
* **Two-Handed Weapons**: Snap your left hand to the weapon by moving it under your right hand (Axe, Hammer, etc.).
* **Movement Options**: Support for HMD directional movement or right-stick seated play.
* **Cinematic Handling**: Automatic camera switching to preserve original cutscenes.
* **Interactive Sequences**: Seamlessly switches to 3rd person for climbing, shimmying, and gaps.
* **Dynamic IK Rigging**: Automatically switches rigs depending on the character "body" you are inhabiting.

---

## 🛠 Instructions

> [!IMPORTANT]
> **UEVR Latest Nightly Required** Latest nightly here: https://github.com/praydog/UEVR-nightly/releases
> **Injection:** Download joeyhodge's `UEVRBackend.dll` (https://github.com/joeyhodge/UEVR/releases/tag/shf57) and place this in your UEVR folder (overwrite existing file). Inject at the main menu. Please be patient; injection takes a moment to complete.
> **Cutscenes FPS Fix** To fix the cutscene low framerate, download the zip here and extract into your SHf game exe folder (https://codeberg.org/Lyall/SHfFix/releases).

1. **DLSS/Upscaling:** Once in VR, you may need to toggle your upscaling method (On/Off) in the game settings, then toggle `r.TemporalAA.Upsampling` in the **UEVR Overlay > Console/Cvars** section.
2. **Troubleshooting:** Reset or reload scripts under **UEVR Overlay > LuaLoader > Main** if you encounter issues.
3. **Enemy Lock-on:** Disable (or do not enable) enemy lock-on (`R3` / Right Stick Click) while playing.
4. **Fine-Tuning:** If needed, adjust minimum controller swing speeds in the **Silent Hill f Config Dev** tab. *Do not adjust other settings unless you know what you're doing.*

---

## ⚔️ Melee Combat Notes
* **Swing Force:** Large weapons (Hammer, Naginata, Axe) require a full downward controller swing for the best hit registration.
* **Precision:** Melee is **not perfect**. Hits may occasionally fail to register due to internal cooldowns or enemy stagger animations.

## Controls

![Silent Hill F VR](https://raw.githubusercontent.com/letmein-vr/SHF_UEVR/main/screenshots/IMG_4747.jpeg)

---

## ⚠️ Known Issues ⚠️
* **Camera Rotation:** Occasional camera/pawn rotation glitches during melee attacks.
* **Costumes:** While costume changes work, certain changes in Hina's appearance may result in buggy or black textures.
* **Visuals:** Hina's skirt currently renders as solid black.
