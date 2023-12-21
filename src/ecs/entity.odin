package ecs

import "core:mem"
import "core:runtime"
import "core:fmt"
import "core:slice"
import "core:math"
import "core:math/rand"
import "../raylib"
import "../helper"
import "../asset"

// TODO: Instead of Components lets do one big struct with all the components in it
// We do an array for enemies, decorations, etc

Entity :: struct {
    id: i32,
    debug: bool,
    
    current_health: i32,
    max_health: i32,

    texture: ^raylib.Texture2D,

    hitbox_width: f32,
    hitbox_height: f32,

    transform_position: raylib.Vector2,
    transform_origin: raylib.Vector2,
    transform_rotation: f32,

    cooldowns: map[string]Cooldown,

    physics_velocity: raylib.Vector2,
    physics_max_velocity: f32,
    physics_acceleration: raylib.Vector2,
    physics_friction: f32,
    physics_mass: f32,
    physics_fixed_angle: f32,
    physics_angle: f32,

    sprite_collection_textures: []^raylib.Texture2D,
    sprite_collection_frame_index: i32,
    sprite_collection_frame_count: i32,
    sprite_collection_frame_time: f32,
    sprite_collection_current_time: f32,
}

Entity_Context :: struct {
    entities: []Entity,
    next_id: i32,
}

Cooldown :: struct {
    name: string,
    time: f64,
    last_used: f64,
}

init_entity_context :: proc() -> Entity_Context {
    entity_context := Entity_Context{}
    entity_context.next_id = 0
    entity_context.entities = make([]Entity, 1024)
    return entity_context
}

make_entity :: proc(ctx: ^Entity_Context) -> ^Entity {
    entity:= &ctx.entities[ctx.next_id]
    entity.id = ctx.next_id
    ctx.next_id += 1

    /*track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    entity.allocator = mem.tracking_allocator(&track)*/
    
    return entity
}

free_entity :: proc(entity: ^Entity) {

}

add_cooldown :: proc(entity: ^Entity, name: string, time: f64) {
    entity.cooldowns[name] = Cooldown{ name, time, 0 }
}

cooldown_use :: proc(entity: ^Entity, name: string) -> bool {
    cooldown := &entity.cooldowns[name]
    time := raylib.GetTime()

    if time - cooldown.last_used < cooldown.time {
        return false
    }

    cooldown.last_used = time

    return true
}

physics_apply_force :: proc(entity: ^Entity, force: raylib.Vector2) {
    entity.physics_acceleration = vec2_add(entity.physics_acceleration, force)
}

physics_set_force :: proc(entity: ^Entity, force: raylib.Vector2) {
    delta_time:= raylib.GetFrameTime() * 1000
    entity.physics_acceleration = force * delta_time
}

physics_apply_friction :: proc(entity: ^Entity) {
    entity.physics_velocity = vec2_mul(entity.physics_velocity, entity.physics_friction)
}


// Vector2 procs
vec2_add :: proc(a, b: raylib.Vector2) -> raylib.Vector2 {
    return raylib.Vector2{a.x + b.x, a.y + b.y}
}

vec2_mul :: proc(a: raylib.Vector2, b: f32) -> raylib.Vector2 {
    return raylib.Vector2{a.x * b, a.y * b}
}

vec2_dir :: proc(a: raylib.Vector2) -> raylib.Vector2 {
    magnitude := math.sqrt(a.x * a.x + a.y * a.y)

    return raylib.Vector2{a.x / magnitude, a.y / magnitude}
}

vec2_rnd :: proc(max: f32 = 10) -> raylib.Vector2 {
    x:= rand.float32() * max
    y:= rand.float32() * max
    return raylib.Vector2{x, y}
}

vec2_angle :: proc(dir: raylib.Vector2) -> f32 {
    return math.atan2(dir.y, dir.x)
}

vec2_zero :: proc() -> raylib.Vector2 {
    return raylib.Vector2{0, 0}
}