package timing

import "vendor:raylib"

Timer_Context :: struct {
    start : f64,
    end : f64,
}

timer_create :: proc(seconds: f64) -> ^Timer_Context {
    timer := new(Timer_Context)
    timer.start = raylib.GetTime()
    timer.end = timer.start + seconds
    return timer
}

timer_destroy :: proc(timer: ^Timer_Context) {
    free(timer)
}

timer_is_ellapsed :: proc(timer: ^Timer_Context) -> bool {
    return raylib.GetTime() >= timer.end
}

timer_reset :: proc(seconds: f64, timer: ^Timer_Context) {
    timer.start = raylib.GetTime()
    timer.end = timer.start + seconds
}