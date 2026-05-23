# 函数：add_cxx_node
# 用法：add_cxx_node(<节点名> [DEPENDS 包1 包2 ...])
# 说明：
#   - 源文件固定为 src/<节点名>.cpp
#   - 默认依赖 rclcpp，可通过 DEPENDS 添加额外依赖
#   - 自动传递 NODE_NAME 宏给源代码
function(add_cxx_node NODE_NAME)
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

  set(ALL_DEPENDS rclcpp)
  if(NODE_DEPENDS)
    list(APPEND ALL_DEPENDS ${NODE_DEPENDS})
  endif()

  ament_target_dependencies(${NODE_NAME} ${ALL_DEPENDS})

  install(TARGETS ${NODE_NAME} DESTINATION lib/${PROJECT_NAME})
endfunction()
