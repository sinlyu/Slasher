package main
import "raylib"
import "helper"
import "ecs"
import "asset"
import "core:fmt"

make_cursor :: proc (entity_ctx: ^ecs.Entity_Context, asset_ctx: ^asset.Asset_Context) -> ^ecs.Entity
{
    using raylib
    using ecs
    using asset

    entity:= new_entity()
    entity.texture = load_asset(asset_ctx, "cursor_gauntlet_white", Texture2D)
    entity.layer = Layers.UI

    return entity
}

update_cursor :: proc (cursor: ^ecs.Entity)
{
    using helper
    using raylib
    using ecs

    mouse_pos:= GetMousePosition()

    entity.transform_position.x = mouse_pos.x - tex_width(entity.texture) / 2
    entity.transform_position.y = mouse_pos.y - tex_height(entity.texture) / 2
} 