package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc(){
	data, ok := os.read_entire_file("./Day2-Input.txt")
	if !ok{
		fmt.println("ERROR: Unable to read puzzle input.")
		return
	}
	defer delete(data, context.allocator)

	input := string(data)
	ranges := strings.split(input,",")

	total := 0
	for range in ranges{
		values := strings.split(range,"-")

		start, ok_1 := strconv.parse_int(values[0])
		end, ok_2 := strconv.parse_int(values[1])
		// if !(ok_1 && ok_2){
		// 	fmt.println("Unable to parse ints of range ", range)
		// 	return 
		// }
		
		invalids := find_invalids(start,end)
		for id in invalids{
			total += id
		}
	}

	fmt.printf("-- Result: %d ---\n", total)
}

is_silly :: proc(id_str: string) -> bool{
	//Get length, if not even return false.
	if(len(id_str) % 2 != 0){
		return false
	}

	//Split string in the middle.
	//Turn both halfs to int
	a, ok1 := strconv.parse_int(id_str[:len(id_str)/2])
	b, ok2 := strconv.parse_int(id_str[len(id_str)/2:])

	//If they are equal return true
	if(a == b){
		return true
	}

	return false
}


find_invalids :: proc(start: int, end: int) -> [dynamic]int{
	invalids : [dynamic]int

	for id := start ; id <= end; id += 1 {
		id_bfr : [16]byte
		id_str := strconv.write_int(id_bfr[:],cast(i64)id,10)


		if (is_silly(id_str)){
			append(&invalids,id)
		}
	}

	return invalids
}
