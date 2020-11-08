#!/usr/bin/env roseus

(ros::roseus-add-msgs "geometry_msgs")
(ros::roseus-add-msgs "opencv_apps")

;;  callback function
(setq rect nil)
(defun cb (msg)
    (setq rect (send msg :rect)))

;;init client
(ros::roseus "face_recognizedColor_client" :anonymous t)
(ros::subscribe "/camshift/track_box" opencv_apps::RotatedRectStamped #'cb)
(ros::advertise "/cmd_vel" geometry_msgs::Twist 5)
(setq cmd_vel (instance geometry_msgs::Twist :init))
;;(setq rect (instance opencv_apps::RotatedRectStamped :init))


;;set rate
(ros::rate 10)
(while (ros::ok)
    (setq alpha 0.001)
    (if rect
        (progn
        (if (= (send rect :center :x) 0)
            (send cmd_vel :angular :z 0.3)
            (send cmd_vel :angular :z (* (- alpha) (- (send rect :center :x) 315)))
        )
        (ros::ros-info "ang [~A]" (send rect :center :x))
        (ros::publish "/cmd_vel" cmd_vel)))
    (ros::spin-once)
    (ros::sleep)
)
(exit)
