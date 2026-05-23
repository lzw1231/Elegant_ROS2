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
