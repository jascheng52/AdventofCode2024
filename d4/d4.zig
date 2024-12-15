const std = @import("std");
const print = std.debug.print;

pub fn main() !void 
{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();

    const  argInput: []const u8 = args.next() orelse {
        print("Expected file argument\n", .{});
        std.process.exit(0);
    };

    const fileBuff = try readFileToBuffer(allocator, argInput);
    defer allocator.free(fileBuff);

    var fileIter = std.mem.splitAny(u8, fileBuff, "\n");
    
    const ArrayListGrid = std.ArrayList([] const u8);
    var grid = ArrayListGrid.init(allocator);
    defer grid.deinit();
    
    while (fileIter.next()) |line|
    {
        try grid.append(line);
    }
    
    
    const res = findXmas(grid.items);
    print("Result: {d}\n", .{res});

}


pub fn readFileToBuffer(allocator : std.mem.Allocator, fileName : []const u8) ![]u8
{
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    const stat  = try file.stat();
    const buffer = try file.readToEndAlloc(allocator,stat.size);
    return buffer;
}

pub fn findXmas(items : [][]const u8) u32
{
    const row = items.len;
    const col = items[0].len;

    var numXmas: u32 = 0;
    for(0..row) |i|
    {
        for(0..col) |j|
        {
            // print("--------------- Starting: {d},{d}\n", .{i,j});
            
            numXmas += isXmas(items, i, j ,row, col);
        }

    }

    return numXmas;
}

pub fn isXmas(items: [][] const u8, i: usize, j:usize, row: usize, col:usize) u32
{
    var res: u32 = 0;
    res += search(items, i, j, row, col, 0, 1) ;
    res += search(items, i, j, row, col, 1, 1) ;
    res += search(items, i, j, row, col, 1, 0) ;
    res += search(items, i, j, row, col, 1, -1) ;
    res += search(items, i, j, row, col, 0, -1) ;
    res += search(items, i, j, row, col, -1, -1) ;
    res += search(items, i, j, row, col, -1, 0) ;
    res += search(items, i, j, row, col, -1, 1) ;
    return res;
}

pub fn search(items: [][] const u8, i: usize, j:usize, row: usize, col:usize, iDir:i8, jDir:i8) u32
{
    var newI: i32 = @as(i32, @intCast(i)) ;
    var newJ: i32 = @as(i32, @intCast(j)) ;

    const XMAS:[]const u8 = "XMAS";

    for(XMAS) |char|
    {
        if(newI >= row or newI < 0)
            return 0;
        if(newJ >= col or newJ < 0)
            return 0;
        // print("At: {d}, {d} Char seen : {c}\n", .{newI,newJ, items[@abs(newI)][@abs(newJ)]});

        if(items[@abs(newI)][@abs(newJ)] != char)
            return 0;

        newI = newI + iDir;
        newJ = newJ + jDir;
    }
    print("Found Ending: {d}, {d}\n", .{newI - iDir,newJ-jDir});
    return 1;
}