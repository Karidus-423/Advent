package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"
import "core:mem"


//TODO: Find memory leaks.
main :: proc(){
	tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    // Your program goes here

	data, ok := os.read_entire_file("./Day2-Input.txt")
	if !ok{
		fmt.println("ERROR: Unable to read puzzle input.")
		return
	}
	defer delete(data, context.allocator)


	// input := "11-22,95-115,998-1012,1188511880-1188511890,222220-222224, 1698522-1698528,446443-446449,38593856-38593862,565653-565659, 824824821-824824827,2121212118-2121212124Z"
	input := string(data)

	ranges := strings.split(input,",")
	defer delete(ranges)

	total := 0
	for range in ranges{
		values := strings.split(range,"-")
		defer delete(values)

		start, ok_1 := strconv.parse_int(values[0])
		end, ok_2 := strconv.parse_int(values[1])
		if (!ok_1 && !ok_2){
			fmt.println("Unable to parse ints of range ", range)
			return 
		}

		invalids := find_invalids(start,end)
		defer delete(invalids)
		for id in invalids{
			total += id
		}
	}

    for key, value in tracking_allocator.allocation_map {
        fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
    }

    mem.tracking_allocator_destroy(&tracking_allocator)
	fmt.printf("-- Result: %d ---\n", total)

}

is_silly_p1 :: proc(id_str: string) -> bool{
	//Get length, if not even return false.
	if(len(id_str) % 2 != 0){
		return false
	}

	//Split string in the middle.
	//Turn both halfs to int
	a, ok1 := strconv.parse_int(id_str[:len(id_str)/2])
	b, ok2 := strconv.parse_int(id_str[len(id_str)/2:])
	if (!ok1 && !ok2){
		fmt.println("Unable to parse_int : ", id_str)
		return false
	}

	//If they are equal return true
	if(a == b){
		return true
	}

	return false
}

is_silly_p2 :: proc(id_str: string) -> bool{
	sequence_arr : [dynamic]rune
	defer delete(sequence_arr)

	for digit in id_str{
		append(&sequence_arr,digit)
		sequence_str := utf8.runes_to_string(sequence_arr[:])
		defer delete(sequence_str)

		split_res := strings.split(id_str,sequence_str)
		defer delete(split_res)

		split_res_len := len(split_res) - 1
		if(split_res_len >= 2){
			all_empty_res := true
			for i := 0; i <= split_res_len; i += 1{
				if(strings.compare(split_res[i],"") != 0){
					all_empty_res = false
					break;
				}
			}

			if (all_empty_res){
				return true
			}
		}
	}

	return false
}



find_invalids :: proc(start: int, end: int) -> [dynamic]int{
	invalids : [dynamic]int

	for id := start ; id <= end; id += 1 {
		id_bfr : [16]byte
		id_str := strconv.write_int(id_bfr[:],cast(i64)id,10)


		if (is_silly_p2(id_str)){
			// fmt.printf("-- INVALID_ID: %d ---\n",id)
			append(&invalids,id)
		}
	}

	return invalids
}
