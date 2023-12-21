package ecs
import "../raylib"
import "../asset"
import "core:fmt"
import "core:slice"

Sprite_Collection :: struct {
    using base: Component,
    textures: [dynamic]^raylib.Texture2D,
    frame_index: i32,
    frame_count: i32,
    frame_time: f32,
    current_time: f32,
}

add_and_load_sprite_collection :: proc(asset_ctx: ^asset.Asset_Context, entity: ^Entity, prefix: string, frame_time: f32 = 100) {
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
    collection.frame_time = frame_time

    // Allocate the textures array
    collection.textures = make([dynamic]^raylib.Texture2D, len(filtered_assets))
    collection.frame_count = cast(i32)len(filtered_assets)

    // Load all the textures
    for i := 0; i < len(filtered_assets); i+=1 {
        asset := filtered_assets[i]
        collection.textures[i] = load_asset(asset_ctx, asset.name, raylib.Texture2D)
    }

    // Set the Base_Texture to the first texture
    texture.texture = collection.textures[0]

    // Update Transform origin
    transform := get_component(entity, Transformation)
    transform.origin = raylib.Vector2 {
        cast(f32)texture.texture.width,
        cast(f32)texture.texture.height,
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
    collection := get_component(entity, Sprite_Collection)
    collection.textures = textures
    collection.frame_count = cast(i32)len(textures)
    collection.frame_time = 100

    // TODO: Check if we have the same amount of textures / frame count
}