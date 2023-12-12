package ecs
import "vendor:raylib"
import "../asset"
import "core:fmt"
import "core:slice"

Sprite_Collection :: struct {
    using base: Component,
    textures: [dynamic]^raylib.Texture2D,
    frame_index: i32,
    frame_count: i32,
    frame_time: i32,
}

add_and_load_sprite_collection :: proc(asset_ctx: ^asset.Asset_Context, entity: ^Entity, prefix: string) {
    using asset
    
    // Find all Assets with the prefix
    filtered_assets := filter_assets(asset_ctx, Asset_Type.TEXTURE, prefix)
    slice.sort_by(filtered_assets[:], proc(a, b: ^Asset) -> bool {
        return a.name < b.name
    })

    // Create a new Sprite_Collection
    // Each Sprite based component needs a Base_Texture
    texture := get_component(entity, Base_Texture)
    collection := get_component(entity, Sprite_Collection)

    // Allocate the textures array
    collection.textures = make([dynamic]^raylib.Texture2D, len(filtered_assets))
    collection.frame_count = cast(i32)len(filtered_assets)

    // Load all the textures
    for i := 0; i < len(filtered_assets); i+=1 {
        asset := filtered_assets[i]
        fmt.printf("Loading %s\n", asset.name)
        collection.textures[i] = load_asset(asset_ctx, asset.name, raylib.Texture2D)
    }

    // Set the Base_Texture to the first texture
    texture.texture = collection.textures[0]
}

load_many_sprites :: proc(asset_ctx: ^asset.Asset_Context, entity: ^Entity, prefix: string) -> [dynamic]^raylib.Texture2D {
    using asset

    // Check if we already have the textures loaded
    if asset_ctx.texture_cache[prefix] != nil {
        return asset_ctx.texture_cache[prefix]
    }


    textures := make([dynamic]^raylib.Texture2D)

     // Find all Assets with the prefix
     filtered_assets := filter_assets(asset_ctx, Asset_Type.TEXTURE, prefix)
     slice.sort_by(filtered_assets[:], proc(a, b: ^Asset) -> bool {
         return a.name < b.name
     })

      // Load all the textures
    for i := 0; i < len(filtered_assets); i+=1 {
        asset := filtered_assets[i]
        fmt.printf("Loading %s\n", asset.name)
        texture:= load_asset(asset_ctx, asset.name, raylib.Texture2D)
        append(&textures, texture)
    }

    // Cache the textures
    asset_ctx.texture_cache[prefix] = textures

    return textures
}

change_sprite_collection_items :: proc(entity: ^Entity, textures: [dynamic]^raylib.Texture2D) {
    collection := get_component(entity, Sprite_Collection)
    collection.textures = textures
    collection.frame_count = cast(i32)len(textures)
    collection.frame_index = 0
}