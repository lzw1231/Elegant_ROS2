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
