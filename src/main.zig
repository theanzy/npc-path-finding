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
    const GameState = enum {
        idle,
        moving,
    };
    var game_state: GameState = GameState.idle;
    var npc_moveindex: usize = 0;

    var g = graph.Graph.init(allocator);
    defer g.deinit();
    try g.addConnection(
        rl.Vector2.init(155, 128),
        rl.Vector2.init(172, 373),
    );
    try g.addConnection(
        rl.Vector2.init(172, 373),
        rl.Vector2.init(155, 128),
    );
    try g.addConnection(
        rl.Vector2.init(172, 373),
        rl.Vector2.init(232, 634),
    );
    try g.addConnection(
        rl.Vector2.init(172, 373),
        rl.Vector2.init(538, 361),
    );
    try g.addConnection(
        rl.Vector2.init(538, 361),
        rl.Vector2.init(172, 373),
    );
    try g.addConnection(
        rl.Vector2.init(538, 361),
        rl.Vector2.init(545, 98),
    );
    try g.addConnection(
        rl.Vector2.init(545, 98),
        rl.Vector2.init(538, 361),
    );
    try g.addConnection(
        rl.Vector2.init(545, 98),
        rl.Vector2.init(789, 107),
    );
    try g.addConnection(
        rl.Vector2.init(789, 107),
        rl.Vector2.init(545, 98),
    );
    try g.addConnection(
        rl.Vector2.init(789, 107),
        rl.Vector2.init(804, 375),
    );
    try g.addConnection(
        rl.Vector2.init(789, 107),
        rl.Vector2.init(1760, 128),
    );
    try g.addConnection(
        rl.Vector2.init(804, 375),
        rl.Vector2.init(789, 107),
    );
    try g.addConnection(
        rl.Vector2.init(804, 375),
        rl.Vector2.init(1165, 400),
    );
    try g.addConnection(
        rl.Vector2.init(1760, 128),
        rl.Vector2.init(789, 107),
    );
    try g.addConnection(
        rl.Vector2.init(1760, 128),
        rl.Vector2.init(1757, 647),
    );
    try g.addConnection(
        rl.Vector2.init(1165, 400),
        rl.Vector2.init(804, 375),
    );
    try g.addConnection(
        rl.Vector2.init(1165, 400),
        rl.Vector2.init(1117, 623),
    );
    try g.addConnection(
        rl.Vector2.init(1757, 647),
        rl.Vector2.init(1117, 623),
    );
    try g.addConnection(
        rl.Vector2.init(1757, 647),
        rl.Vector2.init(1551, 917),
    );
    try g.addConnection(
        rl.Vector2.init(1117, 623),
        rl.Vector2.init(1757, 647),
    );
    try g.addConnection(
        rl.Vector2.init(1117, 623),
        rl.Vector2.init(557, 632),
    );
    try g.addConnection(
        rl.Vector2.init(1117, 623),
        rl.Vector2.init(1165, 400),
    );
    try g.addConnection(
        rl.Vector2.init(1551, 917),
        rl.Vector2.init(1757, 647),
    );
    try g.addConnection(
        rl.Vector2.init(1551, 917),
        rl.Vector2.init(550, 903),
    );
    try g.addConnection(
        rl.Vector2.init(550, 903),
        rl.Vector2.init(557, 632),
    );
    try g.addConnection(
        rl.Vector2.init(550, 903),
        rl.Vector2.init(1551, 917),
    );
    try g.addConnection(
        rl.Vector2.init(557, 632),
        rl.Vector2.init(1117, 623),
    );
    try g.addConnection(
        rl.Vector2.init(557, 632),
        rl.Vector2.init(550, 903),
    );
    try g.addConnection(
        rl.Vector2.init(557, 632),
        rl.Vector2.init(232, 634),
    );
    try g.addConnection(
        rl.Vector2.init(232, 634),
        rl.Vector2.init(557, 632),
    );
    try g.addConnection(
        rl.Vector2.init(232, 634),
        rl.Vector2.init(172, 373),
    );
    try g.calculateDistance();

    var shortest_path: ?std.ArrayList(rl.Vector2) = null;
    defer if (shortest_path != null) shortest_path.?.deinit();

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
        switch (game_state) {
            GameState.idle => {
                if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
                    mousepos = rl.getMousePosition();
                    pin_rect.x = mousepos.?.x;
                    pin_rect.y = mousepos.?.y;

                    std.debug.print("mouse.point ({d},{d})\n", .{ mousepos.?.x, mousepos.?.y });

                    const start_point = graphFindNearestPoint(&g, rl.Vector2.init(npc_rect.x, npc_rect.y), &blocks, false);
                    const end_point = graphFindNearestPoint(&g, rl.Vector2.init(pin_rect.x, pin_rect.y), &blocks, true);
                    if (start_point != null and end_point != null) {
                        if (shortest_path != null) {
                            shortest_path.?.deinit();
                        }
                        shortest_path = try g.getShortestPath(allocator, start_point.?, end_point.?);
                        if (shortest_path.?.items.len == 0) {
                            shortest_path.?.deinit();
                            shortest_path = null;
                        } else {
                            if (shortest_path.?.items[shortest_path.?.items.len - 1].equals(mousepos.?) != 1) {
                                try shortest_path.?.append(mousepos.?);
                            }
                            game_state = GameState.moving;
                            npc_moveindex = 0;
                        }
                    }
                } else if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_right)) {
                    mousepos = null;
                }
            },
            GameState.moving => {
                const dt = rl.getFrameTime();
                // npc_move_index
                npc_rect.x += npc_direction.x * 400 * dt;
                npc_rect.y += npc_direction.y * 400 * dt;
                const npc_center = rl.Vector2.init(npc_rect.x, npc_rect.y);
                if (npc_direction.x == 0 and npc_direction.y == 0) {
                    std.debug.print("start move\n", .{});
                    const dest_point = shortest_path.?.items[npc_moveindex];
                    npc_direction = dest_point.subtract(npc_center).normalize();

                    const radian = std.math.atan2(mousepos.?.y - npc_center.y, mousepos.?.x - npc_center.x);
                    const degree = radian * std.math.deg_per_rad;
                    npc_rotation = degree;
                } else {
                    const dest_point = shortest_path.?.items[npc_moveindex];
                    if (dest_point.distance(npc_center) < 30) {
                        std.debug.print("reach point {d} / {d}\n", .{ npc_moveindex, shortest_path.?.items.len - 1 });

                        npc_moveindex += 1;
                        if (npc_moveindex >= shortest_path.?.items.len) {
                            std.debug.print("end walking\n", .{});

                            npc_moveindex = 0;
                            game_state = GameState.idle;
                            npc_direction = rl.Vector2.init(0, 0);
                        } else {
                            npc_direction = rl.Vector2.init(0, 0);
                        }
                    }
                }
            },
        }

        // draw
        rl.beginDrawing();
        rl.clearBackground(rl.Color.dark_gray);
        for (blocks) |block| {
            rl.drawRectangleRec(block, rl.Color.dark_purple);
        }
        var nodeIter = g.valueIter();

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

