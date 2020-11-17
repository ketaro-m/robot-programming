#!/usr/bin/env python

import rospy
from opencv_apps.msg import FaceArrayStamped
from std_msgs.msg import Int64
from sensor_msgs.msg import Range

image_size = [640, 480] # pixel
image_center = list(map(lambda x: x/2, image_size))
motor_angle = 0 # [deg]
motor_v = 0
pub = None

def face_detection_cb(msg):
    global pub

    face_msg = FaceArrayStamped()
    face_pos = [0, 0]
    global motor_angle
    global motor_v

    # face check
    if len(msg.faces):
        face = msg.faces[0].face
        face_pos[0] = face.x
        face_pos[1] = face.y
        # check face position. left or right
        if face_pos[0] <= image_center[0]:
            motor_angle -= motor_v
        else:
            motor_angle += motor_v

        motor_command_msg = Int64(int(motor_angle))

        # print
        print "face_pos(x, y): ({} {})".format(face_pos[0], face_pos[1])
        print "/motor1/command: {}\n".format(motor_command_msg.data)

        # publish
        pub.publish(motor_command_msg)
    else:
        print "no faces"


def range_cb(msg):
    global motor_v
    motor_v = max(int([msg.range * 100, 10])
    print "range: {:.2f} cm\n".format(msg.range*100)



    
        
def main():
    rospy.init_node('motor_command_by_face', anonymous=True)
    global pub
    pub = rospy.Publisher('motor1/command', Int64, queue_size=100)
    rospy.Subscriber('face_detection/faces', FaceArrayStamped, face_detection_cb)
    rospy.Subscriber('/range', Range, range_cb)
    rospy.spin()
    
if __name__ == '__main__':
    main()

