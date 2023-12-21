package systems
import "core:fmt"
import "../raylib"
import "../ecs"
import "../timing"
import "../engine"

HEALTH_WIDTH :: 102
HEALTH_HEIGHT :: 12
HEALTH_SIZE_VEC :: raylib.Vector2{ HEALTH_WIDTH, HEALTH_HEIGHT }

update_health :: proc(ctx: ^engine.Game_Context, entity: ^ecs.Entity) {
    using ecs

    if(entity.max_health < 0) {
        return
    }

    if cooldown_use(entity, "test") {
        entity.current_health -= 1
        if entity.current_health <= 0 {
            entity.current_health = entity.max_health
        }
    } 
}


draw_health :: proc(ctx: ^engine.Game_Context, entity: ^ecs.Entity) {
    using raylib
    using ecs

    if(entity.max_health < 0) {
        return
    }
    
    pos := Vector2{ entity.transform_position.x + entity.transform_origin.x - 50, entity.transform_position.y + entity.transform_origin.y / 2 + 35 }
    fill := cast(f32)HEALTH_WIDTH * cast(f32)entity.current_health / cast(f32)entity.max_health

    DrawRectangleV(pos - 1, HEALTH_SIZE_VEC, BLACK)
    DrawRectangleV(pos, Vector2{fill - 2, HEALTH_HEIGHT - 2}, RED)
}