package systems
import "core:fmt"
import "core:math"
import "core:strings"
import "vendor:raylib"
import "../ecs"
import "../engine"

frame_angles := [16]f32{0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180, 202.5, 225, 247.5, 270, 292.5, 315, 337.5}
frame_names := [16]string{"E", "NEE", "NE", "NNE", "N", "NNW", "NW", "NWW", "W", "SWW", "SW", "SSW", "S", "SSE", "SE", "SEE"}

update_physics_system :: proc(ctx: ^engine.Game_Context) {
    using ecs

    entity_ctx := ctx.entity_ctx

    if len(entity_ctx.components[Physics]) == 0 { return }

    for entity_id, component_data in entity_ctx.components[Physics] {
        physics:= cast(^Physics)component_data.data
        update_physics(ctx, physics)
    }
}


@(private)
update_physics :: proc(ctx: ^engine.Game_Context, physics: ^ecs.Physics) {
    using ecs

    entity_ctx := ctx.entity_ctx
    asset_ctx := ctx.asset_ctx

    entity := physics.entity
    transform := get_component(entity, Transformation)
    if transform == nil { panic("Physics component without Transform") }

    delta_time := entity_ctx.delta_time / 100
    real_acceleration := physics.acceleration / physics.mass

    // Apply velocity and acceleration and friction to position
    physics.velocity = physics.velocity + real_acceleration // * delta_time
    physics.velocity = physics.velocity * (1 / (1 + physics.friction * delta_time))
    transform.pos = transform.pos + physics.velocity * delta_time

    physics.acceleration = vec2_zero()

    // calc direction
    dir := vec2_dir(physics.velocity)

    // draw dir debug helper line
    raylib.DrawLineEx(transform.pos + transform.origin, transform.pos + transform.origin + dir * 100, 2, raylib.RED)
    angle := vec2_angle(dir)

    // angle to degrees
    deg := -angle * 180 / math.PI
    if deg < 0 { deg = 360 + deg }

    // determine animation frame (E, N, NE, NEE, NNE, NNW, NW, NWW, S, SE, SEE, SSE, SW, SWW, SSW, W)
    // find the best match
    best_match_angle :f32 = 0
    best_frame_name :string = "E"
    best_index := 0

    for frame_angle in frame_angles {
        if math.abs(frame_angle - deg) < math.abs(best_match_angle - deg) {
            best_frame_name = frame_names[best_index]
            best_match_angle = frame_angle
        }
        best_index += 1
    }

    physics.angle = angle

    if physics.fixed_angle != best_match_angle {    
        physics.fixed_angle = best_match_angle
        fmt.println(physics.fixed_angle)

        if has_component(entity, Sprite_Collection) {
            // update sprite direction
            sb := strings.builder_make()
            defer strings.builder_destroy(&sb)
            fmt.sbprintf(&sb, "skeleton_default_walk_%s_%v.", best_frame_name, cast(i32)best_match_angle)
            change_sprite_collection_items(entity, load_many_sprites(&asset_ctx, strings.to_string(sb)))
        }
    }

    entity_pos := transform.pos + transform.origin


    screen_width:= cast(f32)raylib.GetScreenWidth()
    screen_height:= cast(f32)raylib.GetScreenHeight()

    // Check if entity is off screen and wrap it around
    if entity_pos.x < 0 { transform.pos.x = transform.pos.x + transform.origin.x - screen_width }
    if entity_pos.x > screen_width { transform.pos.x = -transform.origin.x }
    if entity_pos.y < 0 { transform.pos.y = screen_height + transform.origin.y }
    if entity_pos.y > screen_height { transform.pos.y = -transform.origin.y }
}