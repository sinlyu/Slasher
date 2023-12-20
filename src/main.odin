package main

import "core:fmt"
import "core:strings"
import "core:mem"
import "vendor:raylib"
import "ecs"
import "systems"
import "asset"
import "drawing"
import "engine"

main :: proc() {
    using raylib
    using ecs
    using systems
    using asset

    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    width: i32 = 800
    height: i32 = 600

    game_ctx:= engine.init_game_context()

    asset_ctx := &game_ctx.asset_ctx
    entity_ctx := &game_ctx.entity_ctx

    register_asset(asset_ctx, "cursor_gauntlet_white", "assets/user_interface/cursor/cursor_gauntlet_white.png")

    // Skeleton
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/E")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/N")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/NE")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/NEE")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/NNE")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/NNW")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/NW")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/NWW")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/S")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/SE")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/SEE")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/SSE")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/SSW")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/SW")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/SWW")
    auto_register_assets(asset_ctx, "assets/enemy/skeleton/skeleton_default_walk/W")

    InitWindow(width, height, "Slasher")

    cursor:= make_cursor(entity_ctx, asset_ctx)

    load_many_sprites(asset_ctx, "skeleton_default_walk_E_0.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_N_90.")

    SetTargetFPS(60)

    HideCursor()
    
    swap: bool = false
    delta_time: f32 = 0.0

    entity: ^Entity;
    
    for !WindowShouldClose() {
        entity_ctx.delta_time = GetFrameTime() * 1000

        BeginDrawing()
        ClearBackground(RAYWHITE)
        
        update_sprite_collection_system(entity_ctx)
        update_sprite_system(entity_ctx)      
        update_health_system(entity_ctx)
        update_physics_system(&game_ctx)

        if IsMouseButtonPressed(MouseButton.LEFT) {
            if(entity != nil) {
                free_entity(entity)
            }

            entity = make_skeleton(entity_ctx, asset_ctx, cast(f32)GetMouseX(), cast(f32)GetMouseY())
        }

        if IsMouseButtonPressed(MouseButton.RIGHT) {
            if entity != nil {
                // Whack entity randomly
                physics_apply_force(entity, vec2_rnd(500000))
            }
        }

        if IsKeyDown(KeyboardKey.LEFT) {
            if entity != nil {
                physics_set_force(entity, raylib.Vector2{ -10, 0 })
            }
        }

        if IsKeyDown(KeyboardKey.RIGHT) {
            if entity != nil {
                physics_set_force(entity, raylib.Vector2{ 10, 0 })
            }
        }

        if IsKeyDown(KeyboardKey.UP) {
            if entity != nil {
                physics_set_force(entity, raylib.Vector2{ 0, -10 })
            }
        }

        if IsKeyDown(KeyboardKey.DOWN) {
            if entity != nil {
                physics_set_force(entity, raylib.Vector2{ 0, 10 })
            }
        }

        // Debug info
        when ODIN_DEBUG {
            // Draw total memory usage
            mem_total := 0
            for _, entry in track.allocation_map {
                mem_total += entry.size
            }

            builder := strings.builder_make()

            strings.builder_reset(&builder)
            fmt.sbprintf(&builder, "Mem: %v KB", mem_total / 1024)
            text:= strings.unsafe_string_to_cstring(strings.to_string(builder))
            DrawText(text, 10, 10, 20, BLACK)
            strings.builder_destroy(&builder)
        
            // Draw delta time
            strings.builder_reset(&builder)
            fmt.sbprintf(&builder, "Delta: %v", delta_time)
            text = strings.unsafe_string_to_cstring(strings.to_string(builder))
            DrawText(text, 10, 30, 20, BLACK)
            strings.builder_destroy(&builder)

            // Draw entity count
            strings.builder_reset(&builder)
            fmt.sbprintf(&builder, "Ents: %v", len(entity_ctx.entities))
            text = strings.unsafe_string_to_cstring(strings.to_string(builder))
            DrawText(text, 10, 50, 20, BLACK)
            strings.builder_destroy(&builder)
            
            // Draw asset count
            strings.builder_reset(&builder)
            fmt.sbprintf(&builder, "Assets: %v", len(asset_ctx.assets))
            text = strings.unsafe_string_to_cstring(strings.to_string(builder))
            DrawText(text, 10, 70, 20, BLACK)
            strings.builder_destroy(&builder)

            // Draw Texture Map cache count
            strings.builder_reset(&builder)
            fmt.sbprintf(&builder, "Tex Cache: %v", len(asset_ctx.texture_cache))
            text = strings.unsafe_string_to_cstring(strings.to_string(builder))
            DrawText(text, 10, 90, 20, BLACK)
            strings.builder_destroy(&builder)

            // Draw FPS
            strings.builder_reset(&builder)
            fmt.sbprintf(&builder, "FPS: %v", GetFPS())
            text = strings.unsafe_string_to_cstring(strings.to_string(builder))
            DrawText(text, 10, 110, 20, BLACK)
            strings.builder_destroy(&builder)
        }

        update_cursor(cursor);

        
        EndDrawing()
    }
    
    mem.tracking_allocator_destroy(&track)
    CloseWindow()
}

make_skeleton :: proc(entity_ctx: ^ecs.Entity_Context, asset_ctx: ^asset.Asset_Context, x: f32, y: f32) -> ^ecs.Entity {
    using ecs
    
    skeleton:= make_entity(entity_ctx)
    health:= get_component(skeleton, Health)
    cooldowns:= make_cooldowns(skeleton)
    add_cooldown(skeleton, "test", 0.1)

    health.max_health = 100
    health.health = 100

    transform:= get_component(skeleton, Transformation)
    add_and_load_sprite_collection(asset_ctx, skeleton, "skeleton_default_walk_E_0.", 100)
    transform.pos = raylib.Vector2{ x - transform.origin.x, y - transform.origin.y }

    physics:= get_component(skeleton, Physics)

    physics.velocity = vec2_zero()
    physics.max_velocity = 100
    physics.acceleration = vec2_zero()
    physics.friction = 0.9
    physics.mass = 100

    //ecs.debug_set_component(skeleton, ecs.Base_Texture, true)
    return skeleton
}