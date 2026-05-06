import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.I3
import Quickshell.Wayland
import qs.Common
import qs.Services

Item {
    id: root

    required property var barConfig

    signal colorPickerRequested
    signal barReady(var barConfig)

    property alias barVariants: barVariants
    property var hyprlandOverviewLoader: null
    property bool systemTrayMenuOpen: false

    property alias leftWidgetsModel: leftWidgetsModel
    property alias centerWidgetsModel: centerWidgetsModel
    property alias rightWidgetsModel: rightWidgetsModel

    property string _leftWidgetsJson: {
        root.barConfig;
        const leftWidgets = root.barConfig?.leftWidgets || [];
        const mapped = leftWidgets.map((w, index) => {
            if (typeof w === "string") {
                return {
                    widgetId: w,
                    id: w + "_" + index,
                    enabled: true
                };
            } else {
                const obj = Object.assign({}, w);
                obj.widgetId = w.id || w.widgetId;
                obj.id = (w.id || w.widgetId) + "_" + index;
                obj.enabled = w.enabled !== false;
                return obj;
            }
        });
        return JSON.stringify(mapped);
    }

    property string _centerWidgetsJson: {
        root.barConfig;
        const centerWidgets = root.barConfig?.centerWidgets || [];
        const mapped = centerWidgets.map((w, index) => {
            if (typeof w === "string") {
                return {
                    widgetId: w,
                    id: w + "_" + index,
                    enabled: true
                };
            } else {
                const obj = Object.assign({}, w);
                obj.widgetId = w.id || w.widgetId;
                obj.id = (w.id || w.widgetId) + "_" + index;
                obj.enabled = w.enabled !== false;
                return obj;
            }
        });
        return JSON.stringify(mapped);
    }

    property string _rightWidgetsJson: {
        root.barConfig;
        const rightWidgets = root.barConfig?.rightWidgets || [];
        const mapped = rightWidgets.map((w, index) => {
            if (typeof w === "string") {
                return {
                    widgetId: w,
                    id: w + "_" + index,
                    enabled: true
                };
            } else {
                const obj = Object.assign({}, w);
                obj.widgetId = w.id || w.widgetId;
                obj.id = (w.id || w.widgetId) + "_" + index;
                obj.enabled = w.enabled !== false;
                return obj;
            }
        });
        return JSON.stringify(mapped);
    }

    ScriptModel {
        id: leftWidgetsModel
        values: JSON.parse(root._leftWidgetsJson)
    }

    ScriptModel {
        id: centerWidgetsModel
        values: JSON.parse(root._centerWidgetsJson)
    }

    ScriptModel {
        id: rightWidgetsModel
        values: JSON.parse(root._rightWidgetsJson)
    }

    function triggerControlCenterOnFocusedScreen() {
        let focusedScreenName = "";
        if (CompositorService.isHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.monitor) {
            focusedScreenName = Hyprland.focusedWorkspace.monitor.name;
        } else if (CompositorService.isNiri && NiriService.currentOutput) {
            focusedScreenName = NiriService.currentOutput;
        } else if (CompositorService.isSway || CompositorService.isScroll || CompositorService.isMiracle) {
            const focusedWs = I3.workspaces?.values?.find(ws => ws.focused === true);
            focusedScreenName = focusedWs?.monitor?.name || "";
        } else if (CompositorService.isDwl && DwlService.activeOutput) {
            focusedScreenName = DwlService.activeOutput;
        }

        if (!focusedScreenName && barVariants.instances.length > 0) {
            const firstBar = barVariants.instances[0];
            firstBar.triggerControlCenter();
            return true;
        }

        for (var i = 0; i < barVariants.instances.length; i++) {
            const barInstance = barVariants.instances[i];
            if (barInstance.modelData && barInstance.modelData.name === focusedScreenName) {
                barInstance.triggerControlCenter();
                return true;
            }
        }
        return false;
    }

    function triggerWallpaperBrowserOnFocusedScreen() {
        let focusedScreenName = "";
        if (CompositorService.isHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.monitor) {
            focusedScreenName = Hyprland.focusedWorkspace.monitor.name;
        } else if (CompositorService.isNiri && NiriService.currentOutput) {
            focusedScreenName = NiriService.currentOutput;
        } else if (CompositorService.isSway || CompositorService.isScroll || CompositorService.isMiracle) {
            const focusedWs = I3.workspaces?.values?.find(ws => ws.focused === true);
            focusedScreenName = focusedWs?.monitor?.name || "";
        } else if (CompositorService.isDwl && DwlService.activeOutput) {
            focusedScreenName = DwlService.activeOutput;
        }

        if (!focusedScreenName && barVariants.instances.length > 0) {
            const firstBar = barVariants.instances[0];
            firstBar.triggerWallpaperBrowser();
            return true;
        }

        for (var i = 0; i < barVariants.instances.length; i++) {
            const barInstance = barVariants.instances[i];
            if (barInstance.modelData && barInstance.modelData.name === focusedScreenName) {
                barInstance.triggerWallpaperBrowser();
                return true;
            }
        }
        return false;
    }

    Variants {
        id: barVariants
        model: {
            const prefs = root.barConfig?.screenPreferences || ["all"];
            if (prefs.includes("all") || (typeof prefs[0] === "string" && prefs[0] === "all")) {
                return Quickshell.screens;
            }
            const filtered = Quickshell.screens.filter(screen => SettingsData.isScreenInPreferences(screen, prefs));
            if (filtered.length === 0 && root.barConfig?.showOnLastDisplay && Quickshell.screens.length === 1) {
                return Quickshell.screens;
            }
            return filtered;
        }

        delegate: DankBarWindow {
            rootWindow: root
            barConfig: root.barConfig
            leftWidgetsModel: root.leftWidgetsModel
            centerWidgetsModel: root.centerWidgetsModel
            rightWidgetsModel: root.rightWidgetsModel
        }
    }

    Variants {
        id: barExclusionVariants
        model: {
            const width = Math.max(0, root.barConfig?.barWidth ?? 0);
            const position = root.barConfig?.position ?? SettingsData.Position.Top;
            const isHorizontal = position === SettingsData.Position.Top || position === SettingsData.Position.Bottom;
            if (width <= 0 || !isHorizontal)
                return [];
            return barVariants.model;
        }

        delegate: PanelWindow {
            required property var modelData

            readonly property int barPos: root.barConfig?.position ?? SettingsData.Position.Top
            readonly property real effectiveSpacing: SettingsData.frameEnabled ? 0 : (root.barConfig?.spacing ?? 4)
            readonly property real effectiveBarThickness: SettingsData.frameEnabled ? SettingsData.frameBarSize : Theme.snap(Math.max(20 + (root.barConfig?.innerPadding ?? 4) * 0.6 + (root.barConfig?.innerPadding ?? 4) + 4, Theme.barHeight - 4 - (8 - (root.barConfig?.innerPadding ?? 4))), CompositorService.getScreenScale(modelData))

            screen: modelData
            color: "transparent"
            mask: Region {}

            WlrLayershell.namespace: "dms:bar-exclusion"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.exclusiveZone: (root.barConfig?.visible ?? true) ? (effectiveBarThickness + effectiveSpacing + (Theme.isConnectedEffect ? 0 : (root.barConfig?.bottomGap ?? 0))) : -1

            implicitWidth: 0
            implicitHeight: 1

            anchors {
                top: barPos === SettingsData.Position.Top
                bottom: barPos === SettingsData.Position.Bottom
                left: true
                right: true
            }
        }
    }
}
