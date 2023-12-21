package helper
import "../raylib"

tex_multiplier :: proc() -> f32 {
    return 2.0;
}

tex_width :: proc(texture: ^raylib.Texture2D) -> f32 {
    return cast(f32)texture.width * tex_multiplier();
}

tex_height :: proc(texture: ^raylib.Texture2D) -> f32 {
    return cast(f32)texture.height * tex_multiplier();
}