#!/usr/bin/env roseus

(ros::roseus-add-msgs "trajectory_msgs")

;;init client
(ros::roseus "send_joint_position" :anonymous t)                                           
(ros::advertise "/fullbody_controller/command" trajectory_msgs::JointTrajectory 1)
(ros::sleep)                                                                  
(setq joint_trajectory (instance trajectory_msgs::JointTrajectory :init))     
(send joint_trajectory :header :stamp (ros::time-now))
(send joint_trajectory :joint_names (list "arm_joint1" "arm_joint2" "arm_joint3" "arm_joint4" "arm_joint5" "arm_joint6"))

(dotimes (i 5)
    (setq point (instance trajectory_msgs::JointTrajectoryPoint :init))
    (send point :positions (float-vector pi/2 0 (* (/ pi 4) (mod i 2)) 0 pi/2 pi/2))
    (send point :time_from_start (instance ros::duration :init (+ 1.0 i)))
    (send joint_trajectory :points (append (send joint_trajectory :points) (list point)))
    )

(ros::publish "/fullbody_controller/command" joint_trajectory)
(ros::sleep)