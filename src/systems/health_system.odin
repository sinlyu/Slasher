package systems
import "core:fmt"
import "../ecs"


update_health_system :: proc(ctx: ^ecs.Entity_Context) {
    using ecs

    for entity_id, component_data in ctx.components[Health] {
        health:= cast(^Health)component_data.data
        update_health(ctx, health)
    }
}

@(private)
update_health :: proc(ctx: ^ecs.Entity_Context, health: ^ecs.Health) {
    health.health -= 100
}