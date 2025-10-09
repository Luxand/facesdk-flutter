#ifndef CONVERTER
#define CONVERTER

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

FFI_PLUGIN_EXPORT void YUV420ToRGBA(const unsigned char*,
                             const unsigned char*,
                             const unsigned char*,
                             const int,
                             const int,
                             const int,
                             const int,
                             unsigned char*);

FFI_PLUGIN_EXPORT void BGRAToRGBA(const unsigned char*, const int, const int, const int, unsigned char*);

#endif
