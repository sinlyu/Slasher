package systems
import "core:fmt"
import "core:math"
import "core:strings"
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

    // calc direction
    dir := vec2_dir(physics.velocity)

    // draw dir debug helper line
    raylib.DrawLineEx(transform.pos + transform.origin, transform.pos + transform.origin + dir * 100, 2, raylib.RED)
    angle := vec2_angle(transform.pos + dir)

    // angle to degrees
    deg := angle * 180 / math.PI

    // determine animation frame (E, N, NE, NEE, NNE, NNW, NW, NWW, S, SE, SEE, SSE, SW, SWW, SSW, W)
    // find the best match
    frame_angles := [16]f32{0, 22, 45, 67, 90, 112, 135, 157, 180, 202, 225, 247, 270, 292, 315, 337}
    frame_names := [16]string{"E", "NEE", "NE", "NNE", "N", "NNW", "NW", "NWW", "W", "SWW", "SW", "SSW", "S", "SSE", "SE", "SEE"}
    
    best_match_angle :f32 = 0
    best_frame_name :string = "E"
    best_index := 0

    for frame_angle in frame_angles {
        if math.abs(frame_angle - deg) < math.abs(best_match_angle - deg) {
            best_match_angle = frame_angle
            best_frame_name = frame_names[best_index]
        }
        best_index += 1
    }

    physics.angle = angle

    if physics.fixed_angle != best_match_angle {    
        physics.fixed_angle = best_match_angle

        if has_component(entity, Sprite_Collection) {
            // update sprite direction
            sb := strings.builder_make()
            defer strings.builder_destroy(&sb)
            fmt.sbprintf(&sb, "skeleton_default_walk_%s_%v.", best_frame_name, cast(i32)best_match_angle)

            change_sprite_collection_items(entity, load_many_sprites(ctx.asset_ctx, strings.to_string(sb)))
        }
    }
}