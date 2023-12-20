package engine
import "../ecs"
import "../asset"
import "../drawing"

Game_Context :: struct {
    entity_ctx: ecs.Entity_Context,
    asset_ctx: asset.Asset_Context,
    draw_ctx: drawing.Draw_Context
}

init_game_context :: proc() -> Game_Context {
    using ecs
    using asset
    using drawing

    ctx:= Game_Context{}
    ctx.entity_ctx = init_entity_context()
    ctx.asset_ctx = init_asset_context()
    ctx.draw_ctx = init_draw_context()

    return ctx
}