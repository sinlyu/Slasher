package systems
import "core:fmt"
import "vendor:raylib"
import "../ecs"

update_physics_system :: proc(ctx: ^ecs.Entity_Context) {
    using ecs

    if len(ctx.components[Physics]) == 0 { return }

    for entity_id, component_data in ctx.components[Physics] {
        physics:= cast(^Physics)component_data.data
        update_physics(ctx, physics)
    }
}


@(private)
update_physics :: proc(ctx: ^ecs.Entity_Context, physics: ^ecs.Physics) {
    using ecs

    entity := physics.entity
    transform := get_component(entity, Transformation)
    if transform == nil { panic("Physics component without Transform") }

    delta_time := ctx.delta_time / 1000

    // Apply velocity and acceleration and friction to position
    physics.velocity = physics.velocity + physics.acceleration * delta_time
    physics.velocity = physics.velocity * physics.friction
    transform.pos = transform.pos + physics.velocity * delta_time
}