const std = @import("std");

const cwd = std.fs.cwd();

const alloc = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const expect = std.testing.expect;
pub fn main() void {

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    _ = args.skip();

    
    const inputFile: ?[:0]const u8 = args.next();
    const filePath = inputFile orelse {
        std.debug.print("Missing File arg", .{}) ;
        std.process.exit(0);};

    var file = cwd.openFile(filePath, .{}) catch |e| 
    {
        std.debug.print("Could not open {}\n", .{e});
        return;
    };
    defer file.close();

   

    const stat = file.stat() catch |e| {
            std.debug.print("Error {}\n", .{e});
            std.process.exit(0);
        };

    const buffer = file.readToEndAlloc(alloc, stat.size) catch |e| {
            std.debug.print("Error {}\n", .{e});
            std.process.exit(0);
        };
    defer alloc.free(buffer);

    var l1 = ArrayList(i32).init(alloc);
    var l2 = ArrayList(i32).init(alloc);
    defer l1.deinit();
    defer l2.deinit();


    var lines = std.mem.splitAny(u8, buffer,"\n");
    while (lines.next()) |line|
    {
        // std.debug.print("Read {s}\n", .{line});
        var numbers = std.mem.splitAny(u8, line," ");
        const n1S = numbers.next() orelse {std.debug.print("Invalid File", .{}); return;};
        _ = numbers.next();
        _ = numbers.next();
        const n2S = numbers.next() orelse {std.debug.print("Invalid File", .{}); return;};

        
        const n1 :i32 = std.fmt.parseInt(i32,n1S,10) catch |e| {
            std.debug.print("Failed to parse {s}, error {}\n", .{n1S,e});        
            std.process.exit(0);
        };
        const n2 :i32 = std.fmt.parseInt(i32,n2S,10) catch |e| {
            std.debug.print("Failed to parse {s}, error {}\n", .{n2S,e});
            std.process.exit(0);        
        };


        l1.append(n1) catch {
            std.debug.print("Failed to add l1\n", .{});
            std.process.exit(0);        
        };
        l2.append(n2) catch {
            std.debug.print("Failed to add l2\n", .{});
            std.process.exit(0);        
        };
    }

    std.mem.sort(i32, l1.items,{}, std.sort.asc(i32));
    std.mem.sort(i32, l2.items,{}, std.sort.asc(i32));

    var sum:u32 = 0;
    for (l1.items, 0..) |num1, i| 
    {
        const num2 = l2.items[i];
        const diff = num1 - num2;
        sum += @abs(diff);
    }

    std.debug.print("Success {d}\n", .{sum}) ;
}

