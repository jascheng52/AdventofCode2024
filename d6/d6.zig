const std = @import("std");
const print = std.debug.print;

const Mark = enum { BLANK, VISITED, BLOCK, GUARD };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer print("{}\n", .{gpa.deinit()});

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();

    const argInput: []const u8 = args.next() orelse {
        print("Expected file argument\n", .{});
        std.process.exit(0);
    };

    const fileBuff = readFileToBuffer(allocator, argInput) catch |err| {
        print("{}\n", .{err});
        std.process.exit(std.process.exit(0));
    };
    defer allocator.free(fileBuff);

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arenaAllocator = arena.allocator();

    var grid = parseMap(fileBuff, arenaAllocator) catch |err| {
        print("{}\n", .{err});
        std.process.exit(std.process.exit(0));
    };

    _ = try walkGuard(&grid);
    print("Count: {d}\n", .{countX(grid)});
}

pub fn readFileToBuffer(allocator: std.mem.Allocator, fileName: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    const stat = try file.stat();
    const buffer = try file.readToEndAlloc(allocator, stat.size);
    return buffer;
}

//free each item as well
pub fn parseMap(fileBuff: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]u8) {
    var lineIter = std.mem.splitAny(u8, fileBuff, "\n");
    var grid = std.ArrayList([]u8).init(allocator);

    while (lineIter.next()) |line| {
        var mutLine: []u8 = try allocator.alloc(u8, line.len);
        _ = &mutLine;
        std.mem.copyForwards(u8, mutLine, line);
        try grid.append(mutLine);
        for (line) |char| {
            _ = char;
            // print("{c}\n", .{char});
        }
    }

    return grid;
}

pub fn walkGuard(grid: *std.ArrayList([]u8)) !void {
    var guardPos = try getGuardPos(grid);
    _ = &guardPos;

    while (inBounds(guardPos.x, guardPos.y, grid.*)) {
        printGrid(grid.*);
        print("------------\n", .{});
        // print("{d},{d},{}\n", .{guardPos.x,guardPos.y, guardPos.dir});

        var xdir: i32 = 0;
        var ydir: i32 = 0;

        switch (guardPos.dir) {
            DIR_ENUM.UP => {
                xdir = -1;
                ydir = 0;
            },
            DIR_ENUM.RIGHT => {
                xdir = 0;
                ydir = 1;
            },
            DIR_ENUM.DOWN => {
                xdir = 1;
                ydir = 0;
            },
            DIR_ENUM.LEFT => {
                xdir = 0;
                ydir = -1;
            },
        }

        const spaceFront_X = guardPos.x + xdir;
        const spaceFront_Y = guardPos.y + ydir;
        if (inBounds(spaceFront_X, spaceFront_Y, grid.*)) {
            const space_Xindex = @abs(spaceFront_X);
            const space_Yindex = @abs(spaceFront_Y);
            const charFront = grid.items[space_Xindex][space_Yindex];
            switch (charFront) {
                '#' => {
                    switch (guardPos.dir) {
                        DIR_ENUM.UP => guardPos.dir = DIR_ENUM.RIGHT,
                        DIR_ENUM.RIGHT => guardPos.dir = DIR_ENUM.DOWN,
                        DIR_ENUM.DOWN => guardPos.dir = DIR_ENUM.LEFT,
                        DIR_ENUM.LEFT => guardPos.dir = DIR_ENUM.UP,
                    }
                    continue;
                },
                '.', 'X' => {
                    switch (guardPos.dir) {
                        DIR_ENUM.UP => grid.items[space_Xindex][space_Yindex] = '^',
                        DIR_ENUM.RIGHT => grid.items[space_Xindex][space_Yindex] = '>',
                        DIR_ENUM.DOWN => grid.items[space_Xindex][space_Yindex] = 'v',
                        DIR_ENUM.LEFT => grid.items[space_Xindex][space_Yindex] = '<',
                    }
                },
                else => return,
            }
        }
        grid.items[@abs(guardPos.x)][@abs(guardPos.y)] = 'X';
        guardPos.x = spaceFront_X;
        guardPos.y = spaceFront_Y;
    }
    printGrid(grid.*);

}

const GuardInit = struct { x: i32, y: i32, dir: DIR_ENUM };
const DIR_ENUM = enum { UP, LEFT, DOWN, RIGHT };
const ErrorGuard = error{NO_GUARD};
pub fn getGuardPos(grid: *std.ArrayList([]u8)) !GuardInit {
    for (0..grid.capacity) |i| {
        for (0..grid.items[i].len) |j| {
            const char = grid.items[i][j];
            switch (char) {
                '^' => return GuardInit{ .x = @intCast(i), .y = @intCast(j), .dir = DIR_ENUM.UP },
                '>' => return GuardInit{ .x = @intCast(i), .y = @intCast(j), .dir = DIR_ENUM.RIGHT },
                'v' => return GuardInit{ .x = @intCast(i), .y = @intCast(j), .dir = DIR_ENUM.DOWN },
                '<' => return GuardInit{ .x = @intCast(i), .y = @intCast(j), .dir = DIR_ENUM.LEFT },
                else => continue,
            }
        }
    }
    return ErrorGuard.NO_GUARD;
}

pub fn inBounds(x: i32, y: i32, grid: std.ArrayList([]u8)) bool 
{

    if (x >= 0 and x < grid.items.len) 
    {
        if (y >= 0 and y < grid.items[0].len) {
            return true;
        }
    }
    return false;
}

pub fn printGrid(grid: std.ArrayList([]u8)) void 
{
    for (grid.items) |line| {
        print("{s}\n", .{line});
    }
}

pub fn countX(grid: std.ArrayList([] u8)) usize
{
    var count :u32 = 0;
    for(grid.items) |row|
    {
        for(row) |c|
        {
            if(c == 'X')
            {
                count += 1;
            }
        }
    }
    return count;
}