fn graphFindNearestPoint(g: *graph.Graph, origin: rl.Vector2, obstacles: []const rl.Rectangle, is_ending: bool) ?rl.Vector2 {
    var iter = g.valueIter();
    var nearest_point: ?rl.Vector2 = null;
    var min_distance = std.math.inf(f32);
    while (iter.next()) |value| {
        const dir = if (is_ending) origin.subtract(value.point) else value.point.subtract(origin);
        const view_point = if (is_ending) value.point else origin;
        const is_insight = for (obstacles) |obstacle| {
            if (rayIntersectRect(view_point, dir, obstacle)) {
                break false;
            }
        } else true;
        // std.debug.print("({d},{d}) -> ({d},{d}) is_insight = {}\n", .{ origin.x, origin.y, value.point.x, value.point.y, is_insight });
        const distance = value.point.distance(origin);
        if (distance < min_distance and is_insight) {
            min_distance = distance;
            nearest_point = value.point;
        }
    }
    if (nearest_point != null) {
        std.debug.print("nearest_point ({d},{d})\n", .{ nearest_point.?.x, nearest_point.?.y });
    } else {
        std.debug.print("nearest_point is null\n", .{});
    }
    return nearest_point;
}

// intersection using the slab method
// https://tavianator.com/2011/ray_box.html#:~:text=The%20fastest%20method%20for%20performing,remains%2C%20it%20intersected%20the%20box.
fn rayIntersectRect(origin: rl.Vector2, direction: rl.Vector2, rect: rl.Rectangle) bool {
    var tmin = -std.math.inf(f32);
    var tmax = std.math.inf(f32);

    if (direction.x != 0.0) {
        const tx1 = (rect.x - origin.x) / direction.x;
        const tx2 = ((rect.x + rect.width) - origin.x) / direction.x;

        tmin = @max(tmin, @min(tx1, tx2));
        tmax = @min(tmax, @max(tx1, tx2));
    }

    if (direction.y != 0.0) {
        const ty1 = (rect.y - origin.y) / direction.y;
        const ty2 = ((rect.y + rect.height) - origin.y) / direction.y;

        tmin = @max(tmin, @min(ty1, ty2));
        tmax = @min(tmax, @max(ty1, ty2));
    }

    // if maxParam < 0, ray is intersecting AABB, but the whole AABB is behind us
    if (tmax < 0) {
        return false;
    }

    // if minParam > maxParam, ray doesn't intersect AABB
    if (tmin > tmax) {
        return false;
    }

    return true;
}
