cmake_minimum_required(VERSION 4.2)
project("Elegant_ROS2")

# 包含两个注册脚本
include(cmake/register_cxx_pkg.cmake)

# 注册所有 C++ 包（以便 CLion 索引）
register_cxx_pkg(
        BUILD_BASE "${PROJECT_SOURCE_DIR}/build"
        BASE_PATHS "${PROJECT_SOURCE_DIR}/src/"
)

