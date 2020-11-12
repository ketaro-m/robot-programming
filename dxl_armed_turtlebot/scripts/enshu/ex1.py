#!/usr/bin/env python
# -*- coding: utf-8 -*-
import rospy, actionlib
from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
from geometry_msgs.msg import Twist
from jsk_recognition_msgs.msg import BoundingBoxArray

boxes = []
def cb(msg):
    global boxes
    boxes = msg.boxes 

if __name__ == '__main__':

    try:
        rospy.init_node("send_goal", anonymous=True)
        client = actionlib.SimpleActionClient("move_base", MoveBaseAction)
        rospy.Subscriber('/camera/depth_registered/boxes', BoundingBoxArray, cb)
        pub = rospy.Publisher('/cmd_vel', Twist)
        rospy.loginfo("wait for server")
        client.wait_for_server()
        rospy.loginfo("connected to server")
        goal = MoveBaseGoal()
        while True:
            rospy.loginfo("detecting boxes...")
            cmd_vel = Twist()
            cmd_vel.angular.z = 0.1
            rate = rospy.Rate(10)
            pub.publish(cmd_vel)
            rate.sleep()
            if (len(boxes) >= 1):
                cmd_vel.angular.z = 0.0
                pub.publish(cmd_vel)
                goal.target_pose.header = boxes[-1].header
                goal.target_pose.pose = boxes[-1].pose
                break
        rospy.loginfo("send goal")
        rospy.loginfo(goal)
        client.send_goal(goal)
        rospy.loginfo("wait for goal ...")
        ret = client.wait_for_result()
        rospy.loginfo("done")
    except rospy.ROSInterruptException: pass