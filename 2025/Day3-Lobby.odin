package main

import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:unicode/utf8"
import "core:mem"
import "core:os"
import "core:testing"

Battery :: struct{
	val : rune,
	pos : int,
}

day_3_lobby ::proc(){
	data, ok := os.read_entire_file("./Day3-Input.txt")
	defer delete(data)
	if !ok{
		fmt.println("Unable to open file to read.")
		return;
	}

	input := string(data)

	result := 0
	bat_select_limit := 12

	for bank in strings.split_lines_iterator(&input){
		result += get_voltage(bank,bat_select_limit)
	}

	fmt.println("-- RESULT ----", result)
}

highlight_overloaded_batteries ::proc(bank: string, selected_bats: []Battery){
	for digit, i in bank{
		highlight := false
		for bat in selected_bats{
			if i == bat.pos{
				fmt.printf("\033[93;1;4m%v\033[0m",bat.val)
				highlight = true
				break;
			}
		}

		if !highlight{
			fmt.printf("\033[97;1;9m%v\033[0m",digit)
		}
	}

	fmt.printf("\n")
}

get_voltage ::proc(bank: string,limit: int)-> int{
	selected_bats : [dynamic]Battery
	for i := 0; i < limit; i += 1 do append(&selected_bats,Battery{'0',255})
	defer delete(selected_bats)

	slots_available := limit
	fill_remaining := false
	continue_from := 0

	for digit, i in bank{
		if fill_remaining{
			break
		}
		curr_bat := Battery{val = digit,pos = i}

		for slot_bat, j in selected_bats{
			if curr_bat.val > slot_bat.val{

				remaining_digits := len(bank) - i
				slots_available = limit - j - 1
				if remaining_digits > slots_available{
					assign_at(&selected_bats,j,curr_bat)
					for k := j+1; k < limit; k += 1 do assign_at(&selected_bats, k, Battery{'0',255})
					break
				}else if (remaining_digits == slots_available){
					continue_from = i + 1 
					fill_remaining = true
				}
			}
		}
	}

	if(len(bank) != 0){
		for i := 0; i < slots_available; i += 1{
			slot_pos := limit - slots_available + i
			bank_pos := continue_from + i
			bat := Battery{val = cast(rune)bank[bank_pos],pos = bank_pos}
			assign_at(&selected_bats, slot_pos, bat)
		}
	}


	highlight_overloaded_batteries(bank,selected_bats[0:])

	// Create int from found batteries and return
	bank_joltage_runes : [dynamic]rune
	defer delete(bank_joltage_runes)
	for bat in selected_bats{
		append(&bank_joltage_runes, bat.val)
	}

	bank_joltage_str := utf8.runes_to_string(bank_joltage_runes[:])
	defer delete(bank_joltage_str)

	bank_joltage_val , ok := strconv.parse_int(bank_joltage_str)
	if !ok{
		fmt.println("Unable to convert string->", bank_joltage_str, "to int.")
		return 0;
	}

	return bank_joltage_val;
}

@(test)
test_day_3_lobby :: proc(t: ^testing.T){
	banks := "987654321111111\n811111111111119\n234234234234278\n818181911112111"
	expect := 3121910778619
	result := 0
	bat_select_limit := 12

	for bank in strings.split_lines_iterator(&banks){
		result += get_voltage(bank,bat_select_limit)
	}

	testing.expect(t, expect == result, "-- Day 3 --- FAILURE!")
}

