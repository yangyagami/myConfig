---
name: qml-custom-dialog-dim
description: >-
  Popup management via DialogController singleton + custom dim via frame-level
  dimmingOverlay. Use when adding modal dialogs to a frameless Qt Quick Window.
metadata:
  category: pattern
---

# QML 弹窗管理与自定义 Dim

## 1. 弹窗管理：DialogController 单例

弹窗只实例化一次，挂到根窗口，注册给 DialogController。页面不直接操作弹窗，全走 Controller。

### DialogController（`controller/DialogController.qml`）

```qml
pragma Singleton
import QtQuick

QtObject {
    property var confirmDialog: null
    property var savePathDialog: null

    function showConfirm(frame, text, onAccept) {
        if (!confirmDialog) return
        confirmDialog.pkgName = text
        confirmDialog.frame = frame
        var conn = confirmDialog.accepted.connect(function() {
            if (onAccept) onAccept()
            try { confirmDialog.accepted.disconnect(conn) } catch(e) {}
        })
        confirmDialog.open()
    }

    function showSavePath(frame, onAccept) {
        if (!savePathDialog) return
        savePathDialog.frame = frame
        var conn = savePathDialog.accepted.connect(function(path) {
            if (onAccept) onAccept(path)
            try { savePathDialog.accepted.disconnect(conn) } catch(e) {}
        })
        savePathDialog.open()
    }
}
```

- **一次性信号连接**：`accepted` 连完立即 disconnect，避免多次打开弹窗重复触发回调
- **frame 注入**：打开前把 frame 引用写进弹窗，弹窗用它居中 + 控制 dim
- **open/close 不 create/destroy**：弹窗实例常驻，只开关

### 根窗口注册（`MainWindow.qml`）

```qml
Custom.ConfirmDialog { id: globalConfirmDialog }
Custom.SavePathDialog  { id: globalSavePathDialog  }

Component.onCompleted: {
    DialogController.confirmDialog  = globalConfirmDialog
    DialogController.savePathDialog = globalSavePathDialog
}
```

### 页面调用

```qml
DialogController.showConfirm(findFrame(), qsTr("确认卸载？"), function() {
    entity.uninstall()
})
```

---

## 2. 自定义 Dim：frame 内置 dimmingOverlay

不用 `Popup { dim: true }`，改为在 frame Rectangle 里放一层半透明遮罩。

### Frame 侧（`Window.qml`）

```qml
Rectangle {
    id: frame
    property bool dimmed: false
    // ... TitleBar, content ...

    // dimmingOverlay —— 放 frame 最后一个 child
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Qt.rgba(0.0, 0.0, 0.0, 0.2)
        visible: parent.dimmed

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPressed:  function(mouse) { mouse.accepted = true }
            onReleased: function(mouse) { mouse.accepted = true }
            onClicked:  function(mouse) { mouse.accepted = true }
            onWheel:    function(wheel) { wheel.accepted = true }
        }
    }
}
```

- **`hoverEnabled: true`**：不加弹窗按钮 hover 效果全废
- **最后声明**：盖住 frame 内其他内容
- **`radius` 对齐 parent**：跟 frame 圆角一致
- **吃掉所有事件**：防止点击穿透到下层

### 弹窗侧（所有 Popup）

```qml
Popup {
    property Item frame: null
    dim: false
    parent: Overlay.overlay

    onOpened: { if (frame) frame.dimmed = true  }
    onClosed: { if (frame) frame.dimmed = false }
}
```

- **`dim: false`**：显式关掉 Qt 自带 dim
- **`parent: Overlay.overlay`**：弹窗渲染在 dimmingOverlay 之上
- **`frame` 可空**：x/y 有 fallback，toggle 有 `if (frame)` 守卫
- **用 `onClosed` 不用 `onClosing`**：`onClosing` 导致 dim 在弹窗还没消失时就关掉
