#include <stddef.h>
#include "flutter_face_sdk.h"

char clip(const int value) {
    return value > 255 ? 255 : value < 0 ? 0 : value;
}

void set_color(unsigned char** p, const unsigned char* y, const int r, const int g, const int b) {
    const int cy = *(y++);
    *((*p)++) = clip(cy + r);
    *((*p)++) = clip(cy - g);
    *((*p)++) = clip(cy + b);
}

FFI_PLUGIN_EXPORT void YUV420ToRGB(const unsigned char* y,
                                   const unsigned char* u,
                                   const unsigned char* v,
                                   const int width,
                                   const int height,
                                   const int pp,
                                   const int pr,
                                   unsigned char* rgb) {
    for (size_t i = 0; i < width; ++i)
        for (size_t j = 0; j < height; ++j) {
            const size_t y_index = j * pr + i;
            const size_t uv_index = pp * (i / 2) + pr * (j / 2);
            const size_t index = j * width + i;

            const int yp = y[ y_index];
            const int up = u[uv_index];
            const int vp = v[uv_index];

            rgb[index * 3 + 0] = clip(yp + (1436 * vp >> 10) - 179);
            rgb[index * 3 + 1] = clip(yp - ((46549 * up + 93604 * vp) >> 17) + 135);
            rgb[index * 3 + 2] = clip(yp + (1814 * up >> 10) - 227);
        }
}

FFI_PLUGIN_EXPORT void BGRAToRGB(const unsigned char* bgra,
                                 const int width,
                                 const int height,
                                 const int row_bytes,
                                 unsigned char* rgb) {
    for (size_t i = 0; i < height; ++i, bgra += row_bytes) {
        const unsigned char* data = bgra;
        for (size_t j = 0; j < width; ++j, data += 4, rgb += 3) {
            rgb[0] = data[2];
            rgb[1] = data[1];
            rgb[2] = data[0];
        }
    }
}
