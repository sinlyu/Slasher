package main

import "core:fmt"
import "core:strings"
import "core:mem"
import "raylib"
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

    when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)
    }

    width: i32 = 800
    height: i32 = 600

    SetTargetFPS(60)

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
    load_many_sprites(asset_ctx, "skeleton_default_walk_NNW_112.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_W_180.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_NE_45.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_NEE_22.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_SSE_292.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_NNE_67.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_NW_135.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_NWW_157.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_SE_315.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_SEE_337.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_S_270.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_SSW_247.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_SW_225.")
    load_many_sprites(asset_ctx, "skeleton_default_walk_SWW_202.")

    HideCursor()
    
    swap: bool = false
    delta_time: f32 = 0.0

    entity: ^Entity;

    for !WindowShouldClose() {
        game_ctx.delta_time = GetFrameTime() * 1000

        BeginDrawing()
        ClearBackground(RAYWHITE)

        for entity, i in entity_ctx.entities {
            if cast(i32)i >= entity_ctx.next_id { continue }
            ent_ptr := &entity_ctx.entities[i]
            update_sprite_collection(&game_ctx, ent_ptr)
            update_sprite(&game_ctx, ent_ptr)
            update_health(&game_ctx, ent_ptr)
            draw_health(&game_ctx, ent_ptr)
            update_physics(&game_ctx, ent_ptr)
        }

        if IsMouseButtonPressed(MouseButton.LEFT) {
            if(entity != nil) {
                free_entity(entity)
            }

            entity = make_skeleton(entity_ctx, asset_ctx, cast(f32)GetMouseX(), cast(f32)GetMouseY())
        }

        // TODO: (Linux) Mouse button presses kills the frame rate
        if IsMouseButtonPressed(MouseButton.RIGHT) {
            if entity != nil {
                // Whack entity randomly
                physics_apply_force(entity, vec2_rnd_range(-10000, 10000))
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

            mem:= TextFormat("Memory: %v KB", mem_total / 1024)
            DrawText(mem, 10, 10, 20, BLACK)
            delete(mem)
        
            // Draw delta time
            delta_time:= TextFormat("Delta Time: %v", game_ctx.delta_time)
            DrawText(delta_time, 10, 30, 20, BLACK)
            delete(delta_time)
            
            // Draw asset count
            asset_count:= TextFormat("Assets: %v", len(asset_ctx.assets))
            DrawText(asset_count, 10, 70, 20, BLACK)
            delete(asset_count)

            // Draw Texture Map cache count
            tex_cache_count:= TextFormat("Tex Cache: %v", len(asset_ctx.texture_cache))
            DrawText(tex_cache_count, 10, 90, 20, BLACK)
            delete(tex_cache_count)

            // Draw FPS
            fps:= TextFormat("FPS: %v", GetFPS())
            DrawText(fps, 10, 110, 20, BLACK)
            delete(fps)
        }

        update_cursor(cursor);
        
        EndDrawing()
    }
    
    when ODIN_DEBUG {
        mem.tracking_allocator_destroy(&track)
    }

    CloseWindow()
}

make_skeleton :: proc(entity_ctx: ^ecs.Entity_Context, asset_ctx: ^asset.Asset_Context, x: f32, y: f32) -> ^ecs.Entity {
    using ecs
    
    entity:= make_entity(entity_ctx)
    add_cooldown(entity, "test", 0.1)

    entity.current_health = 100
    entity.max_health = 100

    add_and_load_sprite_collection(asset_ctx, entity, "skeleton_default_walk_E_0.", 100)
    entity.transform_position = raylib.Vector2{ x - entity.transform_origin.x, y - entity.transform_origin.y }

    entity.hitbox_height = 80
    entity.hitbox_width = 40

    entity.physics_velocity = vec2_zero()
    entity.physics_max_velocity = 100
    entity.physics_acceleration = vec2_zero()
    entity.physics_friction = 0.9
    entity.physics_mass = 50

    entity.debug = false

    return entity
}