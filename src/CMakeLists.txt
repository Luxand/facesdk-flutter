# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(flutter_face_sdk_library VERSION 0.0.1 LANGUAGES C)

add_library(flutter_face_sdk SHARED
  "flutter_face_sdk.c"
)

set_target_properties(flutter_face_sdk PROPERTIES
  PUBLIC_HEADER flutter_face_sdk.h
  OUTPUT_NAME "flutter_face_sdk"
)

target_compile_definitions(flutter_face_sdk PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size.
  target_link_options(flutter_face_sdk PRIVATE "-Wl,-z,max-page-size=16384")
endif()
