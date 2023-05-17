include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(factrory_craft_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(factrory_craft_setup_options)
  option(factrory_craft_ENABLE_HARDENING "Enable hardening" ON)
  option(factrory_craft_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    factrory_craft_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    factrory_craft_ENABLE_HARDENING
    OFF)

  factrory_craft_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR factrory_craft_PACKAGING_MAINTAINER_MODE)
    option(factrory_craft_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(factrory_craft_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(factrory_craft_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(factrory_craft_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(factrory_craft_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(factrory_craft_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(factrory_craft_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(factrory_craft_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(factrory_craft_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(factrory_craft_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(factrory_craft_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(factrory_craft_ENABLE_PCH "Enable precompiled headers" OFF)
    option(factrory_craft_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(factrory_craft_ENABLE_IPO "Enable IPO/LTO" ON)
    option(factrory_craft_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(factrory_craft_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(factrory_craft_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(factrory_craft_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(factrory_craft_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(factrory_craft_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(factrory_craft_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(factrory_craft_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(factrory_craft_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(factrory_craft_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(factrory_craft_ENABLE_PCH "Enable precompiled headers" OFF)
    option(factrory_craft_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      factrory_craft_ENABLE_IPO
      factrory_craft_WARNINGS_AS_ERRORS
      factrory_craft_ENABLE_USER_LINKER
      factrory_craft_ENABLE_SANITIZER_ADDRESS
      factrory_craft_ENABLE_SANITIZER_LEAK
      factrory_craft_ENABLE_SANITIZER_UNDEFINED
      factrory_craft_ENABLE_SANITIZER_THREAD
      factrory_craft_ENABLE_SANITIZER_MEMORY
      factrory_craft_ENABLE_UNITY_BUILD
      factrory_craft_ENABLE_CLANG_TIDY
      factrory_craft_ENABLE_CPPCHECK
      factrory_craft_ENABLE_COVERAGE
      factrory_craft_ENABLE_PCH
      factrory_craft_ENABLE_CACHE)
  endif()

  factrory_craft_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (factrory_craft_ENABLE_SANITIZER_ADDRESS OR factrory_craft_ENABLE_SANITIZER_THREAD OR factrory_craft_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(factrory_craft_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(factrory_craft_global_options)
  if(factrory_craft_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    factrory_craft_enable_ipo()
  endif()

  factrory_craft_supports_sanitizers()

  if(factrory_craft_ENABLE_HARDENING AND factrory_craft_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR factrory_craft_ENABLE_SANITIZER_UNDEFINED
       OR factrory_craft_ENABLE_SANITIZER_ADDRESS
       OR factrory_craft_ENABLE_SANITIZER_THREAD
       OR factrory_craft_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${factrory_craft_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${factrory_craft_ENABLE_SANITIZER_UNDEFINED}")
    factrory_craft_enable_hardening(factrory_craft_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(factrory_craft_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(factrory_craft_warnings INTERFACE)
  add_library(factrory_craft_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  factrory_craft_set_project_warnings(
    factrory_craft_warnings
    ${factrory_craft_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(factrory_craft_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(factrory_craft_options)
  endif()

  include(cmake/Sanitizers.cmake)
  factrory_craft_enable_sanitizers(
    factrory_craft_options
    ${factrory_craft_ENABLE_SANITIZER_ADDRESS}
    ${factrory_craft_ENABLE_SANITIZER_LEAK}
    ${factrory_craft_ENABLE_SANITIZER_UNDEFINED}
    ${factrory_craft_ENABLE_SANITIZER_THREAD}
    ${factrory_craft_ENABLE_SANITIZER_MEMORY})

  set_target_properties(factrory_craft_options PROPERTIES UNITY_BUILD ${factrory_craft_ENABLE_UNITY_BUILD})

  if(factrory_craft_ENABLE_PCH)
    target_precompile_headers(
      factrory_craft_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(factrory_craft_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    factrory_craft_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(factrory_craft_ENABLE_CLANG_TIDY)
    factrory_craft_enable_clang_tidy(factrory_craft_options ${factrory_craft_WARNINGS_AS_ERRORS})
  endif()

  if(factrory_craft_ENABLE_CPPCHECK)
    factrory_craft_enable_cppcheck(${factrory_craft_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(factrory_craft_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    factrory_craft_enable_coverage(factrory_craft_options)
  endif()

  if(factrory_craft_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(factrory_craft_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(factrory_craft_ENABLE_HARDENING AND NOT factrory_craft_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR factrory_craft_ENABLE_SANITIZER_UNDEFINED
       OR factrory_craft_ENABLE_SANITIZER_ADDRESS
       OR factrory_craft_ENABLE_SANITIZER_THREAD
       OR factrory_craft_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    factrory_craft_enable_hardening(factrory_craft_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
