#!/usr/bin/env roseus

(ros::roseus-add-msgs "trajectory_msgs")
(ros::roseus-add-msgs "control_msgs")

(ros::roseus "send_joint_position")

(defun send-joint-position-actionilib ()
    (let (goal)
        (if (not (boundp '*c*))
            (setq *c* (instance ros::simple-action-client 
                :init "/fullbody_controller/follow_joint_trajectory" control_msgs::FollowJointTrajectoryAction)))
        (warning-message 2 ";; ~A wait-for-server~%" (unix::getpid))
        (send *c* :wait-for-server)
        (setq goal (instance control_msgs::FollowJointTrajectoryGoal :init))
        (setq trajectory (instance trajectory_msgs::JointTrajectory :init))
        (send goal :trajectory :header :stamp (ros::time-now))
        (send goal :trajectory :joint_names (list "arm_joint1" "arm_joint2" "arm_joint3" "arm_joint4" "arm_joint5" "arm_joint6"))
        (dotimes (i 5)
            (setq point (instance trajectory_msgs::JointTrajectoryPoint :init))
            (send point :positions (float-vector pi/2 0 (* (/ pi 4) (mod i 2)) 0 pi/2 pi/2))
            (send point :time_from_start (instance ros::duration :init (+ 1.0 i)))
            (send goal :trajectory :points (append (send goal :trajectory :points) (list point)))
            )
        (send *c* :send-goal goal)
        (ros::ros-info "wait for goal ...")
        (send *c* :wait-for-result)
        (ros::ros-info "done")
    ))


(send-joint-position-actionilib)
