add_executable(intro main.cpp)

target_link_libraries(
  intro
  PRIVATE factrory_craft::factrory_craft_options
          factrory_craft::factrory_craft_warnings)

target_link_system_libraries(
  intro
  PRIVATE
          fmt::fmt
          spdlog::spdlog)

target_include_directories(intro PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
