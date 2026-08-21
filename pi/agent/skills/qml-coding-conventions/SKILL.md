---
name: qml-coding-conventions
description: QML coding conventions for object declarations, grouped properties, lists, and JavaScript code style. Use when writing, reviewing, or refactoring QML files.
---

# QML Coding Conventions

Follow these conventions when writing, editing, or reviewing QML code.

## Comment
Add comment at the end of object block
```qml
Rectangle {
}  // Rectangle

Rectangle {
    id: rect
}  // Rectangle($rect)
```

## QML Object Declarations

QML object attributes must be structured in the following order, separated by an empty line between each group:

1. `id`
2. property declarations
3. signal declarations
4. JavaScript functions
5. object properties
6. child objects
7. states
8. transitions

Example:

```qml
Rectangle {
    id: photo                                               // id on the first line makes it easy to find an object

    property bool thumbnail: false                          // property declarations
    property alias image: photoImage.source

    signal clicked                                          // signal declarations

    function doSomething(x)                                 // javascript functions
    {
        return x + photoImage.width
    }

    color: "gray"                                           // object properties
    x: 20                                                   // try to group related properties together
    y: 20
    height: 150
    width: {                                                // large bindings
        if (photoImage.width > 200) {
            photoImage.width;
        } else {
            200;
        }
    }

    Rectangle {                                             // child objects
        id: border
        anchors.centerIn: parent; color: "white"

        Image {
            id: photoImage
            anchors.centerIn: parent
        }
    }

    states: State {                                         // states
        name: "selected"
        PropertyChanges { target: border; color: "red" }
    }

    transitions: Transition {                               // transitions
        from: ""
        to: "selected"
        ColorAnimation { target: border; duration: 200 }
    }
}
```

## Grouped Properties

If using multiple properties from a group, use group notation instead of dot notation when it improves readability.

Instead of:
```qml
Rectangle {
    anchors.left: parent.left; anchors.top: parent.top; anchors.right: parent.right; anchors.leftMargin: 20
}

Text {
    text: "hello"
    font.bold: true; font.italic: true; font.pixelSize: 20; font.capitalization: Font.AllUppercase
}
```

Write:
```qml
Rectangle {
    anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: 20 }
}

Text {
    text: "hello"
    font { bold: true; italic: true; pixelSize: 20; capitalization: Font.AllUppercase }
}
```

## Lists

If a list contains only one element, omit the square brackets.

Instead of:
```qml
states: [
    State {
        name: "open"
        PropertyChanges { target: container; width: 200 }
    }
]
```

Write:
```qml
states: State {
    name: "open"
    PropertyChanges { target: container; width: 200 }
}
```

## JavaScript Code

### Single expression — write inline
```qml
Rectangle { color: "blue"; width: parent.width / 3 }
```

### Short script (a couple of lines) — use a block
```qml
Rectangle {
    color: "blue"
    width: {
        var w = parent.width / 3
        console.debug(w)
        return w
    }
}
```

### Medium script — create a function
```qml
function calculateWidth(object)
{
    var w = object.width / 3
    // ...
    // more javascript code
    // ...
    console.debug(w)
    return w
}

Rectangle { color: "blue"; width: calculateWidth(parent) }
```

### Long script — put in a separate JavaScript file
```qml
import "myscript.js" as Script

Rectangle { color: "blue"; width: Script.calculateWidth(parent) }
```

### Semicolons
If the code is longer than one line and within a block, use semicolons to indicate the end of each statement:

```qml
MouseArea {
    anchors.fill: parent
    onClicked: {
        var scenePos = mapToItem(null, mouseX, mouseY);
        console.log("MouseArea was clicked at scene pos " + scenePos);
    }
}
```
