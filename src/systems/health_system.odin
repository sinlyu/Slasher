package systems
import "core:fmt"
import "../raylib"
import "../ecs"
import "../timing"

HEALTH_WIDTH :: 102
HEALTH_HEIGHT :: 12
HEALTH_SIZE_VEC :: raylib.Vector2{ HEALTH_WIDTH, HEALTH_HEIGHT }

update_health_system :: proc(ctx: ^ecs.Entity_Context) {
    using ecs

    if len(ctx.components[Health]) == 0 { return }

    for entity_id, component_data in ctx.components[Health] {
        health:= cast(^Health)component_data.data
        update_health(ctx, health)
        draw_health(ctx, health)
    }
}

@(private)
update_health :: proc(ctx: ^ecs.Entity_Context, health: ^ecs.Health) {
    using ecs

    entity := health.entity
    
    if cooldown_use(entity, "test") {
        health.health -= 1
        if health.health <= 0 {
            health.health = health.max_health
        }
    } 
}


@(private)
draw_health :: proc(ctx: ^ecs.Entity_Context, health: ^ecs.Health) {
    using raylib
    using ecs

    entity := health.entity
    transform := get_component(entity, Transformation)

    pos := raylib.Vector2{transform.pos.x + transform.origin.x - 50, transform.pos.y + transform.origin.y / 2 + 35}
    fill := cast(f32)HEALTH_WIDTH * cast(f32)health.health / cast(f32)health.max_health

    DrawRectangleV(pos - 1, HEALTH_SIZE_VEC, BLACK)
    DrawRectangleV(pos, Vector2{fill - 2, HEALTH_HEIGHT - 2}, RED)
}