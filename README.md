## Easy style switch for MHRS

*English version below

本 mod 可以让你瞬间切换红/蓝书，并可以自定义第三本书并进行切换。

### 使用
- 先安装 [REFramework](https://www.nexusmods.com/monsterhunterrise/mods/26) 再安装本 mod 。
- 在REFramework的UI里修改设置，可设置的参数如下:
  - Enabled: 是否启用本 mod 。
  - Disable action switch by 'switch skill swap': 是否禁用默认切换方式，快速切换动作仍能使用，只是不再能切书。
  - Separate buff and action set: 分开动作和书，用于伏魔耗命等技能。
  - Key bindings: 按键设置
    - Keyboard/Gamepad switch: 设置在红/蓝之间切换的按键。
    - Keyboard/Gamepad red/blue: 设置切为红/蓝书所含动作的按键。
    - Keyboard/Gamepad third: 设置切为第三书的按键。
  - Third style: 设置第三本书
    - Switch skill #: 设置第#个替换技（顺序同游戏内设置）
  - Explanation：详细说明（英文）
- 推荐设置：关闭动作快捷栏，像但丁一样用十字键切换风格。

### 接口
见 `easy_style_switch/state_update_api.lua`

### 开发人员

[Hugo](https://github.com/DerKleineLi) - 主要开发者。

[godoakos](https://www.nexusmods.com/monsterhunterrise/users/453968) - 他开发的 [Carve Timer Skip and Fast Return](https://www.nexusmods.com/monsterhunterrise/mods/62) 提供了按键绑定的框架。

### 已知问题

参见 issues 。

### 参与开发

你可以通过开 issue 和 pr 来参与开发。

我在 issues 里提了一些想法并希望得到帮助。

---

This mod enables instant scroll-switch. You can also customize a third scroll and switch to it.

### Usage
- You need [REFramework](https://www.nexusmods.com/monsterhunterrise/mods/26) to run this mod.
- Change settings in script generated UI, the supported settings are:
  - Enabled: whether the script functionality is enabled.
  - Disable move switch: whether to disable the default move to switch between scrolls. You can still do the move if set to true.
  - Separate buff and action set: can be used for skills like 'Dereliction'.
  - Key bindings: 
    - Keyboard/Gamepad switch: set the button to switch between red/blue scrolls.
    - Keyboard/Gamepad red/blue: set the button to switch to the red/blue scroll.
    - Keyboard/Gamepad third: set the button to switch to the third scroll.
  - Third style: set the third scroll
    - Switch skill #: set the #-th switch skill (same order as in-game setting).
  - Explanation：more detailed explanation.
- Recommended: disable all action bars and use D-pad to switch styles like Dante.

### API
See `easy_style_switch/state_update_api.lua`.

### Credits

[Hugo](https://github.com/DerKleineLi) - creator of this mod and its main contributor.

[godoakos](https://www.nexusmods.com/monsterhunterrise/users/453968) - creator of [Carve Timer Skip and Fast Return](https://www.nexusmods.com/monsterhunterrise/mods/62) mod, which provides pattern for key binding.

### Known issue

See issues.

### Contribution

Feel free to post issues and open prs!

Looking for help to solve problems posted in issue.