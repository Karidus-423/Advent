package main

import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:unicode/utf8"
import "core:mem"
import "core:os"
import "core:testing"

day_3_lobby ::proc(){
}

@(test)
test_day_3_lobby :: proc(t: ^testing.T){
	n := 2 + 2

	testing.expect(t, n == 4, "Failed to get 4 from 2 + 2 operation")
}

