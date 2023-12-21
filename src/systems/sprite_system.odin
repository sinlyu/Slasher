package systems
import "core:fmt"
import "../raylib"
import "../ecs"
import "../helper"
import "../engine"


update_sprite :: proc(ctx: ^engine.Game_Context, entity: ^ecs.Entity) {
    using helper
    using raylib
    using ecs

    if entity.texture == nil {
        return
    }

    
    src := Rectangle{0, 0, cast(f32)entity.texture.width, cast(f32)entity.texture.height}
    dst := Rectangle{ entity.transform_position.x, entity.transform_position.y, tex_width(entity.texture), tex_height(entity.texture)}

    DrawTexturePro(entity.texture^, src, dst, Vector2{0, 0}, 0, WHITE)
    
    // Debug Rectangle for Size
    if entity.debug {
        DrawRectangleLinesEx(dst, 1,  RED)
    }
}