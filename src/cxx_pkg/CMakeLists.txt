# ============================================================================
# 固定配置（通常无需修改）
# ============================================================================

cmake_minimum_required(VERSION 4.2)

# 自定义 ROS2 功能包名
project(cxx_pkg)

# C/C++ 语言标准
set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 编译选项（GCC / Clang）
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# ROS 2 基础依赖（固定）
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)

# 加载自定义函数模块
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../cmake")
include(add_ros2_node)

# ============================================================================
# 手动配置区域（额外依赖、节点添加）
# ============================================================================

# 额外依赖包（按需取消注释）
# find_package(example_interfaces REQUIRED)
# find_package(std_msgs REQUIRED)

# 添加可执行节点（默认依赖 rclcpp，可通过 DEPENDS 指定额外依赖）
add_ros2_node(cxx_node)
# add_ros2_node(demo_node)
# add_ros2_node(demo_node DEPENDS example_interfaces std_msgs)

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
