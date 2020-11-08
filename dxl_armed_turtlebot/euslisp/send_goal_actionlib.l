#!/usr/bin/env roseus

(ros::roseus-add-msgs "move_base_msgs")

(ros::roseus "move_base")

(defun move-base (x y)
    (let (goal)
        (if (not (boundp '*c*))
            (setq *c* (instance ros::simple-action-client :init "move_base" move_base_msgs::MoveBaseAction)))
        (warning-message 2 ";; ~A wait-for-server~%" (unix::getpid))
        (send *c* :wait-for-server)
        (setq goal (instance move_base_msgs::MoveBaseActionGoal :init))
        (send goal :goal :target_pose :header :stamp (ros::time-now))
        (send goal :goal :target_pose :header :frame_id "map")
        (send goal :goal :target_pose :pose :position :x x)
        (send goal :goal :target_pose :pose :position :y y)
        (send goal :goal :target_pose :pose :orientation :w 1) 
        (send *c* :send-goal goal)
        (ros::ros-info "wait for goal ...")
        (send *c* :wait-for-result)
        (ros::ros-info "done")
    ))


(move-base 3 2)
