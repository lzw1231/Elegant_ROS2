# 函数：add_ros2_node
# 用法：add_ros2_node(<节点名> [DEPENDS 包1 包2 ...])
# 说明：
#   - 源文件固定为 src/<节点名>.cpp
#   - 默认依赖 rclcpp，可通过 DEPENDS 添加额外依赖
#   - 自动传递 NODE_NAME 宏给源代码
function(add_ros2_node NODE_NAME)
  # 解析可选参数 DEPENDS
  cmake_parse_arguments(NODE "" "" "DEPENDS" ${ARGN})

  # 设置源文件路径（固定规则）
  set(SOURCE_FILE src/${NODE_NAME}.cpp)

  # 创建可执行目标
  add_executable(${NODE_NAME} ${SOURCE_FILE})

  # 将节点名作为宏定义传递给源代码（可在代码中用 NODE_NAME 获取）
  target_compile_definitions(${NODE_NAME} PRIVATE NODE_NAME="${NODE_NAME}")

  # 添加头文件搜索路径（支持构建和安装两种场景）
  target_include_directories(${NODE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}>
  )

  # 强制使用项目设置的 C/C++ 语言标准
  target_compile_features(${NODE_NAME} PUBLIC
    c_std_${CMAKE_C_STANDARD}
    cxx_std_${CMAKE_CXX_STANDARD}
  )

  # 组装依赖列表：默认依赖 rclcpp，再附加上用户通过 DEPENDS 指定的包
  set(ALL_DEPENDS rclcpp)
  if(NODE_DEPENDS)
    list(APPEND ALL_DEPENDS ${NODE_DEPENDS})
  endif()

  # 调用 ROS 2 的依赖处理函数（处理 include 和链接）
  ament_target_dependencies(${NODE_NAME} ${ALL_DEPENDS})

  # 安装生成的可执行文件到 lib/${PROJECT_NAME} 目录
  install(TARGETS ${NODE_NAME} DESTINATION lib/${PROJECT_NAME})
endfunction()
