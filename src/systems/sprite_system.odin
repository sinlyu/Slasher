package systems
import "core:fmt"
import "vendor:raylib"
import "../ecs"
import "../helper"


update_sprite_system :: proc(ctx: ^ecs.Entity_Context) {
    using ecs
    
    for entity_id, component_data in ctx.components[Base_Texture] {
        base_texture:= cast(^Base_Texture)component_data.data
        update_sprite(ctx, base_texture)
    }
}

@(private)
update_sprite :: proc(ctx: ^ecs.Entity_Context, base_texture: ^ecs.Base_Texture) {
    using helper
    using raylib
    using ecs
    
    entity := base_texture.entity
    pos := base_texture.entity.pos
    base_texture := get_component(entity, Base_Texture)
    texture := base_texture.texture
    
    src := Rectangle{0, 0, cast(f32)texture.width, cast(f32)texture.height}
    dst := Rectangle{cast(f32)pos.x, cast(f32)pos.y, tex_width(texture), tex_height(texture)}

    DrawTexturePro(texture^, src, dst, Vector2{0, 0}, 0, WHITE)
    
    // Debug Rectangle for Size
    if base_texture.debug {
        DrawRectangleLinesEx(dst, 1,  RED)
    }
}