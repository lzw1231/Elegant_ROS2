cmake_minimum_required(VERSION 4.2)
project("Elegant_ROS2")

include("cmake/register_cxx_pkg.cmake")

# only for clion highlighting and analysis
register_cxx_pkg(
        BUILD_BASE "${PROJECT_SOURCE_DIR}/build"
        BASE_PATHS "${PROJECT_SOURCE_DIR}/src/"
        # --packages-select
)
