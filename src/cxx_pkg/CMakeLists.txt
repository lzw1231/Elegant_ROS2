# ============================================================================
# 固定配置（通常无需修改）
# ============================================================================

cmake_minimum_required(VERSION 4.2)

project(cxx_pkg)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../cmake")
include(add_cxx_node)

# ============================================================================
# 手动配置区域（额外依赖、节点添加）
# ============================================================================

# find_package(example_interfaces REQUIRED)
# find_package(std_msgs REQUIRED)

add_cxx_node(cxx_node)
# add_cxx_node(demo_node)
# add_cxx_node(demo_node DEPENDS example_interfaces std_msgs)

# ============================================================================
# 测试与打包（通常无需修改）
# ============================================================================

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  set(ament_cmake_copyright_FOUND TRUE)
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
