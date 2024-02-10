#include <stdint.h>

// Redefine the resolution objects so we can export the constants
#define RESOLUTION_256x240 _RESOLUTION_256x240
#define RESOLUTION_320x240 _RESOLUTION_320x240
#define RESOLUTION_512x240 _RESOLUTION_512x240
#define RESOLUTION_640x240 _RESOLUTION_640x240
#define RESOLUTION_512x480 _RESOLUTION_512x480
#define RESOLUTION_640x480 _RESOLUTION_640x480
#include "display.h"
#undef RESOLUTION_256x240
#undef RESOLUTION_320x240
#undef RESOLUTION_512x240
#undef RESOLUTION_640x240
#undef RESOLUTION_512x480
#undef RESOLUTION_640x480

const resolution_t RESOLUTION_256x240 = _RESOLUTION_256x240;
const resolution_t RESOLUTION_320x240 = _RESOLUTION_320x240;
const resolution_t RESOLUTION_512x240 = _RESOLUTION_512x240;
const resolution_t RESOLUTION_640x240 = _RESOLUTION_640x240;
const resolution_t RESOLUTION_512x480 = _RESOLUTION_512x480;
const resolution_t RESOLUTION_640x480 = _RESOLUTION_640x480;

void display_init_r( resolution_t* res, bitdepth_t bit, uint32_t num_buffers, gamma_t gamma, filter_options_t filters ) {
    display_init(*res, bit, num_buffers, gamma, filters);
}

#include "graphics.h"
uint32_t graphics_convert_color_r( color_t* color ) {
    return graphics_convert_color(*color);
}

#include "sprite.h"
void sprite_get_pixels_r(surface_t* surface_ret, sprite_t* sprite) {
    *surface_ret = sprite_get_pixels(sprite);
}

void sprite_get_lod_pixels_r(surface_t* surface_ret, sprite_t* sprite, int num_level) {
    *surface_ret = sprite_get_lod_pixels(sprite, num_level);
}

void sprite_get_detail_pixels_r(surface_t* surface_ret, sprite_t* sprite, sprite_detail_t* info, rdpq_texparms_t* infoparms) {
    *surface_ret = sprite_get_detail_pixels(sprite, info, infoparms);
}

void sprite_get_tile_r(surface_t* surface_ret, sprite_t* sprite, int h, int v) {
    *surface_ret = sprite_get_tile(sprite, h, v);
}

#include "surface.h"
void surface_alloc_r(surface_t* surface_ret, tex_format_t format, uint32_t width, uint32_t height) {
    *surface_ret = surface_alloc(format, width, height);
}
void surface_make_sub_r(surface_t* surface_ret, surface_t* parent, uint32_t x0, uint32_t y0, 
                        uint32_t width, uint32_t height) {
    *surface_ret = surface_make_sub(parent, x0, y0, width, height);
}

#include "rdpq.h"
#include "rdpq_debug.h"
void rdpq_debug_get_tmem_r(surface_t* s) {
    *s = rdpq_debug_get_tmem();
}

#include "rspq.h"
void rspq_write_begin_r(rspq_write_t* w, uint32_t ovl_id, uint32_t cmd_id, int size) {
    *w = rspq_write_begin(ovl_id, cmd_id, size);
}

void rspq_write_arg_r(rspq_write_t* w, uint32_t value) {
    rspq_write_arg(w, value);
}

void rspq_write_end_r(rspq_write_t* w) {
    rspq_write_end(w);
}

#include "yuv.h"
void yuv_new_colorspace_r(yuv_colorspace_t* res, float Kr, float Kb, int y0, int yrange, int crange) {
    *res = yuv_new_colorspace(Kr, Kb, y0, yrange, crange);
}
