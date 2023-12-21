package main
import "vendor:raylib"
import "helper"
import "ecs"
import "asset"
import "core:fmt"

make_cursor :: proc (entity_ctx: ^ecs.Entity_Context, asset_ctx: ^asset.Asset_Context) -> ^ecs.Entity
{
    using raylib
    using ecs
    using asset
    
    texture:= load_asset(asset_ctx, "cursor_gauntlet_white", Texture2D)
    cursor:= make_entity(entity_ctx, Layers.UI)
    
    sprite:= get_component(cursor, Sprite)
    base_texture:= get_component(cursor, Base_Texture)
    base_texture.texture = texture


    return cursor
}

update_cursor :: proc (cursor: ^ecs.Entity)
{
    using helper
    using raylib
    using ecs

    mouse_pos:= GetMousePosition()
    
    base_texture := get_component(cursor, Base_Texture)
    transform := get_component(cursor, Transformation)
    texture := base_texture.texture

    transform.pos.x = mouse_pos.x - tex_width(texture) / 2
    transform.pos.y = mouse_pos.y - tex_height(texture) / 2
} 