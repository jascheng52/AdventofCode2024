const std = @import("std");
const print = std.debug.print;

pub fn main() !void 
{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();

    const argInput = args.next();
    const inputFile: []const u8 = argInput orelse {
        std.debug.print("Missing File Arg \n", .{});
        return;
    };

    const fileBuf = readFileToBuffer(allocator, inputFile) catch |err|
    {
        print("Failed to read file: {}", .{err});
        std.process.exit(0);
    };
    defer allocator.free(fileBuf);

    // print("Read :{s} type: {}\n", .{fileBuf, @TypeOf(fileBuf)});
    
    // print("Total: {any}\n", .{findMul(fileBuf)});
    print("Total: {any}\n", .{findMulP2(fileBuf)});

    
}

//Caller frees return val
pub fn readFileToBuffer(allocator : std.mem.Allocator, fileName : []const u8) ![]u8
{
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    const stat  = try file.stat();
    const buffer = try file.readToEndAlloc(allocator,stat.size);
    return buffer;
}


pub fn findMul(input : []const u8) !i32
{
    var split  = std.mem.splitAny(u8 ,input, "\n");
    
    var total : i32 = 0;
    while (split.next()) |word|
    {
        print("word : {s}\n", .{word});
        var first : i32 = 0;
        var second : i32 = 0;
        const start = word[4..word.len];
        var commaSplit  = std.mem.splitAny(u8 ,start, ",");
        const firstStr = commaSplit.next() orelse "" ;
        first = try std.fmt.parseInt(i32, firstStr, 10);

        const secondPart = commaSplit.next() orelse "";
        var secondParen = std.mem.splitAny(u8 ,secondPart, ")");
        const secondStr = secondParen.next() orelse "";
        second = try std.fmt.parseInt(i32, secondStr, 10);

        total = total + first * second;
    }
    
    return total;
}

pub fn findMulP2(input : []const u8) !i32
{
    var split  = std.mem.splitAny(u8 ,input, "\n");
    
    var total : i32 = 0;
    var canMul: bool = true;
    while (split.next()) |word|
    {
        print("word : {s}\n", .{word});
        var isMul: bool = false;
        switch (matchCase(word)) {
            0 => canMul = true,
            2 => canMul = false,
            1 => isMul = true,
            else => canMul = canMul
        }
        print("canMul : {any}\n", .{canMul});

        if(canMul and isMul)
        {
            var first : i32 = 0;
            var second : i32 = 0;
            const start = word[4..word.len];
            var commaSplit  = std.mem.splitAny(u8 ,start, ",");
            const firstStr = commaSplit.next() orelse "" ;
            first = try std.fmt.parseInt(i32, firstStr, 10);

            const secondPart = commaSplit.next() orelse "";
            var secondParen = std.mem.splitAny(u8 ,secondPart, ")");
            const secondStr = secondParen.next() orelse "";
            second = try std.fmt.parseInt(i32, secondStr, 10);

            total = total + first * second;
        }
    }
    
    return total;
}

pub fn matchCase(word: [] const u8) u32
{
    const dontString:[] const u8 = "don't()";
    const doString:[] const u8= "do()";

    if(std.mem.eql(u8, doString, word[0..4]))
        return 0;
    if(std.mem.eql(u8, dontString, word[0..7]))
        return 2;
    
    return 1;
}



