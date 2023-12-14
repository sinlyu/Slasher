package systems
import "core:fmt"
import "vendor:raylib"
import "../ecs"


update_health_system :: proc(ctx: ^ecs.Entity_Context) {
    using ecs

    size:= len(ctx.components[Health])
    if size == 0 { return }

    for entity_id, component_data in ctx.components[Health] {
        health:= cast(^Health)component_data.data
        draw_health(ctx, health)
    }
}


@(private)
draw_health :: proc(ctx: ^ecs.Entity_Context, health: ^ecs.Health) {
    using raylib
    using ecs

    entity := health.entity
    transform := get_component(entity, Transformation)

    pos := raylib.Vector2{transform.pos.x + transform.origin.x - 50, transform.pos.y + transform.origin.y / 2 + 35}

    DrawRectangleV(pos - 1, Vector2{102, 12}, Color{0, 0, 0, 255})
    DrawRectangleV(pos, Vector2{50, 10}, Color{255, 0, 0, 255})
}

@(private)
update_health :: proc(ctx: ^ecs.Entity_Context, health: ^ecs.Health) {
    
}