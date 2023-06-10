add_executable(HelloWorld main.cpp)



target_link_libraries(
        HelloWorld
        PRIVATE factrory_craft::factrory_craft_options
        factrory_craft::factrory_craft_warnings
        factrory_craft::lib
        )

target_link_system_libraries(
        HelloWorld
        PRIVATE
        fmt::fmt
        spdlog::spdlog)

target_include_directories(HelloWorld PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")