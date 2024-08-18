const rl = @import("raylib");
const std = @import("std");
const graph = @import("./graph.zig");

pub fn main() !void {
    const TILE_SIZE: i32 = 64;
    const ROWS: i32 = 15;
    const COLS: i32 = 30;
    const SCREEN_HEIGHT: i32 = ROWS * TILE_SIZE;
    const SCREEN_WIDTH: i32 = COLS * TILE_SIZE;

    const allocator = std.heap.page_allocator;
    var mousepos: ?rl.Vector2 = null;
    const blocks = [_]rl.Rectangle{
        rl.Rectangle.init(330, 0, 80, 250),
        rl.Rectangle.init(330, 450, 700, 80),
        rl.Rectangle.init(600, 160, 80, 350),
        rl.Rectangle.init(330, 700, 80, 500),
        rl.Rectangle.init(650, 700, 800, 80),
        rl.Rectangle.init(900, 230, 800, 80),
        rl.Rectangle.init(1250, 450, 250, 80),
    };

    var points = graph.Graph.init(allocator);
    defer points.deinit();
    try points.addConnection(
        rl.Vector2.init(155, 128),
        rl.Vector2.init(172, 373),
    );
    try points.addConnection(
        rl.Vector2.init(172, 373),
        rl.Vector2.init(155, 128),
    );
    try points.addConnection(
        rl.Vector2.init(172, 373),
        rl.Vector2.init(232, 634),
    );
    try points.addConnection(
        rl.Vector2.init(172, 373),
        rl.Vector2.init(538, 361),
    );
    try points.addConnection(
        rl.Vector2.init(538, 361),
        rl.Vector2.init(172, 373),
    );
    try points.addConnection(
        rl.Vector2.init(538, 361),
        rl.Vector2.init(545, 98),
    );
    try points.addConnection(
        rl.Vector2.init(545, 98),
        rl.Vector2.init(538, 361),
    );
    try points.addConnection(
        rl.Vector2.init(545, 98),
        rl.Vector2.init(789, 107),
    );
    try points.addConnection(
        rl.Vector2.init(789, 107),
        rl.Vector2.init(545, 98),
    );
    try points.addConnection(
        rl.Vector2.init(789, 107),
        rl.Vector2.init(804, 375),
    );
    try points.addConnection(
        rl.Vector2.init(789, 107),
        rl.Vector2.init(1760, 128),
    );
    try points.addConnection(
        rl.Vector2.init(804, 375),
        rl.Vector2.init(789, 107),
    );
    try points.addConnection(
        rl.Vector2.init(804, 375),
        rl.Vector2.init(1165, 400),
    );
    try points.addConnection(
        rl.Vector2.init(1760, 128),
        rl.Vector2.init(789, 107),
    );
    try points.addConnection(
        rl.Vector2.init(1760, 128),
        rl.Vector2.init(1757, 647),
    );
    try points.addConnection(
        rl.Vector2.init(1165, 400),
        rl.Vector2.init(804, 375),
    );
    try points.addConnection(
        rl.Vector2.init(1165, 400),
        rl.Vector2.init(1117, 623),
    );
    try points.addConnection(
        rl.Vector2.init(1757, 647),
        rl.Vector2.init(1117, 623),
    );
    try points.addConnection(
        rl.Vector2.init(1757, 647),
        rl.Vector2.init(1551, 917),
    );
    try points.addConnection(
        rl.Vector2.init(1117, 623),
        rl.Vector2.init(1757, 647),
    );
    try points.addConnection(
        rl.Vector2.init(1117, 623),
        rl.Vector2.init(557, 632),
    );
    try points.addConnection(
        rl.Vector2.init(1117, 623),
        rl.Vector2.init(1165, 400),
    );
    try points.addConnection(
        rl.Vector2.init(1551, 917),
        rl.Vector2.init(1757, 647),
    );
    try points.addConnection(
        rl.Vector2.init(1551, 917),
        rl.Vector2.init(550, 903),
    );
    try points.addConnection(
        rl.Vector2.init(550, 903),
        rl.Vector2.init(557, 632),
    );
    try points.addConnection(
        rl.Vector2.init(550, 903),
        rl.Vector2.init(1551, 917),
    );
    try points.addConnection(
        rl.Vector2.init(557, 632),
        rl.Vector2.init(1117, 623),
    );
    try points.addConnection(
        rl.Vector2.init(557, 632),
        rl.Vector2.init(550, 903),
    );
    try points.addConnection(
        rl.Vector2.init(557, 632),
        rl.Vector2.init(232, 634),
    );
    try points.addConnection(
        rl.Vector2.init(232, 634),
        rl.Vector2.init(557, 632),
    );
    try points.addConnection(
        rl.Vector2.init(232, 634),
        rl.Vector2.init(172, 373),
    );
    try points.calculateDistance();

    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "path fiding");
    defer rl.closeWindow();
    // assets
    const tex_npc = rl.loadTexture("assets/sprites/npc/green/rifle/idle/npc-idle-rifle-00.png");
    defer rl.unloadTexture(tex_npc);

    const npc_source_rect = rl.Rectangle.init(0, 0, @as(f32, @floatFromInt(tex_npc.width)), @as(f32, @floatFromInt(tex_npc.height)));
    var npc_rect = rl.Rectangle.init(160, 200, npc_source_rect.width / 2, npc_source_rect.height / 2);
    const npc_origin = rl.Vector2.init(npc_rect.width / 2, npc_rect.height / 2);
    var npc_rotation: f32 = 0.0;
    var npc_direction = rl.Vector2.init(0, 0);

    const tex_pin = rl.loadTexture("assets/images/location.png");
    defer rl.unloadTexture(tex_pin);
    const pin_source_rect = rl.Rectangle.init(0, 0, @as(f32, @floatFromInt(tex_pin.width)), @as(f32, @floatFromInt(tex_pin.height)));
    var pin_rect = rl.Rectangle.init(0, 0, pin_source_rect.width / 4, pin_source_rect.height / 4);
    const pin_origin = rl.Vector2.init(pin_rect.width / 2, pin_rect.height);

    const tex_node = rl.loadTexture("assets/images/location-dark.png");
    defer rl.unloadTexture(tex_node);

    // collision blocks
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        // update
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            mousepos = rl.getMousePosition();
            pin_rect.x = mousepos.?.x;
            pin_rect.y = mousepos.?.y;
            const npc_center = rl.Vector2.init(npc_rect.x, npc_rect.y);

            const radian = std.math.atan2(mousepos.?.y - npc_center.y, mousepos.?.x - npc_center.x);
            const degree = radian * std.math.deg_per_rad;
            npc_rotation = degree;
            npc_direction = mousepos.?.subtract(npc_center).normalize();
            std.debug.print("mouse.point ({d},{d})\n", .{ mousepos.?.x, mousepos.?.y });
        } else if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_right)) {
            mousepos = null;
        }

        const dt = rl.getFrameTime();
        npc_rect.x += npc_direction.x * 400 * dt;
        npc_rect.y += npc_direction.y * 400 * dt;

        if (mousepos != null and mousepos.?.distance(rl.Vector2{ .x = npc_rect.x, .y = npc_rect.y }) < 5) {
            npc_direction = rl.Vector2.zero();
        }

        // draw
        rl.beginDrawing();
        rl.clearBackground(rl.Color.dark_gray);
        for (blocks) |block| {
            rl.drawRectangleRec(block, rl.Color.dark_purple);
        }
        var nodeIter = points.valueIter();

        while (nodeIter.next()) |node| {
            const point = node.point;

            const neighbors = node.neighbors;
            for (neighbors.items) |neighbor| {
                rl.drawLineEx(point, neighbor, 1, rl.Color.light_gray);
            }

            const x = point.x - @as(f32, @floatFromInt(tex_node.width)) / 2;
            const y = point.y - @as(f32, @floatFromInt(tex_node.height));
            const vec = rl.Vector2.init(x, y);
            rl.drawTextureV(tex_node, vec, rl.Color.gray);
            const text = rl.textFormat("(%.02f, %.02f)", .{ point.x, point.y });
            rl.drawText(text, @as(i32, @intFromFloat(x)) - 50, @as(i32, @intFromFloat(y)) + 60, 20, rl.Color.white);
        }

        rl.drawTexturePro(tex_npc, npc_source_rect, npc_rect, npc_origin, npc_rotation, rl.Color.gray);
        if (mousepos != null) {
            rl.drawTexturePro(tex_pin, pin_source_rect, pin_rect, pin_origin, 0, rl.Color.gray);
        }

        rl.endDrawing();
    }
}
