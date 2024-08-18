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

fn Vector2HashMap(comptime V: type) type {
    return std.HashMap(rl.Vector2, V, Vector2HashContext, std.hash_map.default_max_load_percentage);
}

pub const Graph = struct {
    const Vector2List = std.ArrayList(rl.Vector2);
    const PointMap = Vector2HashMap(GraphNode);
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

    pub fn addConnection(self: *@This(), point: rl.Vector2, neighbor: rl.Vector2) !void {
        if (!self._graphs.contains(point)) {
            var arena = self.arena;
            // const node = try arena.allocator().create(GraphNode);
            // node.* = GraphNode.init(arena.allocator(), point);
            try self._graphs.put(
                point,
                GraphNode.init(arena.allocator(), point),
            );
        }
        var node = self._graphs.getPtr(point);
        try node.?.addNeighbor(neighbor);
        // try node.?.addNeighbor(neighbor);
    }

    pub fn valueIter(self: *@This()) @TypeOf(self._graphs.valueIterator()) {
        return self._graphs.valueIterator();
    }

    pub fn calculateDistance(self: *@This()) !void {
        var valIter = self._graphs.valueIterator();
        while (valIter.next()) |val| {
            try val.calculateDistance();
        }
    }

    pub fn getShortestPath(self: *@This(), start: rl.Vector2, end: rl.Vector2) !std.ArrayList(rl.Vector2) {
        var arena = self.arena;
        var result = std.ArrayList(rl.Vector2).init(arena.allocator());
        if (!self._graphs.contains(start) or !self._graphs.contains(end)) {
            return result;
        }
        var costs = Vector2HashMap(f32).init(arena.allocator());
        defer costs.deinit();
        var keyIter = self._graphs.keyIterator();
        while (keyIter.next()) |point| {
            const p = point.*;
            try costs.put(p, std.math.inf(f32));
        }
        try costs.put(start, 0);

        const end_node = self._graphs.get(end);
        std.debug.assert(end_node != null);

        var current_node = self._graphs.get(start);
        std.debug.assert(current_node != null);

        var visited = Vector2HashMap(bool).init(arena.allocator());
        defer visited.deinit();

        var prev_nodes = Vector2HashMap(rl.Vector2).init(arena.allocator());
        defer prev_nodes.deinit();

        while (current_node != null and current_node.?.point.equals(end) != 1) {
            // compute costs of neighbors
            for (current_node.?.neighbors.items) |neighbor_point| {
                if (visited.contains(neighbor_point)) {
                    continue;
                }
                if (neighbor_point.equals(end) == 1) {
                    try prev_nodes.put(neighbor_point, current_node.?.point);
                    current_node = end_node;
                    break;
                }
                const distance: ?f32 = current_node.?.distances.get(neighbor_point);
                std.debug.assert(distance != null);
                const heuristics = end_node.?.point.distance(neighbor_point);
                const current_node_cost: ?f32 = costs.get(current_node.?.point);
                const new_cost = current_node_cost.? + heuristics + distance.?;
                const neighbor_cost: ?f32 = costs.get(neighbor_point);
                if (new_cost < neighbor_cost.?) {
                    try costs.put(neighbor_point, new_cost);
                    try prev_nodes.put(neighbor_point, current_node.?.point);
                }
            }
            if (current_node.?.point.equals(end) == 1) {
                break;
            }

            try visited.put(current_node.?.point, true);
            current_node = if (findLowestCost(&costs, &visited)) |point| self._graphs.get(point) else null;
        }
        try result.append(end);

        if (!prev_nodes.contains(end)) {
            result.clearAndFree();
            return result;
        }

        while (result.items[0].equals(start) != 1) {
            const first_item = result.items[0];
            const point = prev_nodes.get(first_item);
            if (point == null) {
                result.clearAndFree();
                return result;
            }
            try result.insert(0, point.?);
        }
        return result;
    }
};

fn findLowestCost(costs: *const Vector2HashMap(f32), visited: *const Vector2HashMap(bool)) ?rl.Vector2 {
    var lowest_cost: f32 = std.math.inf(f32);
    var lowest_cost_point: ?rl.Vector2 = null;

    var costIter = costs.iterator();
    while (costIter.next()) |entry| {
        const point = entry.key_ptr;
        const cost: f32 = entry.value_ptr.*;
        if (visited.contains(point.*)) {
            continue;
        }
        if (cost < lowest_cost) {
            lowest_cost_point = point.*;
            lowest_cost = cost;
        }
    }
    return lowest_cost_point;
}

const GraphNode = struct {
    const DistanceMap = std.HashMap(rl.Vector2, f32, Vector2HashContext, std.hash_map.default_max_load_percentage);
    point: rl.Vector2,
    neighbors: std.ArrayList(rl.Vector2),
    distances: DistanceMap,

    pub fn init(allocator: std.mem.Allocator, p: rl.Vector2) GraphNode {
        return GraphNode{
            .point = p,
            .neighbors = std.ArrayList(rl.Vector2).init(allocator),
            .distances = DistanceMap.init(allocator),
        };
    }
    pub fn deinit(self: *@This()) void {
        self.neighbors.deinit();
    }

    pub fn addNeighbor(self: *@This(), neighbor: rl.Vector2) !void {
        try self.neighbors.append(neighbor);
    }

    pub fn calculateDistance(self: *@This()) !void {
        for (self.neighbors.items) |neighbor| {
            try self.distances.put(neighbor, neighbor.distance(self.point));
        }
    }
};
