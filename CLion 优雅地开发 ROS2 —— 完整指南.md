# CLion 优雅地开发 ROS2 —— 完整指南

## 一、创建标准 ROS2 工作空间

新建名为 `Elegant\_ROS2` 的文件夹，作为本次 ROS2 开发的工作空间根目录。

```bash
mkdir Elegant_ROS2
cd Elegant_ROS2
```

## 二、创建源码目录

在工作空间根目录下创建 `src` 源码目录，ROS2 所有功能包均统一存放于此，符合 ROS2 工程规范。

```bash
mkdir src
```

## 三、创建 Python / C\+\+ 功能包与初始节点

进入工作空间的 `src` 目录，分别创建标准化的 Python、C\+\+ ROS2 功能包，工具会自动生成基础包文件与默认节点模板。

### 3\.1 创建 Python 功能包

```bash
cd src
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
cd ..
```

## 四、编写自定义节点业务代码

### 4\.1 Python 节点（py\_pkg/py\_pkg/py\_node\.py）

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

### 4\.2 C\+\+ 节点（src/cxx\_pkg/src/cxx\_node\.cpp）

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

在工作空间 `cmake` 目录下新建`add\_cxx\_node\.cmake`，封装复用性极强的 ROS2 C\+\+ 节点编译逻辑，统一节点编译、依赖链接、宏传递、安装部署全流程规范，规避重复配置，适配多节点批量开发。

```bash
mkdir -p cmake
```

**cmake/add\_cxx\_node\.cmake 文件内容：**

```cmake
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
```

## 六、配置 C\+\+ 功能包编译文件

完全替换`src/cxx\_pkg/CMakeLists\.txt` 默认生成内容，引入全局自定义 CMake 工具函数。

**src/cxx\_pkg/CMakeLists\.txt 内容：**

```cmake
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
```

## 七、CLion 工程适配配置（核心优化）

### 7\.1 工作空间根目录下创建 CMakeLists\.txt

**Elegant\_ROS2/CMakeLists\.txt 内容：**

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

在 `cmake` 目录创建 `colcon\.cmake` 适配脚本，自动遍历、识别、加载 ROS2 Colcon 功能包，解决原生 ROS2 工程无法被 CLion 正常索引、高亮、解析的痛点。

**cmake/colcon\.cmake 内容：**

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
│   ├── add_cxx_node.cmake
│   └── colcon.cmake
├── src/
│   ├── cxx_pkg/
│   │   ├── include/
│   │   │   └── cxx_pkg/
│   │   ├── src/
│   │   │   └── cxx_node.cpp
│   │   ├── CMakeLists.txt
│   │   ├── LICENSE
│   │   └── package.xml
│   └── py_pkg/
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
└── CMakeLists.txt
```

## 九、CLion External Tool 编译工具与快捷键配置

本节配置 CLion 外部编译工具，适配 ROS2 一键编译，采用 **Clang \+ LLD** 高效编译链，替代原生编译方式，提升编译速度与代码规范校验效果。

### 9\.1 External Tool 核心配置参数

打开 CLion 设置：`File \-\&gt; Settings \-\&gt; Tools \-\&gt; External Tools`，新建自定义工具，填写以下参数：

- **Program**：`/bin/bash`

- **Arguments**：

```text
-c "source /opt/ros/jazzy/setup.bash && colcon build --base-paths src --symlink-install --cmake-args -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_LINKER=/usr/bin/ld.lld-18"
```

- **Working directory**：`$ProjectFileDir$`

### 9\.2 顶层 CMake 配置说明

此前配置的顶层`CMakeLists\.txt`（包含 `colcon\_add\_subdirectories` 逻辑）**无需修改、无需删除**。当前 `colcon build` 仅扫描工作空间 `src` 目录，不会与顶层 CMake 配置冲突，完美兼容 CLion 代码索引、语法高亮和工程解析功能。

### 9\.3 快捷键绑定配置

为自定义编译工具绑定快捷键，实现一键编译工程：

CLion 设置：`File \-\&gt; Settings \-\&gt; Keymap`，搜索刚刚创建的 External Tool，绑定自定义快捷键（推荐 **Ctrl\+Shift\+B**）。

### 9\.4 最终效果

配置完成后，当前 ROS2 工作空间可实现：

- 一键快捷键编译整个工程

- 基于 Clang \+ LLD 极速编译、严格语法检查

- 完美兼容 CLion 代码提示、索引、跳转、调试

- 正常运行 C\+\+、Python 两类 ROS2 节点

> （注：文档部分内容可能由 AI 生成）
