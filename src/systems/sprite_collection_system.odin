package systems
import "core:fmt"
import "../raylib"
import "../ecs"
import "../helper"
import "../engine"



update_sprite_collection :: proc(ctx: ^engine.Game_Context, entity: ^ecs.Entity) {
    using helper
    using raylib
    using ecs

    if entity.sprite_collection_frame_count == 0 {
        return
    }

    entity.sprite_collection_current_time += ctx.delta_time
    if entity.sprite_collection_current_time >= entity.sprite_collection_frame_time {
        entity.sprite_collection_current_time = 0
        entity.sprite_collection_frame_index += 1
        if entity.sprite_collection_frame_index >= entity.sprite_collection_frame_count {
            entity.sprite_collection_frame_index = 0
        }

        entity.texture = entity.sprite_collection_textures[entity.sprite_collection_frame_index]
    }
}