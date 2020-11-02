#!/usr/bin/env python
# -*- coding: utf-8 -*-
import rospy
from opencv_apps.msg import RotatedRectStamped
from image_view2.msg import ImageMarker2
from geometry_msgs.msg import Point, Twist
from send_joint_position_actionlib import *

class track_box_to_cmd_vel:
    rect = None ## メンバ変数として定義
    pub = None
    rate = None
    def __init__(self):
        self.rect = RotatedRectStamped()
        rospy.init_node('client')
        rospy.Subscriber('/camshift/track_box', RotatedRectStamped, self.cb)
        self.pub = rospy.Publisher('/cmd_vel', Twist)
    def cb(self, msg):
        self.rect = msg ## 画像処理の結果 (msg) を大域変数 rect に登録
    def loop(self):
        rate = rospy.Rate(10)
        while not rospy.is_shutdown():
            cmd_vel = Twist() ## 大域変数 rect に応じて cmd_vel を計算．
            alpha = 0.001 # coefficient for turning speed
            # beta = 0.01 # coefficient for moving speed
            if (self.rect.rect.center.x == 0):
                cmd_vel.angular.z = 0.3
            else:
                cmd_vel.angular.z = - alpha * (self.rect.rect.center.x - 315)
                if (abs(self.rect.rect.center.x - 315) < 50):
                    if ((350 - self.rect.rect.center.y) < 10):
                        cmd_vel.linear.x = 0
                        break
                    else:
                        # cmd_vel.linear.x = - beta * (self.rect.rect.center.y - 400)
                        cmd_vel.linear.x = 0.1

            self.pub.publish(cmd_vel)
            rate.sleep()

if __name__ == '__main__':
    # track_box_to_cmd_vel オブジェクトを生成
    obj = track_box_to_cmd_vel()
    # obj.loop() メンバ関数内で無限ループとなる．
    obj.loop()

    try:
        send_joint_position_actionlib()
    except rospy.ROSInternalException:
        pass