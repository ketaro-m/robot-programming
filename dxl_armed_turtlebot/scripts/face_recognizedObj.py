#!/usr/bin/env python
# -*- coding: utf-8 -*-
import rospy
from jsk_recognition_msgs.msg import RectArray
from opencv_apps.msg import RotatedRectStamped
from image_view2.msg import ImageMarker2
from geometry_msgs.msg import Point, Twist

class track_box_to_cmd_vel:
    rect = None ## メンバ変数として定義
    pub = None
    rate = None
    def __init__(self):
        self.rect = RectArray()
        rospy.init_node('client')
        rospy.Subscriber('/edgetpu_object_detector/output/rects', RectArray, self.cb)
        self.pub = rospy.Publisher('/cmd_vel', Twist)
    def cb(self, msg):
        self.rect = msg ## 画像処理の結果 (msg) を大域変数 rect に登録
    def loop(self):
        rate = rospy.Rate(10)
        while not rospy.is_shutdown():
            cmd_vel = Twist() ## 大域変数 rect に応じて cmd_vel を計算．
            #TODO
            alpha = 0.001 # coefficient for facing speed
            if (len(self.rect.rects) == 0):
                cmd_vel.angular.z = 0.3
            else:
                #print(self.rect.rects[0].x + self.rect.rects[0].width/2)
                cmd_vel.angular.z = - alpha * (self.rect.rects[0].x + self.rect.rects[0].width/2 - 315)
            self.pub.publish(cmd_vel)
            rate.sleep()
        print("shutdown")

if __name__ == '__main__':
    # track_box_to_cmd_vel オブジェクトを生成
    obj = track_box_to_cmd_vel()
    # obj.loop() メンバ関数内で無限ループとなる．
    obj.loop()