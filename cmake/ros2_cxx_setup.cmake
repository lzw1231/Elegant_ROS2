# ============================================================================
# ros2_cxx_setup.cmake
# 为 ROS2 C++ 包提供：
#   - 设置 C23 / C++26 标准和编译器警告
#   - 查找 ament_cmake
#   - 配置测试时的 lint 依赖
#   - 定义 add_cxx_node() 函数（自动创建节点可执行文件并链接依赖）
# ============================================================================

# 防止重复包含，并输出提示信息
if (__ADD_CXX_NODE_INCLUDED)
  message(STATUS "[ros2_cxx_setup.cmake] 已经包含过，跳过重复包含")
  return()
endif ()
set(__ADD_CXX_NODE_INCLUDED TRUE)

# ----------------------------------------------------------------------------
# 1. 全局编译设置（C/C++ 标准、警告选项）
# ----------------------------------------------------------------------------
set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif ()

# ----------------------------------------------------------------------------
# 2. ROS2 核心依赖（必须，提供 ament 宏和函数）
# ----------------------------------------------------------------------------
find_package(ament_cmake REQUIRED)

# ----------------------------------------------------------------------------
# 3. 测试配置（仅在测试启用时）
# ----------------------------------------------------------------------------
if (BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  set(ament_cmake_copyright_FOUND TRUE)
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif ()

# ----------------------------------------------------------------------------
# 4. 定义函数 ros2_cxx_setup
# 用法：ros2_cxx_setup(<节点名> DEPENDS 依赖1 依赖2 ...)
# 说明：用户必须在调用前通过 find_package 引入所有 DEPENDS 中列出的包
# ----------------------------------------------------------------------------
function(ros2_cxx_setup NODE_NAME)
  cmake_parse_arguments(NODE "" "" "DEPENDS" ${ARGN})

  set(SOURCE_FILE src/${NODE_NAME}.cpp)
  add_executable(${NODE_NAME} ${SOURCE_FILE})

  target_compile_definitions(${NODE_NAME} PRIVATE NODE_NAME="${NODE_NAME}")

  target_include_directories(${NODE_NAME} PUBLIC
          $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
          $<INSTALL_INTERFACE:include/${PROJECT_NAME}>
  )

  target_compile_features(${NODE_NAME} PUBLIC
          c_std_${CMAKE_C_STANDARD}
          cxx_std_${CMAKE_CXX_STANDARD}
  )

  # 链接依赖（前提：依赖包已通过 find_package 查找）
  if (NODE_DEPENDS)
    ament_target_dependencies(${NODE_NAME} ${NODE_DEPENDS})
  endif ()

  install(TARGETS ${NODE_NAME} DESTINATION lib/${PROJECT_NAME})
endfunction()