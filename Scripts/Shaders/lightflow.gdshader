shader_type canvas_item;

// 流光参数
uniform float frequency = 2.0;
uniform float speed = 1.0;
uniform float width = 0.2;
uniform vec4 stream_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 bg_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float gradient_sharpness = 2.0; // 渐变锐度

void fragment() {
    vec2 uv = UV;
    
    // 创建流光效果
    float stream = sin(uv.x * frequency - TIME * speed);
    
    // 使用指数函数创建更自然的渐变效果
    float stream_strength = pow(abs(stream), gradient_sharpness);
    
    // 调整宽度
    stream_strength = smoothstep(1.0 - width, 1.0, stream_strength);
    
    // 混合颜色
    vec4 final_color = mix(bg_color, stream_color, stream_strength);
    
    COLOR = final_color;
}