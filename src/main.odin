package main

import "core:fmt"
import "core:strings"
import "core:mem"
import "vendor:raylib"
import "ecs"
import "systems"
import "asset"

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

    entity_ctx: ^Entity_Context = init_entity_context()
    asset_ctx: ^Asset_Context = init_asset_context()

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
    SetTargetFPS(60)

    cursor:= make_cursor(entity_ctx, asset_ctx)
    skeleton:= make_entity(entity_ctx)


    load_many_sprites(asset_ctx, skeleton, "skeleton_default_walk_E_0.")
    load_many_sprites(asset_ctx, skeleton, "skeleton_default_walk_N_90.")

    add_and_load_sprite_collection(asset_ctx, skeleton, "skeleton_default_walk_E_0.")
    debug_set_component(skeleton, Base_Texture, true)

    skeleton.pos = pos_with_origin(skeleton, 400, 300)

    HideCursor()
    
    swap: bool = false
    delta_time: f32 = 0.0
    
    for !WindowShouldClose() {
        delta_time = GetFrameTime() * 1000

        BeginDrawing()
        ClearBackground(RAYWHITE)

        update_cursor(cursor);
        
        update_sprite_collection_system(entity_ctx)  
        update_sprite_system(entity_ctx)      

        if IsKeyPressed(KeyboardKey.LEFT) {
            swap = !swap
            if swap {
                change_sprite_collection_items(skeleton, load_many_sprites(asset_ctx, skeleton, "skeleton_default_walk_N_90."))
            } else {
                change_sprite_collection_items(skeleton, load_many_sprites(asset_ctx, skeleton, "skeleton_default_walk_E_0."))
            }
        }

        // Debug info
        when ODIN_DEBUG {
            // Draw total memory usage
            mem_total := 0
            for _, entry in track.allocation_map {
                mem_total += entry.size
            }

            mem_total_builder := strings.builder_make()
            defer strings.builder_destroy(&mem_total_builder)
            fmt.sbprintf(&mem_total_builder, "Mem: %v KB", mem_total / 1024)
            text:= strings.unsafe_string_to_cstring(strings.to_string(mem_total_builder))
            DrawText(text, 10, 10, 20, BLACK)

        
            // Draw delta time
            delta_time_builder := strings.builder_make()
            defer strings.builder_destroy(&delta_time_builder)
            fmt.sbprintf(&delta_time_builder, "Delta: %v", delta_time)
            text = strings.unsafe_string_to_cstring(strings.to_string(delta_time_builder))
            DrawText(text, 10, 30, 20, BLACK)


            // Draw entity count
            entity_count_builder := strings.builder_make()
            defer strings.builder_destroy(&entity_count_builder)
            fmt.sbprintf(&entity_count_builder, "Ents: %v", len(entity_ctx.entities))
            text = strings.unsafe_string_to_cstring(strings.to_string(entity_count_builder))
            DrawText(text, 10, 50, 20, BLACK)

            
            // Draw asset count
            sprite_count_builder := strings.builder_make()
            defer strings.builder_destroy(&sprite_count_builder)
            fmt.sbprintf(&sprite_count_builder, "Assets: %v", len(asset_ctx.assets))
            text = strings.unsafe_string_to_cstring(strings.to_string(sprite_count_builder))
            DrawText(text, 10, 70, 20, BLACK)


            // Draw Texture Map cache count
            texture_cache_count_builder := strings.builder_make()
            defer strings.builder_destroy(&texture_cache_count_builder)
            fmt.sbprintf(&texture_cache_count_builder, "Tex Cache: %v", len(asset_ctx.texture_cache))
            text = strings.unsafe_string_to_cstring(strings.to_string(texture_cache_count_builder))
            DrawText(text, 10, 90, 20, BLACK)


            // Draw FPS
            fps_builder := strings.builder_make()
            defer strings.builder_destroy(&fps_builder)
            fmt.sbprintf(&fps_builder, "FPS: %v", GetFPS())
            text = strings.unsafe_string_to_cstring(strings.to_string(fps_builder))
            DrawText(text, 10, 110, 20, BLACK)
        }

        EndDrawing()
    }
    
    mem.tracking_allocator_destroy(&track)
    CloseWindow()
}