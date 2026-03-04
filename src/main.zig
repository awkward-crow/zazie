// main.zig

const std = @import("std");

pub fn main() !void 
{

    // setup stdout writer
    var output_buf: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&output_buf);
    const stdout = &stdout_writer.interface;

    // setup allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    // get command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try stdout.print("Usage: {s} <filename>\n", .{args[0]});
        try stdout.flush();
        return;
    }

    const filename = args[1];

    // load stop words from file
    var stop_words_file = try std.fs.cwd().openFile("stop_words.txt", .{});
    defer stop_words_file.close();

    const stat = try stop_words_file.stat();
    const stop_words_buffer = try stop_words_file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(stop_words_buffer);

    // populate stop words set
    var stop_words = std.StringHashMap(void).init(allocator);
    defer stop_words.deinit();

    var stop_words_iter = std.mem.splitAny(u8, stop_words_buffer, ",");
    while (stop_words_iter.next()) |w| {
        try stop_words.put(w, {});
    }

    // add single letter characters
    const letters = "abcdefghijklmnopqrstuvwxyz";
    for (letters, 0..) |_, i| {
        try stop_words.put(letters[i..i+1], {});
    }

    // read input file
    var input_file = try std.fs.cwd().openFile(filename, .{});
    defer input_file.close();

    const input_stat = try input_file.stat();
    const buffer = try input_file.readToEndAlloc(allocator, input_stat.size);
    defer allocator.free(buffer);

    // replace all non-alphanumeric chars with whitespace and convert to lowercase
    for (buffer, 0..) |char, i| {
        if (!std.ascii.isAlphanumeric(char)) {
            buffer[i] = ' ';
        } else {
            buffer[i] = std.ascii.toLower(char);
        }
    }

    // create hash map for word counts
    var word_counts = std.StringHashMap(u32).init(allocator);
    defer word_counts.deinit();

    // split on whitespace and count words
    var words_iter = std.mem.tokenizeAny(u8, buffer, " ");
    while (words_iter.next()) |word| {
        // skip stop words
        if (stop_words.contains(word)) {
            continue;
        }

        const entry = try word_counts.getOrPut(word);
        if (entry.found_existing) {
            entry.value_ptr.* += 1;
        } else {
            entry.value_ptr.* = 1;
        }
    }

    // convert hashmap to array for sorting
    const WordCount = struct {
        word: []const u8,
        count: u32,
    };

    var word_array = try allocator.alloc(WordCount, word_counts.count());
    defer allocator.free(word_array);

    var iter = word_counts.iterator();
    var idx: usize = 0;
    while (iter.next()) |entry| {
        word_array[idx] = .{
            .word = entry.key_ptr.*,
            .count = entry.value_ptr.*,
        };
        idx += 1;
    }

    // sort by count descending
    std.mem.sort(WordCount, word_array, {}, struct {
        fn lessThan(_: void, a: WordCount, b: WordCount) bool {
            return a.count > b.count;
        }
    }.lessThan);

    // print first 25 sorted results
    const limit = @min(25, word_array.len);
    for (word_array[0..limit]) |wc| {
        try stdout.print("{s} - {d}\n", .{ wc.word, wc.count });
    }

    try stdout.flush();
}


// end
