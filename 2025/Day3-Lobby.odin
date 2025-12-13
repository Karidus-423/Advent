package main

import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:unicode/utf8"
import "core:mem"
import "core:os"

Battery :: struct{
	v: rune,
	pos: int,
}

find_joltage :: proc(bank: string) -> int{
	high := Battery{'0',0}
	for num, i in bank{
		if num > high.v && i != len(bank)-1{
			high.v = num
			high.pos = i
		}
	}

	jolt_runes : []rune = {high.v,'a'}
	high_jolt := 0
	for num, i in bank{
		if (high.pos < i){
			jolt_runes[1] = num
			jolt_str := utf8.runes_to_string(jolt_runes)
			defer delete(jolt_str)

			jolt_val, ok:= strconv.parse_int(jolt_str)
			if !ok{
				fmt.println("Unable to parse string to int. | ", jolt_str)
				return 0
			}

			if high_jolt < jolt_val do high_jolt = jolt_val 
		}
	}

	return high_jolt
}

main :: proc() {
	//---------------------------------------------------------------------
	tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)
	//---------------------------------------------------------------------

	// input := "987654321111111\n811111111111119\n234234234234278\n818181911112111"
	data, ok := os.read_entire_file("./Day3-Input.txt")
	if !ok{
		fmt.println("Unable to read file.")
		return
	}
	input := string(data)
	defer delete(input)

	banks := strings.split_lines(input)
	defer delete(banks)

	total := 0
	for bank in banks {
		joltage_val := find_joltage(bank)
		total += joltage_val
	}

	//---------------------------------------------------------------------
    for key, value in tracking_allocator.allocation_map {
        fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
    }
    mem.tracking_allocator_destroy(&tracking_allocator)
	//---------------------------------------------------------------------
	fmt.printf("-- RESULT: %d----\n",total)
}
