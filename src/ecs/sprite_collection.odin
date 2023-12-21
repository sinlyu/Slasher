package ecs
import "../raylib"
import "../asset"
import "core:fmt"
import "core:slice"


add_and_load_sprite_collection :: proc(asset_ctx: ^asset.Asset_Context, entity: ^Entity, prefix: string, frame_time: f32 = 100) {
    using asset
    
    // Find all Assets with the prefix
    filtered_assets := filter_assets(asset_ctx, Asset_Type.TEXTURE, prefix)
    slice.sort_by(filtered_assets[:], proc(a, b: ^Asset) -> bool {
        return a.name < b.name
    })

    entity.sprite_collection_frame_time = frame_time

    // Allocate the textures array
    entity.sprite_collection_textures = make([dynamic]^raylib.Texture2D, len(filtered_assets))
    entity.sprite_collection_frame_count = cast(i32)len(filtered_assets)

    // Load all the textures
    for i := 0; i < len(filtered_assets); i+=1 {
        asset := filtered_assets[i]
        entity.sprite_collection_textures[i] = load_asset(asset_ctx, asset.name, raylib.Texture2D)
    }

    // Set the Base_Texture to the first texture
    entity.texture = entity.sprite_collection_textures[0]

    // Update Transform origin
    entity.transform_origin = raylib.Vector2 {
        cast(f32)entity.texture.width,
        cast(f32)entity.texture.height,
    }
}

load_many_sprites :: proc(asset_ctx: ^asset.Asset_Context, prefix: string) -> [dynamic]^raylib.Texture2D {
    using asset

    fmt.println("Loading sprites: ", prefix)

    // Check if we already have the textures loaded
    if asset_ctx.texture_cache[prefix] != nil {
        return asset_ctx.texture_cache[prefix]
    }

    fmt.println(asset_ctx.texture_cache[prefix])
    fmt.println("Textures not cached, loading...")

    textures := make([dynamic]^raylib.Texture2D)

     // Find all Assets with the prefix
     filtered_assets := filter_assets(asset_ctx, Asset_Type.TEXTURE, prefix)
     slice.sort_by(filtered_assets[:], proc(a, b: ^Asset) -> bool {
         return a.name < b.name
     })

      // Load all the textures
    for i := 0; i < len(filtered_assets); i+=1 {
        asset := filtered_assets[i]
        texture:= load_asset(asset_ctx, asset.name, raylib.Texture2D)
        append(&textures, texture)
    }

    // Cache the textures
    asset_ctx.texture_cache[prefix] = textures

    return textures
}

change_sprite_collection_items :: proc(entity: ^Entity, textures: [dynamic]^raylib.Texture2D) {
    entity.sprite_collection_textures = textures
    entity.sprite_collection_frame_count = cast(i32)len(textures)
    entity.sprite_collection_frame_time = 100
}