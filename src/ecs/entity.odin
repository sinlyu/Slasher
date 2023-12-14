package ecs

import "core:mem"
import "core:runtime"
import "core:fmt"
import "core:slice"
import "vendor:raylib"
import "../helper"

Entity_Id :: i32

Layers :: enum u8 {
    UI = 0,
    World = 1,
}

Entity_Context :: struct {
    entities: [dynamic]^Entity,
    components: map[typeid]map[Entity_Id]Component_Data,
    next_id: Entity_Id,
    delta_time: f32,
}

Entity :: struct {
    id: Entity_Id,
    layer: Layers,
    ctx: ^Entity_Context,
}

Component_Data :: struct {
    type: typeid,
    data: ^runtime.Raw_Any,
}

Component :: struct {
    entity: ^Entity,
    debug: bool,
}

Health :: struct {
    using base: Component,
    health: i32,
    max_health: i32,
}

Sprite :: struct {
    using base: Component,
}

Base_Texture :: struct {
    using base: Component,
    texture: ^raylib.Texture2D,
}

Hitbox :: struct {
    using base: Component,
    width: f32,
    height: f32,
}

Transformation :: struct {
    using base: Component,
    pos: raylib.Vector2,
    origin: raylib.Vector2,
    rotation: f32,
}

init_entity_context :: proc() -> ^Entity_Context {
    entity_context, err := new(Entity_Context)
    return entity_context
}

make_entity :: proc(ctx: ^Entity_Context, layer: Layers = Layers.World) -> ^Entity {
    entity:= new(Entity)
    entity.id = ctx.next_id
    entity.ctx = ctx
    entity.layer = layer // Default layer
    ctx.next_id += 1

    // Add the default components
    transform := get_component(entity, Transformation)

    append(&ctx.entities, entity)

    // We need to sort the entities by layer when we add a new one
    sort_entites(ctx)

    return entity
}

make_hitbox :: proc(entity: ^Entity, width: f32, height: f32) {
    hitbox := new(Hitbox)
    hitbox.width = width
    hitbox.height = height
    add_component(entity, Hitbox)
}

sort_entites :: proc(ctx: ^Entity_Context) {
    using mem
    slice.sort_by(ctx.entities[:], proc(a, b: ^Entity) -> bool {
        return a.layer > b.layer
    })
}

add_component :: proc(entity: ^Entity, $T: typeid) {
    components := &entity.ctx.components

    if !(T in &entity.ctx.components) {
        components[T] = make(map[Entity_Id]Component_Data)
    }

    specific_components := &entity.ctx.components[T]
    specific_components[entity.id] = new_component(T, entity)
}

new_component :: proc($T: typeid, entity: ^Entity) -> Component_Data {
    using mem
    component, err := new(T)
    component.entity = entity
    return Component_Data{ T, cast(^runtime.Raw_Any)component }
}

get_component :: proc(entity: ^Entity, $T: typeid) -> ^T {
    if !has_component(entity, T) {
        add_component(entity, T)
    }

    component := &entity.ctx.components[T][entity.id]
    return cast(^T)component.data
}

debug_set_component :: proc(entity: ^Entity, $T: typeid, debug: bool) {
    if !has_component(entity, T) {
        panic("[debug_set_component] Entity does not have that component!")
    }

    component := get_component(entity, T)
    component.debug = debug
}

has_component :: proc(entity: ^Entity, $T: typeid) -> bool {
    return T in entity.ctx.components && entity.id in entity.ctx.components[T]
}

// Helper procs based on components

comp_width :: proc(entity: ^Entity) -> f32 {
    if(!has_component(entity, Base_Texture)) {
        panic("Entity does not have a Texture based component")
    }

    base_texture := get_component(entity, Base_Texture)
    return helper.tex_width(base_texture.texture)

    // TODO: Add a BoundingBox component
}

comp_height :: proc(entity: ^Entity) -> f32 {
    if(!has_component(entity, Base_Texture)) {
        panic("Entity does not have a Texture based component")
    }

    base_texture := get_component(entity, Base_Texture)
    return helper.tex_height(base_texture.texture)

    // TODO: Add a BoundingBox component
}

try_get_texture :: proc(entity: ^Entity) -> (bool, ^raylib.Texture2D) {
    if !has_component(entity, Base_Texture) {
        return false, nil
    }
    return true, get_component(entity, Base_Texture).texture
}