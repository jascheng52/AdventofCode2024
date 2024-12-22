
const std = @import("std");
const print = std.debug.print;

const NumPair = struct 
{
    firstNum: i32,
    secondNum: i32,
    secAppear: bool
};

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
    print("{}\n", .{@TypeOf(fileIter)});
    _ = &fileIter;

    const PairList = std.ArrayList(NumPair);
    var pairsList = PairList.init(allocator);
    defer pairsList.deinit();

    try getPairs(&fileIter, &pairsList);
    for(pairsList.items) |item|
    {
        print("{d},{d}\n",  .{item.firstNum, item.secondNum});
    }

    const res =try findMiddle(pairsList, &fileIter, allocator);
    print("{d}\n",  .{res});

}



pub fn readFileToBuffer(allocator : std.mem.Allocator, fileName : []const u8) ![]u8
{
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    const stat  = try file.stat();
    const buffer = try file.readToEndAlloc(allocator,stat.size);
    return buffer;
}

pub fn  getPairs(splitIter: *std.mem.SplitIterator(u8,.any), list: *std.ArrayList(NumPair) ) !void
{
    while (splitIter.next()) |line|
    {
        if(std.mem.eql(u8, line, ""))
            return;

        var numP = std.mem.splitAny(u8, line, "|");
        const n1Str :  []const u8 = numP.next() orelse return;
        const n2Str :  [] const u8 = numP.next() orelse return;
        _=&n1Str;
        _=&n2Str;

        const pair = NumPair {
            .firstNum = try std.fmt.parseInt(i32, n1Str, 10), 
            .secondNum = try std.fmt.parseInt(i32, n2Str, 10), 
            .secAppear = false
        };
        try list.append(pair);

    }
}

pub fn findMiddle(pairsList: std.ArrayList(NumPair), 
        splitIter: *std.mem.SplitIterator(u8,.any), allocator: std.mem.Allocator) !i32
{
    const NumsList = std.ArrayList(i32);
    var total:i32 = 0;
    while(splitIter.next()) |line|
    {
        var comSplit = std.mem.splitAny(u8, line, ",");
        var numList = NumsList.init(allocator);
        defer numList.deinit();

        while(comSplit.next()) |numStr|
        {
            try numList.append(try std.fmt.parseInt(i32, numStr, 10));
        }

        var valid = false;
        
        const pairsListCopy = try pairsList.clone();
                    print("-----------------\n",  .{});

        for(numList.items) |item|
        {
            print("{d},",  .{item});
            valid = validateNum(item, &pairsListCopy);
            if(!valid)
                break;
        }
        print("\n",  .{});
        print("res: {}\n", .{valid});
        if(valid)
        {
            const mid: i32 = numList.items[numList.items.len / 2];

            print("valid\n",  .{});
            total += mid;

        }
    }

    return total;


}


pub fn validateNum(num:i32, pairsList: *const std.ArrayList(NumPair)) bool
{
    for(pairsList.items,0..pairsList.items.len) |pair, i|
    {
        if(pair.secondNum == num)
        {
            const pairRef = &pairsList.items[i];
            pairRef.secAppear = true;
        }
        if(pair.firstNum == num)
        {
            print("{},",  .{pair.secAppear});
            if(pair.secAppear)
            {
                print("exit,",  .{});
                return false;
            }
        }
    }
    return true;
}
