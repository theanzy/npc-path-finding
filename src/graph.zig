const std = @import("std");
const rl = @import("raylib");

const Vector2HashContext = struct {
    pub fn hash(self: @This(), v: rl.Vector2) u64 {
        _ = self;
        var h = std.hash.XxHash3.init(0);
        var arr = [_]f32{ v.x, v.y };
        h.update(std.mem.sliceAsBytes(arr[0..]));
        return h.final();
    }

    pub fn eql(self: @This(), a: rl.Vector2, b: rl.Vector2) bool {
        _ = self;
        return a.equals(b) == 1;
    }
};

pub const Graph = struct {
    const Vector2List = std.ArrayList(rl.Vector2);
    const PointMap = std.HashMap(rl.Vector2, *Vector2List, Vector2HashContext, std.hash_map.default_max_load_percentage);
    _graphs: PointMap,
    arena: std.heap.ArenaAllocator,
    pub fn init(allocator: std.mem.Allocator) Graph {
        return Graph{
            .arena = std.heap.ArenaAllocator.init(allocator),
            ._graphs = PointMap.init(allocator),
        };
    }
    pub fn deinit(self: @This()) void {
        self.arena.deinit();
    }

    pub fn addNode(self: *@This(), point: rl.Vector2) !void {
        if (!self._graphs.contains(point)) {
            var arena = self.arena;
            var allocator = arena.allocator();
            const arr = try allocator.create(Vector2List);
            arr.* = Vector2List.init(allocator);
            try self._graphs.put(
                point,
                arr,
            );
        }
    }

    pub fn addConnection(self: *@This(), point: rl.Vector2, neighbor: rl.Vector2) !void {
        if (!self._graphs.contains(point)) {
            var arena = self.arena;
            var allocator = arena.allocator();
            var arr = try allocator.create(Vector2List);
            arr.* = Vector2List.init(allocator);
            arr.clearAndFree();
            try self._graphs.put(
                point,
                arr,
            );
        }
        var arr = self._graphs.get(point);
        std.debug.print("adding connection\n", .{});
        std.debug.assert(arr != null);
        try arr.?.append(neighbor);
    }

    pub fn getNeighbors(self: *@This(), point: rl.Vector2) ?*Vector2List {
        const arr = self._graphs.get(point);
        return arr;
    }

    pub fn keyIter(self: *@This()) @TypeOf(self._graphs.keyIterator()) {
        return self._graphs.keyIterator();
    }
    pub fn iter(self: *@This()) @TypeOf(self._graphs.iterator()) {
        return self._graphs.iterator();
    }
};
