package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:math"
import "core:testing"

MoveDial :: proc(dial: int, turn: int) -> (new: int, touched_zero: int) {
	touched_zero = 0
	if(turn < 0){
		div,mod := turn / -100, turn % -100
		touched_zero += div

		if(dial != 0 && dial + mod <= 0) do touched_zero += 1
	}else{
		div,mod := turn / 100, turn % 100
		touched_zero += div

		if(dial + mod >= 100) do touched_zero += 1
	}

	//TODO: Understand why df this was the issue.
	new = (((dial + turn) % 100) + 100) % 100
	return
}

day_1_secret_entrance :: proc() {
	data, ok := os.read_entire_file("./Day1-Input.txt", context.allocator)
	if !ok{
		fmt.println("Unable to read file.")
		return
	}

	defer delete(data, context.allocator)

	expected := 6770

	dial := 50
	result := 0
	touched_zero:= 0

	input := string(data)
	for rotation in strings.split_lines_iterator(&input){
	// for rotation in data{
		theta, ok := strconv.parse_int(strings.cut(rotation,1,0))
		if !ok {
			break
		}

		if (strings.contains(rotation,"R")){
			dial, touched_zero = MoveDial(dial, theta)
		}else{
			dial, touched_zero = MoveDial(dial, -theta)
		}

		result += touched_zero
	}


	if (result == expected){
		fmt.println("━━ PASSED ━━━ Result: ", result)
	}else{
		fmt.println("━━ ERROR ━━━ Expected: ", expected, "| Actual: ", result)
	}
}

@(test)
test_day_1_secret_entrance :: proc(t: ^testing.T){
	dial := 50
	result := 0
	touched_zero:= 0

	data : [dynamic]string
	append(&data, "L68","L30","R48","L5","R60","L55","L1","L99","R14","L82","R1000","L1000")

	for rotation in data{
		theta, ok := strconv.parse_int(strings.cut(rotation,1,0))
		if !ok {
			break
		}

		if (strings.contains(rotation,"R")){
			dial, touched_zero = MoveDial(dial, theta)
		}else{
			dial, touched_zero = MoveDial(dial, -theta)
		}

		result += touched_zero
	}


	testing.expect(t, result == 26, "-- Day 1 : FAILED ---")
}
