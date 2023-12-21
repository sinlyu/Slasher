package systems
import "core:fmt"
import "core:math"
import "core:strings"
import "../raylib"
import "../ecs"
import "../engine"

frame_angles := [16]f32{0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180, 202.5, 225, 247.5, 270, 292.5, 315, 337.5}
frame_names := [16]string{"E", "NEE", "NE", "NNE", "N", "NNW", "NW", "NWW", "W", "SWW", "SW", "SSW", "S", "SSE", "SE", "SEE"}

update_physics :: proc(ctx: ^engine.Game_Context, entity: ^ecs.Entity) {
    using ecs

    entity_ctx := ctx.entity_ctx
    asset_ctx := ctx.asset_ctx

    delta_time := ctx.delta_time / 100
    real_acceleration := entity.physics_acceleration / entity.physics_mass

    // Apply velocity and acceleration and friction to position
    entity.physics_velocity = entity.physics_velocity + real_acceleration // * delta_time
    entity.physics_velocity = entity.physics_velocity * (1 / (1 + entity.physics_friction * delta_time))
    entity.transform_position = entity.transform_position + entity.physics_velocity * delta_time

    entity.physics_acceleration = vec2_zero()

    // calc direction
    dir := vec2_dir(entity.physics_velocity)

    // draw dir debug helper line
    raylib.DrawLineEx(entity.transform_position + entity.transform_origin, entity.transform_position + entity.transform_origin + dir * 100, 2, raylib.RED)
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

    entity.physics_angle = angle

    if entity.physics_fixed_angle != best_match_angle {    
        entity.physics_fixed_angle = best_match_angle

        if len(entity.sprite_collection_textures) > 0 {
            // update sprite direction
            sb := strings.builder_make()
            defer strings.builder_destroy(&sb)
            fmt.sbprintf(&sb, "skeleton_default_walk_%s_%v.", best_frame_name, cast(i32)best_match_angle)
            change_sprite_collection_items(entity, get_many_sprites(&asset_ctx, strings.to_string(sb)))
        }
    }

    entity_pos:= entity.transform_position + entity.transform_origin

    screen_width:= cast(f32)raylib.GetScreenWidth()
    screen_height:= cast(f32)raylib.GetScreenHeight()

    // Check if entity is off screen and wrap it around
    if entity_pos.x < -entity.transform_origin.x { entity.transform_position.x = screen_width + entity.transform_origin.x }
    if entity_pos.x > screen_width { entity.transform_position.x = -entity.transform_origin.x }
    if entity_pos.y < -entity.transform_origin.y { entity.transform_position.y = screen_height + entity.transform_origin.y }
    if entity_pos.y > screen_height { entity.transform_position.y = -entity.transform_origin.y }


    // Draw Hitbox
    center_x := entity.transform_position.x + entity.transform_origin.x + 2
    center_y := entity.transform_position.y + entity.transform_origin.y - 30

    hitbox_x := center_x - entity.hitbox_width / 2
    hitbox_y := center_y - entity.hitbox_height / 2

    raylib.DrawRectangleLinesEx(raylib.Rectangle{hitbox_x, hitbox_y, entity.hitbox_width, entity.hitbox_height}, 1, raylib.RED)

    // Draw Point
    raylib.DrawCircleV(raylib.Vector2{center_x, center_y}, 2, raylib.GREEN)
}

hitbox_intersects :: proc(a: ^ecs.Entity, b: ^ecs.Entity) -> bool {
    using ecs

    a_center_x := a.transform_position.x + a.transform_origin.x + 2
    a_center_y := a.transform_position.y + a.transform_origin.y - 30

    b_center_x := b.transform_position.x + b.transform_origin.x + 2
    b_center_y := b.transform_position.y + b.transform_origin.y - 30

    a_hitbox_x := a_center_x - a.hitbox_width / 2
    a_hitbox_y := a_center_y - a.hitbox_height / 2

    b_hitbox_x := b_center_x - b.hitbox_width / 2
    b_hitbox_y := b_center_y - b.hitbox_height / 2

    return raylib.CheckCollisionRecs(raylib.Rectangle{a_hitbox_x, a_hitbox_y, a.hitbox_width, a.hitbox_height}, raylib.Rectangle{b_hitbox_x, b_hitbox_y, b.hitbox_width, b.hitbox_height})
}