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

    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_DARK_BG = 0x1A1A1A;
    const COLOR_CARD_BG = 0x2D2D2D;
    const COLOR_TEXT_SECONDARY = 0xAAAAAA;

    // --- scrolling state ---
    var scrollOffsetY as Number = 0;

    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;

        menuItems = ["Start Workout", "View Plan", "Progress", "Settings"];
    }

    function onLayout(dc as Dc) as Void {
        // No layout resources used; draw everything in onUpdate()
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Dark background
        dc.setColor(COLOR_DARK_BG, COLOR_DARK_BG);
        dc.clear();

        // Header
        var headerHeight = drawCompactHeader(dc, w);

        // Footer (returns reserved height; may draw "No active plan")
        var footerHeight = drawCompactFooter(dc, w, h);

        // Menu cards, fit between header and footer (prevents overlap/clipping on small screens)
        drawCompactMenuCards(dc, w, h, headerHeight, footerHeight);
    }

    function drawCompactHeader(dc as Dc, w as Number) as Number {
        // Top accent bar
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, w, 2);

        // App name (moved down a bit + smaller font)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w/2, 8, Graphics.FONT_XTINY, "COACHROX", Graphics.TEXT_JUSTIFY_CENTER);

        // Thin separator
        var sepY = 28;
        dc.setColor(0x404040, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(12, sepY, w - 12, sepY);

        // Return the height the header consumes
        return sepY + 6; // small padding below separator
    }

    function drawCompactMenuCards(dc as Dc, w as Number, h as Number, headerHeight as Number, footerHeight as Number) as Void {
        var sidePad = 10;
        var cardWidth = w - (sidePad * 2);
        var cardX = sidePad;

        // Keep content inside safe-ish area
        var topPad = 4;
        var bottomPad = 4;

        var availableTop = headerHeight + topPad;
        var availableBottom = (h - footerHeight) - bottomPad;
        var availableHeight = availableBottom - availableTop;
        if (availableHeight <= 0) {
            return;
        }

        var cardSpacing = 4;
        var itemCount = menuItems.size();

        // Fixed-ish card height so we can scroll when list is taller than the viewport
        var cardHeight = 30;

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
        // (If it doesn't fit, we just use scrolling with the top anchored at availableTop)
        var baseY = availableTop;
        if (maxScroll == 0) {
            baseY = availableTop + ((availableHeight - contentHeight) / 2);
        }

        // Draw items (only those that are visible)
        for (var i = 0; i < itemCount; i++) {
            var itemYInContent = i * (cardHeight + cardSpacing);
            var y = baseY + (itemYInContent - scrollOffsetY);

            // Skip if outside viewport
            if ((y + cardHeight) < availableTop) { continue; }
            if (y > availableBottom) { continue; }

            if (i == selectedItem) {
                drawCompactSelectedCard(dc, cardX, y, cardWidth, cardHeight);
            } else {
                drawCompactNormalCard(dc, cardX, y, cardWidth, cardHeight);
            }

            // Icon indicator
            drawMenuIcon(dc, i, cardX + 10, y + (cardHeight/2), i == selectedItem);

            // Menu text (smaller font)
            var textColor = (i == selectedItem) ? Graphics.COLOR_WHITE : Graphics.COLOR_LT_GRAY;
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

            var textY = y + (cardHeight / 2);
            dc.drawText(cardX + 26, textY, Graphics.FONT_XTINY, menuItems[i], Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

            // Arrow for selected (smaller font)
            if (i == selectedItem) {
                dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cardX + cardWidth - 10, textY, Graphics.FONT_XTINY, ">", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }

        // Optional scroll indicators (subtle)
        if (maxScroll > 0) {
            dc.setColor(COLOR_TEXT_SECONDARY, Graphics.COLOR_TRANSPARENT);
            if (scrollOffsetY > 0) {
                dc.drawText(w/2, availableTop - 2, Graphics.FONT_XTINY, "˄", Graphics.TEXT_JUSTIFY_CENTER);
            }
            if (scrollOffsetY < maxScroll) {
                dc.drawText(w/2, availableBottom + 2, Graphics.FONT_XTINY, "˅", Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
    }

    function drawMenuIcon(dc as Dc, index as Number, x as Number, y as Number, isSelected as Boolean) as Void {
        var color = isSelected ? COLOR_ORANGE : COLOR_TEXT_SECONDARY;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        if (index == ITEM_START_WORKOUT) {
            // Play triangle
            dc.fillPolygon([[x-3, y-4], [x-3, y+4], [x+4, y]]);
        } else if (index == ITEM_VIEW_PLAN) {
            // Document/list icon
            dc.drawRectangle(x-4, y-4, 8, 8);
            dc.drawLine(x-2, y-2, x+2, y-2);
            dc.drawLine(x-2, y, x+2, y);
            dc.drawLine(x-2, y+2, x+2, y+2);
        } else if (index == ITEM_PROGRESS) {
            // Bar chart icon
            dc.fillRectangle(x-4, y, 2, 4);
            dc.fillRectangle(x-1, y-2, 2, 6);
            dc.fillRectangle(x+2, y-4, 2, 8);
        } else if (index == ITEM_SETTINGS) {
            // Gear/settings icon
            dc.drawCircle(x, y, 4);
            dc.fillCircle(x, y, 2);
        }
    }

    function drawCompactSelectedCard(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        // Blue background
        dc.setColor(COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, w, h, 4);

        // Orange accent edge
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, 3, h, 4);
    }

    function drawCompactNormalCard(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        // Card background
        dc.setColor(COLOR_CARD_BG, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, w, h, 4);
    }

    function drawCompactFooter(dc as Dc, w as Number, h as Number) as Number {
        // Always reserve footer space so the menu never overlaps it
        // Increased height so footer text isn't clipped on round/limited displays
        var footerHeight = 40;
        var footerTopY = h - footerHeight;

        var plan = app.getCurrentPlan();
        if (plan != null) {
            // Thin separator
            dc.setColor(0x404040, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(12, footerTopY, w - 12, footerTopY);

            // Week (smaller font)
            var weekText = "W" + plan.getWeekNumber();
            dc.setColor(COLOR_TEXT_SECONDARY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(14, footerTopY + 6, Graphics.FONT_TINY, weekText, Graphics.TEXT_JUSTIFY_LEFT);

            // Progress bar (moved down a bit)
            var barWidth = 50;
            var barHeight = 4;
            var barX = (w - barWidth) / 2;
            var barY = footerTopY + 16;

            dc.setColor(COLOR_CARD_BG, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, barY, barWidth, barHeight, 2);

            var completion = plan.getCompletionRate();
            var fillWidth = (barWidth * completion) / 100;
            if (fillWidth < 0) { fillWidth = 0; }
            if (fillWidth > barWidth) { fillWidth = barWidth; }

            var progressColor = COLOR_GREEN;
            if (completion < 50) {
                progressColor = COLOR_ORANGE;
            } else if (completion >= 85) {
                progressColor = COLOR_GREEN;
            } else {
                progressColor = COLOR_BLUE;
            }

            dc.setColor(progressColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, barY, fillWidth, barHeight, 2);

            // Percentage (ensure it's inside the footer area)
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w - 14, footerTopY + 6, Graphics.FONT_TINY, completion + "%", Graphics.TEXT_JUSTIFY_RIGHT);
        } else {
            dc.setColor(0x404040, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(12, footerTopY, w - 12, footerTopY);

            // Center it vertically within the footer so it's always visible
            dc.setColor(COLOR_TEXT_SECONDARY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w/2, footerTopY + (footerHeight/2), Graphics.FONT_TINY, "No active plan", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        return footerHeight;
    }

    function selectNext() as Void {
        selectedItem = (selectedItem + 1) % menuItems.size();
        WatchUi.requestUpdate();
    }

    function selectPrevious() as Void {
        selectedItem = (selectedItem - 1 + menuItems.size()) % menuItems.size();
        WatchUi.requestUpdate();
    }

    function selectItem() as Void {
        // NOTE: Avoid constructing each view twice (you were doing new View() for the delegate too).
        if (selectedItem == ITEM_START_WORKOUT) {
            var v = new WorkoutListView(app);
            WatchUi.pushView(v, new WorkoutListDelegate(v), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_VIEW_PLAN) {
            var v2 = new PlanView(app);
            WatchUi.pushView(v2, new PlanDelegate(v2), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_PROGRESS) {
            var v3 = new ProgressView(app);
            WatchUi.pushView(v3, new ProgressDelegate(v3), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_SETTINGS) {
            var v4 = new SettingsView(app);
            WatchUi.pushView(v4, new SettingsDelegate(v4), WatchUi.SLIDE_LEFT);
        }
    }
}