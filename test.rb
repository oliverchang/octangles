require './timetabler'

Timetabler::generate([Course.new('COMP2911'), Course.new('COMP3331'), Course.new('COMP3891')],2)
