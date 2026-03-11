import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class CoachroxMenuView extends WatchUi.View {

    var app as CoachroxApp;

    enum {
        ITEM_VIEW_PLAN,
        ITEM_START_WORKOUT,
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
        menuItems = ["View Plan", "Start Workout", "Progress", "Settings"];
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
        var headerHeight = 40;

        // Subtle header panel
        dc.setColor(COLOR_SURFACE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, w, headerHeight);

        // Accent strip
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, w, 3);

        // Title (positioned closer to the bottom divider)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var titleY = headerHeight - 14;
        dc.drawText(w/2, titleY, Graphics.FONT_TINY, "COACHROX", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        //dc.setColor(COLOR_TEXT_MUTED, Graphics.COLOR_TRANSPARENT);
        //dc.drawText(w/2, 32, Graphics.FONT_XTINY, "Training", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

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
        var cardWidth = w - (sidePad * 3);
        var cardX = sidePad;

        var topPad = 8;
        var bottomPad = 14; // was 8; add breathing room above footer

        var availableTop = headerHeight + topPad;
        var availableBottom = (h - footerHeight) - bottomPad;
        var availableHeight = availableBottom - availableTop;
        if (availableHeight <= 0) {
            return;
        }

        // Clip menu drawing to its viewport so it can't overdraw header/footer
        dc.setClip(0, availableTop + 1, w, availableHeight - 2); // inset clip slightly for round screens

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
            var textY = y + (cardHeight / 2);
            drawMenuItemText(dc, menuItems[i], cardX + 34, textY, cardWidth - 34 - 18, i == selectedItem);

            // Chevron
            if (i == selectedItem) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cardX + cardWidth - 12, textY, Graphics.FONT_XTINY, "›", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }

        dc.clearClip();

        // Scroll indicators (draw INSIDE the viewport edges so they don't collide with header/footer)
        if (maxScroll > 0) {
            dc.setColor(COLOR_TEXT_MUTED, Graphics.COLOR_TRANSPARENT);
            if (scrollOffsetY > 0) {
                dc.drawText(w/2, availableTop + 2, Graphics.FONT_XTINY, "^", Graphics.TEXT_JUSTIFY_CENTER);
            }
            if (scrollOffsetY < maxScroll) {
                dc.drawText(w/2, availableBottom - 10, Graphics.FONT_XTINY, "v", Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
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

    function drawMenuItemText(dc as Dc, label as String, x as Number, y as Number, maxWidth as Number, isSelected as Boolean) as Void {
        var textColor = isSelected ? Graphics.COLOR_WHITE : COLOR_TEXT_MUTED;
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

        // Try larger font first, then fall back
        var font = Graphics.FONT_TINY;
        var dims = dc.getTextDimensions(label, font);

        if (dims[0] > maxWidth) {
            font = Graphics.FONT_XTINY;
            dims = dc.getTextDimensions(label, font);
        }

        // If it still doesn't fit, truncate and add "..."
        if (dims[0] > maxWidth) {
            var ellipsis = "...";
            var ellW = dc.getTextDimensions(ellipsis, font)[0];

            var s = label;
            while (s.length() > 0 && (dc.getTextDimensions(s, font)[0] + ellW) > maxWidth) {
                s = s.substring(0, s.length() - 1);
            }
            label = s + ellipsis;
        }

        dc.drawText(x, y, font, label, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
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

        // Progress bar only (centered + clamped for round screens)
        var barHeight = 6;

        // Use the smaller dimension so the bar never exceeds the round watch safe area
        var maxBarWidth = (w < h) ? (w - 40) : (h - 40);
        if (maxBarWidth < 40) { maxBarWidth = 40; } // safety clamp

        var barWidth = maxBarWidth;
        var barX = (w - barWidth) / 2;
        var barY = footerTopY + ((footerHeight - barHeight) / 2);

        dc.setColor(COLOR_SURFACE_2, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barWidth, barHeight, 3);

        var completion = 0;
        if (plan != null) {
            completion = plan.getCompletionRate();
        }

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
        if (selectedItem == ITEM_VIEW_PLAN) {
           var v2 = new PlanView(app);
            WatchUi.pushView(v2, new PlanDelegate(v2), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_START_WORKOUT) {
            var v = new WorkoutListView(app);
            WatchUi.pushView(v, new WorkoutListDelegate(v), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_PROGRESS) {
            var v3 = new Progress.ProgressView(app);
            WatchUi.pushView(v3, new Progress.ProgressDelegate(v3), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_SETTINGS) {
            var v4 = new SettingsView(app);
            WatchUi.pushView(v4, new SettingsDelegate(v4), WatchUi.SLIDE_LEFT);
        }
    }
}