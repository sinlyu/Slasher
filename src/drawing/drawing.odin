package drawing

Draw_Call :: struct {
    draw: proc(),
    layer: i32,
    index: i32,
}

Draw_Context :: struct {
    calls: [dynamic]Draw_Call
}

init_draw_context :: proc() -> Draw_Context {
    ctx:= Draw_Context {}
    ctx.calls = make([dynamic]Draw_Call, 0)
    return ctx
}

flush_draw_context :: proc(ctx: Draw_Context) {
    for call in ctx.calls {
        call.draw()
    }
    delete_dynamic_array(ctx.calls)
}