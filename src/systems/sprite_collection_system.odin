package systems
import "core:fmt"
import "vendor:raylib"
import "../ecs"
import "../helper"


update_sprite_collection_system :: proc(ctx: ^ecs.Entity_Context) {
    using ecs
    
    for entity_id, component_data in ctx.components[Sprite_Collection] {
        sprite_collection:= cast(^Sprite_Collection)component_data.data
        update_sprite_collection(ctx, sprite_collection)
    }
}

@(private)
update_sprite_collection :: proc(ctx: ^ecs.Entity_Context, sprite_collection: ^ecs.Sprite_Collection) {
    using helper
    using raylib
    using ecs

    entity := sprite_collection.entity
    base_texture := get_component(entity, Base_Texture)
    // Check for required components
    if !has_component(entity, Base_Texture) {
        panic("Sprite_Collection must have a Base_Texture")
    }

  // Update timing
    // TODO: refactor with delta time
    sprite_collection.frame_time += 1
    if(sprite_collection.frame_time >= 4) {
        sprite_collection.frame_time = 0
        sprite_collection.frame_index += 1
        if(sprite_collection.frame_index >= sprite_collection.frame_count) {
            sprite_collection.frame_index = 0
        }
        base_texture.texture = sprite_collection.textures[sprite_collection.frame_index]
    }
}