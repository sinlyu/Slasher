package asset
import "../raylib"
import "core:fmt"
import "core:strings"
import "core:runtime"
import "core:os"

ASSET_PATH :: "assets"


Asset_Context :: struct {
    assets: map[string]^Asset,
    asset_type_registers: map[string]^Asset_Type_Register,
    texture_cache: map[string][dynamic]^raylib.Texture2D
}

Asset :: struct {
    name: string,
    path: string,
    loaded: bool,
    data: runtime.Raw_Any
}

Asset_Type :: enum {
    TEXTURE,
}

Asset_Type_Register :: struct {
    name: string,
    extension: string,
    type: typeid,
    asset_type: Asset_Type,
    load_callback: proc(asset: ^Asset) -> ^runtime.Raw_Any
}

init_asset_context :: proc() -> Asset_Context {
    asset_context:= Asset_Context{}
    asset_context.assets = make(map[string]^Asset)
    asset_context.texture_cache = make(map[string][dynamic]^raylib.Texture2D)

    register_asset_types(&asset_context)
    
    return asset_context
}

register_asset_types :: proc(asset_context: ^Asset_Context) {
    asset_context.asset_type_registers = make(map[string]^Asset_Type_Register)
    
    // Image formats
    register_asset_type(asset_context, "png", Asset_Type.TEXTURE, load_image_asset)
    register_asset_type(asset_context, "jpg", Asset_Type.TEXTURE, load_image_asset)
    register_asset_type(asset_context, "jpeg", Asset_Type.TEXTURE, load_image_asset)
    register_asset_type(asset_context, "bmp", Asset_Type.TEXTURE, load_image_asset)
}

register_asset_type :: proc(asset_context: ^Asset_Context, extension: string, asset_type: Asset_Type, load_callback: proc(asset: ^Asset) -> $T) {
    asset_type_register, err := new(Asset_Type_Register)
    asset_type_register.name = extension
    asset_type_register.extension = extension
    asset_type_register.asset_type = asset_type
    asset_type_register.load_callback = load_callback

    // Handle types
    // TODO: find a better way to do this
    if(asset_type == Asset_Type.TEXTURE) {
        asset_type_register.type = raylib.Texture2D
    }
    
    asset_context.asset_type_registers[extension] = asset_type_register
}

register_asset :: proc (ctx: ^Asset_Context, name: string, path: string) -> ^Asset
{
    asset := new(Asset)
    asset.name = name
    asset.path = path
    asset.loaded = false
    
    ctx.assets[name] = asset

    return asset
}

auto_register_assets :: proc(ctx: ^Asset_Context, path: string) {
    fd, err := os.open(path, os.O_RDONLY)
    
    defer os.close(fd)
    fi, err2 := os.read_dir(fd, 0)

    for entry in fi {
        // Skip directories
        if entry.is_dir {
            continue
        }

        // Skip hidden files
        if strings.index(entry.name, ".") == 0 {
            continue
        }

        // Skip files without an extension
        if strings.index(entry.name, ".") == -1 {
            continue
        }

        // Remove the extension from the name
        name_parts := strings.split(entry.name, ".")
        // Remove last part
        name_parts = name_parts[:len(name_parts) - 1]
        name := strings.join(name_parts, ".")
        
        relative_path := strings.join([]string{path, entry.name}, "/")
        
        register_asset(ctx, name, relative_path)
        os.file_info_delete(entry)

        delete(name_parts)
    }
    delete(fi)
}

get_asset_register :: proc(ctx: ^Asset_Context, asset: ^Asset) -> ^Asset_Type_Register {
   file_parts := strings.split(asset.path, ".")
   extension := file_parts[len(file_parts) - 1]

   asset_type_register := ctx.asset_type_registers[extension]
   
   delete(file_parts)
 
   return asset_type_register
}

load_asset :: proc(ctx: ^Asset_Context, name: string, $T: typeid) -> ^T {
    asset := ctx.assets[name]

    // If the asset is already loaded, we take the fast path
    if(asset.loaded) {
        return cast(^T)&asset.data
    }
    
    asset_type_register := get_asset_register(ctx, asset)
    asset_data := asset_type_register.load_callback(asset)

    asset.data = asset_data^
    asset.loaded = true
    return cast(^raylib.Texture2D)&asset.data
}

filter_assets :: proc(ctx: ^Asset_Context, asset_type: Asset_Type, query: string) -> [dynamic]^Asset {
    assets := [dynamic]^Asset{}
    for name, asset in ctx.assets {
        asset_type_register := get_asset_register(ctx, asset)
        if(asset_type_register.asset_type == asset_type && strings.index(name, query) == 0) {
            append(&assets, asset)
        }
    }
    return assets
}

load_image_asset :: proc(asset: ^Asset) -> ^runtime.Raw_Any {
    texture := raylib.LoadTexture(strings.unsafe_string_to_cstring(asset.path))
    asset.loaded = true
    return cast(^runtime.Raw_Any)&texture
}