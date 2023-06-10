find_package(SDL2 REQUIRED)

add_library(factrory_craft_lib src/foo.cpp)
add_library(factrory_craft::lib ALIAS factrory_craft_lib)

target_link_libraries(factrory_craft_lib PRIVATE factrory_craft_options factrory_craft_warnings ${SDL2_LIBRARIES})

target_include_directories(factrory_craft_lib ${WARNING_GUARD} PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/lib/include>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
        ${SDL2_INCLUDE_DIRS})

target_compile_features(factrory_craft_lib PUBLIC cxx_std_20)

set_target_properties(
        factrory_craft_lib
        PROPERTIES VERSION ${PROJECT_VERSION}
        CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN YES)

