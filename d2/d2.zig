const std = @import("std");

const ArrayList = std.ArrayList;

pub fn main() !void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    _ = args.skip();

    const argInput = args.next();
    const inputFile: [:0]const u8 = argInput orelse {
        std.debug.print("Missing File Arg \n", .{});
        return;
    };

    const inputFileRes: std.fs.File = std.fs.cwd().openFile(inputFile, .{}) catch |e| {
        std.debug.print("Error open file: {} \n", .{e});
        return;
    };
    defer inputFileRes.close();


    var lineBuff: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&lineBuff);
    const fbaAlloc = fba.allocator();
    const lineMem: []u8 = fbaAlloc.alloc(u8, 4096) catch |e| {
        std.debug.print("Error alloc line {}\n", .{e});
        std.process.exit(0);
    };

    var lineDelim: ?[]u8 = inputFileRes.reader().readUntilDelimiterOrEof(lineMem, '\n') catch |e| {
        std.debug.print("Error Parsing file {}\n", .{e});
        std.process.exit(0);
    };

    var numSuc: i32 = 0;
    while(lineDelim) |line|
    {
        var skipIndex: i32 = -1 ;
        while(skipIndex < line.len) 
        {
            if(verifyLine(line,skipIndex) )
            {
                numSuc += 1;
                std.debug.print("Line: {s} is {}\n", .{line, true});
                break;
            }
            skipIndex += 1;
        }
        //Uncomment for p1
        // if(verifyLine(line,-1) )
        // {
        //     numSuc += 1;
        //     std.debug.print("Line: {s} is {}\n", .{line, true});
        //     continue;
        // }
        // else {std.debug.print("Line: {s} is {}\n", .{line, false});
        // }
        lineDelim = inputFileRes.reader().readUntilDelimiterOrEof(lineMem, '\n') catch |e| {
            std.debug.print("Error Parsing file {}\n", .{e});
            std.process.exit(0);
        };
    }
    std.debug.print("Total:  {d}\n", .{numSuc});
}


pub fn verifyLine(line: []u8, skipIndex : i32) bool
{
    var lineSpliited = std.mem.splitAny(u8, line, " ");

    var prevNum : i32 = -1;
    var modifer: i32 = 0;
    var index: i32 = 0;
    while (lineSpliited.next()) |word| 
    {
        std.debug.print("Cur Word {s}, index: {d}\n", .{word,index});
        if(skipIndex == index)
        {
            index += 1;
            continue;
        }
        if (prevNum == -1) 
        {
            prevNum = std.fmt.parseInt(i32, word, 10) catch |e| {
                std.debug.print("Failed to parse {}", .{e});
                std.process.exit(0);
            };
            std.debug.print("Assigning init {s}\n", .{word});
            index += 1;
            continue;
        }
        const curNum = std.fmt.parseInt(i32, word, 10) catch |e| {
            std.debug.print("Failed to parse {}\n", .{e});
            std.process.exit(0);
        };
        if (prevNum == curNum)
                return false;
        if (modifer == 0) {
            
            if (prevNum > curNum){
                modifer = -1;
                std.debug.print("Assigned dec\n", .{});
            }
            else 
                modifer = 1;
        }
        const diff = (curNum - prevNum) * modifer;
        std.debug.print("Diff {d}\n", .{diff});
        if (diff < 0)
            return false;
        if (diff > 3)
            return false;
        prevNum = curNum;
        index += 1;

    }
    
    return true;
}

