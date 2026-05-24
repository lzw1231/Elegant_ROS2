# ============================================================================
# CMakeLists.txt
# ROS2 C++ 包主文件，显式声明所需依赖
# ============================================================================

# cmake 所需最小版本
cmake_minimum_required(VERSION 4.2)

# 包名
project(cxx_pkg)

# 默认关闭测试
option(BUILD_TESTING "Build tests" OFF)

# 添加自定义 CMake 模块路径（确保能找到 ros2_cxx_setup.cmake）
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../cmake")

# 引入通用配置（C++ 标准、警告选项、ament_cmake、测试配置等）
include(ros2_cxx_setup)

# 显式查找项目依赖（清晰可见）
find_package(rclcpp REQUIRED)          # ROS2 C++ 客户端库
# find_package(std_msgs REQUIRED)      # 如有需要可继续添加

# 创建节点：显式声明 DEPENDS rclcpp .....
ros2_cxx_setup(cxx_node DEPENDS rclcpp)

# 生成 ROS2 包描述文件
ament_package()