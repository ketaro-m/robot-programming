#!/usr/bin/env python
# -*- coding: utf-8 -*-
import rospy, actionlib
import sys, select, termios, tty
from move_base_msgs.msg import *
from actionlib_msgs.msg import GoalStatus

def getKey(client):
    if select.select([sys.stdin], [], [], 0) == ([sys.stdin], [], []):
        # key = sys.stdin.read(1)
        # return key
        client.cancel_goal()
        return False
    return True

if __name__ == '__main__':
    x = int(sys.argv[1])
    y = int(sys.argv[2])

    settings = termios.tcgetattr(sys.stdin)
    tty.setcbreak(sys.stdin.fileno())
    try:
        rospy.init_node("send_goal", anonymous=True)
        client = actionlib.SimpleActionClient("move_base", MoveBaseAction)
        client.wait_for_server() # ActionLib のサーバと通信が接続されることを確認
        goal = MoveBaseGoal()
        goal.target_pose.header.stamp = rospy.Time.now()
        goal.target_pose.header.frame_id = 'map'
        goal.target_pose.pose.position.x=x
        goal.target_pose.pose.position.y=y
        goal.target_pose.pose.orientation.w = 1
        rospy.loginfo("send goal")
        rospy.loginfo(goal)
        client.send_goal(goal) # 目標位置姿勢を goal として送信
        rospy.loginfo("wait for goal ...")

        flag = True
        while (client.get_state()!=GoalStatus.SUCCEEDED and flag):
            try:
                flag = getKey(client)  
            finally:
                termios.tcsetattr(sys.stdin, termios.TCSADRAIN, settings)
        #ret = client.wait_for_result() # ロボットが目標位置姿勢に到達するまで待つ
        if (flag):
            rospy.loginfo("done")
        else:
            rospy.loginfo("canceled")
    except rospy.ROSInterruptException: pass