shader_type canvas_item;

uniform vec4 cor_aviso : source_color = vec4(1.0);
uniform bool pisca = true;

void fragment() {
	if (pisca) {
		COLOR.rgb = cor_aviso.rgb;
	}
}
