# CLION 优雅地开发 ROS2

## 一、创建标准 ROS2 工作空间

新建名为 `Elegant\_ROS2` 的文件夹，作为本次 ROS2 开发的工作空间根目录。

## 二、创建源码目录

在工作空间根目录下创建 `src` 源码目录，ROS2 所有功能包均统一存放于此，符合 ROS2 工程规范。

## 三、创建 Python / C\+\+ 功能包与初始节点

进入工作空间的 `src` 目录，分别创建标准化的 Python、C\+\+ ROS2 功能包，工具会自动生成基础包文件与默认节点模板。

### 3\.1 创建 Python 功能包

```bash
ros2 pkg create --build-type ament_python \
  --license Apache-2.0 \
  --node-name py_node \
  --maintainer-name "lzw1231" \
  --maintainer-email "lzw1231@sina.com" \
  --description "A Python ROS2 node" \
  py_pkg
```

### 3\.2 创建 C\+\+ 功能包

```bash
ros2 pkg create --build-type ament_cmake \
  --license Apache-2.0 \
  --node-name cxx_node \
  --dependencies rclcpp \
  --maintainer-name "lzw1231" \
  --maintainer-email "lzw1231@sina.com" \
  --description "A C++ ROS2 node" \
  cxx_pkg
```

## 四、编写自定义节点业务代码

### 4\.1 Python 节点（py\_node\.py）

```python
import rclpy
from rclpy.node import Node

class MyNode(Node):
    def __init__(self):
        super().__init__('py_node')
  

def main(args=None):
    rclpy.init(args=args)
    node = MyNode()
    
    node.get_logger().info('py_node: 你好, ROS2!')
    
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
```

### 4\.2 C\+\+ 节点（cxx\_node\.cpp）

节点文件路径：`src/cxx\_pkg/src/cxx\_node\.cpp`，编写基础 ROS2 C\+\+ 节点，依托自定义 CMake 宏定义自动适配节点名称，实现日志打印功能。

```cpp
#include <rclcpp/rclcpp.hpp>

int main(int argc, char * argv[])
{
    rclcpp::init(argc, argv);
    auto node = std::make_shared<rclcpp::Node>(NODE_NAME);
    RCLCPP_INFO(node->get_logger(), "Node %s: 你好, ROS2!", NODE_NAME);
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
```

## 五、封装通用 CMake 编译工具（统一 C\+\+ 节点规范）

在工作空间 `cmake` 目录下新建 `add\_ros2\_node\.cmake`，封装复用性极强的 ROS2 C\+\+ 节点编译逻辑，统一节点编译、依赖链接、宏传递、安装部署全流程规范，规避重复配置，适配多节点批量开发。文件内容如下：

```cmake
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
```

## 六、配置 C\+\+ 功能包编译文件

完全替换 `src/cxx\_pkg/CMakeLists\.txt` 默认生成内容，引入全局自定义 CMake 工具函数，统一项目编译标准，简化节点新增、依赖扩展操作，适配规范化开发流程。

```cmake
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
```

## 七、CLion 工程适配配置（核心优化）

### 7\.1 工作空间根目录 下，创建CMakeLists\.txt如下：

```cmake
cmake_minimum_required(VERSION 4.2)
project("Elegant_ROS2")

include("cmake/colcon.cmake")

# only for clion highlighting and analysis
colcon_add_subdirectories(
        BUILD_BASE "${PROJECT_SOURCE_DIR}/build"
        BASE_PATHS "${PROJECT_SOURCE_DIR}/src/"
        # --packages-select
)
```

### 7\.2 Colcon 工程识别适配脚本

在 `cmake` 目录创建 `colcon\.cmake` 适配脚本，自动遍历、识别、加载 ROS2 Colcon 功能包，解决原生 ROS2 工程无法被 CLion 正常索引、高亮、解析的痛点，实现 IDE 完美适配。文件内容如下：

```cmake
function(colcon_add_subdirectories)
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "" "BUILD_BASE;BASE_PATHS" "")

  message("search criteria: ${ARGV}")

  execute_process(COMMAND colcon list
		--paths-only
		--base-paths ${ARG_BASE_PATHS}
		--topological-order
		${ARG_UNPARSED_ARGUMENTS}
		OUTPUT_VARIABLE paths)
  string(STRIP "${paths}" paths)
  string(REPLACE "\n" ";" paths "${paths}")

  MESSAGE("colcon shows paths ${paths}")

  foreach(path IN LISTS paths)
    message("...examining ${path}")
    # if(EXISTS "${path}/CMakeLists.txt")
    execute_process(COMMAND colcon info --paths "${path}" OUTPUT_VARIABLE package_info)
    if(NOT "${package_info}" MATCHES "type:[ \t]+(cmake|ros.ament_cmake|ros.cmake)")
      message("skipping non-cmake project")
    elseif(NOT "${package_info}" MATCHES "name:[ \t]+([^ \r\n\t]*)")
      message(WARNING "could not identify package at ${path}")
    else()
      set(name "${CMAKE_MATCH_1}")
      message("...adding package ${name} from path ${path}")
      MESSAGE("package info: ${package_info}")

      get_filename_component(BUILD_PATH "${name}" ABSOLUTE BASE_DIR "${ARG_BUILD_BASE}")

      add_subdirectory("${path}" "${BUILD_PATH}")
    endif()
  endforeach()
endfunction()
```

## 八、最终完整项目目录结构

```text
Elegant_ROS2/
├── cmake/
│   ├── add_ros2_node.cmake
│   └── colcon.cmake
├── src/
│   ├── cxx_pkg/
│   │   ├── include/
│   │   │   ├── cxx_pkg/
│   │   ├── src/
│   │   │   └── cxx_node.cpp
│   │   ├── CMakeLists.txt
│   │   ├── LICENSE
│   │   └── package.xml
│   ├── py_pkg/
│       ├── py_pkg/
│       │   ├── __init__.py
│       │   └── py_node.py
│       ├── resource/
│       │   └── py_pkg
│       ├── test/
│       │   ├── test_copyright.py
│       │   ├── test_flake8.py
│       │   └── test_pep257.py
│       ├── LICENSE
│       ├── package.xml
│       ├── setup.cfg
│       └── setup.py
├── CMakeLists.txt
```


