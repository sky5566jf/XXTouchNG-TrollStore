# XXTouchNG TrollStore 适配说明

## 已完成的修改

### 1. 移除 rocketbootstrap 依赖
所有模块的 `#import <rocketbootstrap/rocketbootstrap.h>` 和 `rocketbootstrap_*()` 调用已移除：
- touch/SimulateTouch.m
- screen/ScreenCapture.m
- device/DeviceConfigurator.m
- hid/HIDRecorderImpl.mm
- supervisor/Supervisor.m
- proc/ProcQueue.m
- auth/AuthPolicy.m
- debug/DebugWindow.x
- entitleme/EntitleMe.m
- app/TFContainerManager.m
- shared/TFLuaBridge+IMP+MiddleMan.m

### 2. 替换 substrate 为 ellekit
所有 Makefile 中的 `LIBRARIES = substrate` 已改为 `LIBRARIES = ellekit`：
- touch/Makefile
- screen/Makefile
- device/Makefile
- hid/Makefile
- debug/Makefile
- entitleme/Makefile
- monkey/Makefile
- alert/Makefile

### 3. 更新构建配置
- 根目录 Makefile: `TARGET := iphone:clang:14.5:14.0` (支持 iOS 14-17)
- 版本号: `XXT_VERSION = 3.0.1-trollstore`
- 签名工具: `TARGET_CODESIGN := ldid`

### 4. 创建构建脚本
- `build_trollstore.sh` - 用于构建 TrollStore 安装包

## 在 Mac 上构建

### 前置条件
1. 安装 Xcode 12+
2. 安装 theos:
   ```bash
   brew install theos
   ```
3. 安装 ellekit:
   ```bash
   git clone https://github.com/evelyneee/ellekit
   cd ellekit
   make package install
   ```
4. 安装 ldid:
   ```bash
   brew install ldid
   ```

### 构建步骤
```bash
cd XXTouchNG-main
chmod +x build_trollstore.sh
./build_trollstore.sh
```

### 安装到设备
1. 将生成的 `.tipa` 文件传到设备
2. 打开 TrollStore
3. 点击 + 选择 `.tipa` 文件
4. 安装

## 注意事项

1. **Logos 生成的文件** (logos__*.m) 中仍包含 `MSHookMessageEx`，这是正常的 - ellekit 提供兼容 API
2. **部分功能可能需要测试**:
   - IOHIDEvent 触控模拟
   - 屏幕截图
   - 设备控制
3. **entitleme 模块** 中的 MSHookFunction 调用已注释，可能需要额外适配

## 需要测试的功能

- [ ] 触控模拟 (touch)
- [ ] 屏幕截图 (screen)
- [ ] 按键模拟 (hid)
- [ ] 设备控制 (device)
- [ ] Web服务 (webserv)
- [ ] 脚本执行 (supervisor)
