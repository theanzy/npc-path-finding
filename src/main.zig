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

    const source_rect = rl.Rectangle.init(0, 0, @as(f32, @floatFromInt(tex_npc.width)), @as(f32, @floatFromInt(tex_npc.height)));
    const dest_rect = rl.Rectangle.init(160, 200, source_rect.width / 2, source_rect.height / 2);
    const npc_origin = rl.Vector2.init(dest_rect.width / 2, dest_rect.height / 2);
    const npc_rotation = 0;

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        // update

        // draw
        rl.beginDrawing();
        rl.clearBackground(rl.Color.dark_gray);
        rl.drawTexturePro(tex_npc, source_rect, dest_rect, npc_origin, npc_rotation, rl.Color.gray);

        rl.endDrawing();
    }
}
