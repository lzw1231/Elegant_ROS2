# 设置 CMake 最低版本要求
cmake_minimum_required(VERSION 4.2)

# 定义项目名称（Elegant_ROS2）
project("Elegant_ROS2")

# 引入自定义 CMake 脚本 register_cxx_pkg.cmake
# 该脚本用于注册所有 C++ 类型的 ROS2 包，便于 CLion 索引和统一构建
include(cmake/register_cxx_pkg.cmake)

# 注册所有 C++ 类型的 ROS 2 包
#   - BUILD_BASE：指定构建输出目录
#   - BASE_PATHS：指定源码目录，用于查找 ROS 2 包
register_cxx_pkg(
        BUILD_BASE "${PROJECT_SOURCE_DIR}/build"
        BASE_PATHS "${PROJECT_SOURCE_DIR}/src/"
)
