const rl = @import("raylib");
const std = @import("std");

pub fn main() !void {
    const TILE_SIZE: i32 = 64;
    const ROWS: i32 = 15;
    const COLS: i32 = 30;
    const SCREEN_HEIGHT: i32 = ROWS * TILE_SIZE;
    const SCREEN_WIDTH: i32 = COLS * TILE_SIZE;

    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "path fiding");
    defer rl.closeWindow();

    const tex_npc = rl.loadTexture("assets/sprites/npc/green/rifle/idle/npc-idle-rifle-00.png");
    defer rl.unloadTexture(tex_npc);

    const npc_source_rect = rl.Rectangle.init(0, 0, @as(f32, @floatFromInt(tex_npc.width)), @as(f32, @floatFromInt(tex_npc.height)));
    const npc_rect = rl.Rectangle.init(160, 200, npc_source_rect.width / 2, npc_source_rect.height / 2);
    const npc_origin = rl.Vector2.init(npc_rect.width / 2, npc_rect.height / 2);
    const npc_rotation = 0;

    const tex_pin = rl.loadTexture("assets/images/location.png");
    defer rl.unloadTexture(tex_pin);
    const pin_source_rect = rl.Rectangle.init(0, 0, @as(f32, @floatFromInt(tex_pin.width)), @as(f32, @floatFromInt(tex_pin.height)));
    var pin_rect = rl.Rectangle.init(0, 0, pin_source_rect.width / 2, pin_source_rect.height / 2);
    const pin_origin = rl.Vector2.init(pin_rect.width / 2, pin_rect.height);

    var mousepos: ?rl.Vector2 = null;

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        // update
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            // const mousepos = rl.getMousePosition();
            mousepos = rl.getMousePosition();
            pin_rect.x = mousepos.?.x;
            pin_rect.y = mousepos.?.y;
        } else if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_right)) {
            mousepos = null;
        }

        // draw
        rl.beginDrawing();
        rl.clearBackground(rl.Color.dark_gray);
        rl.drawTexturePro(tex_npc, npc_source_rect, npc_rect, npc_origin, npc_rotation, rl.Color.gray);
        if (mousepos != null) {
            rl.drawTexturePro(tex_pin, pin_source_rect, pin_rect, pin_origin, 0, rl.Color.gray);
        }

        rl.endDrawing();
    }
}
