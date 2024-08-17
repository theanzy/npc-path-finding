const rl = @import("raylib");
const std = @import("std");

pub fn main() !void {
    const SCREEN_HEIGHT: i32 = 450;
    const SCREEN_WIDTH: i32 = 800;

    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "path fiding");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        // update
        // draw
        rl.beginDrawing();
        rl.clearBackground(rl.Color.ray_white);
        rl.drawText("Congrats", 190, 200, 20, rl.Color.light_gray);

        rl.endDrawing();
    }
}
