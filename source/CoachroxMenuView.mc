import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class CoachroxMenuView extends WatchUi.View {

    var app as CoachroxApp;

    enum {
        ITEM_START_WORKOUT,
        ITEM_VIEW_PLAN,
        ITEM_PROGRESS,
        ITEM_SETTINGS
    }

    var selectedItem as Number = 0;
    var menuItems as Array<String>;

    // Brand / UI colors
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;

    const COLOR_BG = 0x0F0F0F;
    const COLOR_SURFACE = 0x1C1C1C;
    const COLOR_SURFACE_2 = 0x252525;

    const COLOR_TEXT_MUTED = 0xA8A8A8;
    const COLOR_DIVIDER = 0x353535;

    // --- scrolling state ---
    var scrollOffsetY as Number = 0;

    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;

        // Consider swapping these to Rez.Strings.* later for localization
        menuItems = ["Start Workout", "View Plan", "Progress", "Settings"];
    }

    function onLayout(dc as Dc) as Void {
        // No layout resources used; draw everything in onUpdate()
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Background
        dc.setColor(COLOR_BG, COLOR_BG);
        dc.clear();

        var headerHeight = drawHeader(dc, w);
        var footerHeight = drawFooter(dc, w, h);

        drawMenu(dc, w, h, headerHeight, footerHeight);
    }

    // -------------------------
    // Header
    // -------------------------
    function drawHeader(dc as Dc, w as Number) as Number {
        var headerHeight = 44;

        // Subtle header panel
        dc.setColor(COLOR_SURFACE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, w, headerHeight);

        // Accent strip
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, w, 3);

        // Title + subtitle
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w/2, 16, Graphics.FONT_TINY, "COACHROX", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(COLOR_TEXT_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w/2, 32, Graphics.FONT_XTINY, "Training", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Divider
        dc.setColor(COLOR_DIVIDER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, headerHeight - 1, w - 10, headerHeight - 1);

        return headerHeight;
    }

    // -------------------------
    // Menu
    // -------------------------
    function drawMenu(dc as Dc, w as Number, h as Number, headerHeight as Number, footerHeight as Number) as Void {
        var sidePad = 10;
        var cardWidth = w - (sidePad * 2);
        var cardX = sidePad;

        var topPad = 8;
        var bottomPad = 8;

        var availableTop = headerHeight + topPad;
        var availableBottom = (h - footerHeight) - bottomPad;
        var availableHeight = availableBottom - availableTop;
        if (availableHeight <= 0) {
            return;
        }

        // Clip menu drawing to its viewport so it can't overdraw header/footer
        dc.setClip(0, availableTop, w, availableHeight);

        var cardSpacing = 8;
        var itemCount = menuItems.size();

        // Slightly larger cards for readability
        var cardHeight = 40;

        var contentHeight = (cardHeight * itemCount) + (cardSpacing * (itemCount - 1));
        var maxScroll = contentHeight - availableHeight;
        if (maxScroll < 0) { maxScroll = 0; }

        // Clamp scroll offset
        if (scrollOffsetY < 0) { scrollOffsetY = 0; }
        if (scrollOffsetY > maxScroll) { scrollOffsetY = maxScroll; }

        // Ensure selected item is visible (auto-scroll)
        var selectedTop = selectedItem * (cardHeight + cardSpacing);
        var selectedBottom = selectedTop + cardHeight;

        if (selectedTop < scrollOffsetY) {
            scrollOffsetY = selectedTop;
        } else if (selectedBottom > (scrollOffsetY + availableHeight)) {
            scrollOffsetY = selectedBottom - availableHeight;
        }

        // Center the whole menu content in the available region when it fits without scrolling
        var baseY = availableTop;
        if (maxScroll == 0) {
            baseY = availableTop + ((availableHeight - contentHeight) / 2);
        }

        // Draw items
        for (var i = 0; i < itemCount; i++) {
            var itemYInContent = i * (cardHeight + cardSpacing);
            var y = baseY + (itemYInContent - scrollOffsetY);

            // Skip if outside viewport
            if ((y + cardHeight) < availableTop) { continue; }
            if (y > availableBottom) { continue; }

            if (i == selectedItem) {
                drawSelectedMenuCard(dc, cardX, y, cardWidth, cardHeight);
            } else {
                drawNormalMenuCard(dc, cardX, y, cardWidth, cardHeight);
            }

            // Icon
            drawMenuIcon(dc, i, cardX + 16, y + (cardHeight / 2), i == selectedItem);

            // Text
            var textColor = (i == selectedItem) ? Graphics.COLOR_WHITE : COLOR_TEXT_MUTED;
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

            var textY = y + (cardHeight / 2);
            dc.drawText(cardX + 34, textY, Graphics.FONT_XTINY, menuItems[i], Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

            // Chevron
            if (i == selectedItem) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cardX + cardWidth - 12, textY, Graphics.FONT_XTINY, "›", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }

        // Scroll indicators (subtle)
        if (maxScroll > 0) {
            dc.setColor(COLOR_TEXT_MUTED, Graphics.COLOR_TRANSPARENT);
            if (scrollOffsetY > 0) {
                dc.drawText(w/2, availableTop - 2, Graphics.FONT_XTINY, "˄", Graphics.TEXT_JUSTIFY_CENTER);
            }
            if (scrollOffsetY < maxScroll) {
                dc.drawText(w/2, availableBottom + 2, Graphics.FONT_XTINY, "˅", Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        dc.clearClip();
    }

    function drawSelectedMenuCard(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        // Bright surface
        dc.setColor(COLOR_SURFACE_2, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, w, h, 6);

        // Left accent
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, 5, h, 6);

        // Thin outline for contrast
        dc.setColor(COLOR_DIVIDER, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(x, y, w, h, 6);
    }

    function drawNormalMenuCard(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        dc.setColor(COLOR_SURFACE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, w, h, 6);

        dc.setColor(COLOR_DIVIDER, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(x, y, w, h, 6);
    }

    function drawMenuIcon(dc as Dc, index as Number, x as Number, y as Number, isSelected as Boolean) as Void {
        var color = isSelected ? COLOR_ORANGE : COLOR_TEXT_MUTED;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        if (index == ITEM_START_WORKOUT) {
            // Play triangle
            dc.fillPolygon([[x-4, y-6], [x-4, y+6], [x+6, y]]);
        } else if (index == ITEM_VIEW_PLAN) {
            // Document/list icon
            dc.drawRoundedRectangle(x-6, y-7, 12, 14, 2);
            dc.drawLine(x-3, y-3, x+3, y-3);
            dc.drawLine(x-3, y, x+3, y);
            dc.drawLine(x-3, y+3, x+2, y+3);
        } else if (index == ITEM_PROGRESS) {
            // Bar chart icon
            dc.fillRectangle(x-6, y+2, 3, 5);
            dc.fillRectangle(x-2, y-1, 3, 8);
            dc.fillRectangle(x+2, y-5, 3, 12);
        } else if (index == ITEM_SETTINGS) {
            // Gear/settings icon (simple)
            dc.drawCircle(x, y, 6);
            dc.fillCircle(x, y, 2);

            // Small "teeth"
            dc.drawLine(x, y-6, x, y-8);
            dc.drawLine(x, y+6, x, y+8);
            dc.drawLine(x-6, y, x-8, y);
            dc.drawLine(x+6, y, x+8, y);
        }
    }

    // -------------------------
    // Footer
    // -------------------------
    function drawFooter(dc as Dc, w as Number, h as Number) as Number {
        var footerHeight = 58;
        var footerTopY = h - footerHeight;

        // Footer panel
        dc.setColor(COLOR_SURFACE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, footerTopY, w, footerHeight);

        // Divider
        dc.setColor(COLOR_DIVIDER, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, footerTopY, w - 10, footerTopY);

        var plan = app.getCurrentPlan();

        if (plan == null) {
            dc.setColor(COLOR_TEXT_MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w/2, footerTopY + 20, Graphics.FONT_XTINY, "No active plan", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return footerHeight;
        }

        var completion = plan.getCompletionRate();
        var weekText = "Week " + plan.getWeekNumber();

        // Left: week
        dc.setColor(COLOR_TEXT_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(12, footerTopY + 18, Graphics.FONT_XTINY, weekText, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Right: percent
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w - 12, footerTopY + 18, Graphics.FONT_XTINY, completion + "%", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Progress bar
        var barX = 12;
        var barY = footerTopY + 34;
        var barWidth = w - 24;
        var barHeight = 6;

        dc.setColor(COLOR_SURFACE_2, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barWidth, barHeight, 3);

        var fillWidth = (barWidth * completion) / 100;
        if (fillWidth < 0) { fillWidth = 0; }
        if (fillWidth > barWidth) { fillWidth = barWidth; }

        var progressColor = COLOR_BLUE;
        if (completion < 50) {
            progressColor = COLOR_ORANGE;
        } else if (completion >= 85) {
            progressColor = COLOR_GREEN;
        }

        dc.setColor(progressColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, fillWidth, barHeight, 3);

        return footerHeight;
    }

    // -------------------------
    // Selection / navigation
    // -------------------------
    function selectNext() as Void {
        selectedItem = (selectedItem + 1) % menuItems.size();
        WatchUi.requestUpdate();
    }

    function selectPrevious() as Void {
        selectedItem = (selectedItem - 1 + menuItems.size()) % menuItems.size();
        WatchUi.requestUpdate();
    }

    function selectItem() as Void {
        if (selectedItem == ITEM_START_WORKOUT) {
            var v = new WorkoutListView(app);
            WatchUi.pushView(v, new WorkoutListDelegate(v), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_VIEW_PLAN) {
            var v2 = new PlanView(app);
            WatchUi.pushView(v2, new PlanDelegate(v2), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_PROGRESS) {
            var v3 = new Progress.ProgressView(app);
            WatchUi.pushView(v3, new Progress.ProgressDelegate(v3), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_SETTINGS) {
            var v4 = new SettingsView(app);
            WatchUi.pushView(v4, new SettingsDelegate(v4), WatchUi.SLIDE_LEFT);
        }
    }
}