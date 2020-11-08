#!/usr/bin/env roseus

(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "geometry_msgs")


(defclass track-box-to-cmd-vel
    :slots (track cmd_vel))
(defmethod track-box-to-cmd-vel
    (:init ()
        ;; ros::init
        (ros::roseus "face_recognizedColord_client")
        (ros::subscribe "/camshift/track_box" opencv_apps::RotatedRectStamped #'send self :cb)
        (ros::advertise "/cmd_vel" geometry_msgs::Twist 5)
        (setq cmd_vel (instance geometry_msgs::Twist :init))
        (setq track nil)
    self)
    (:cb (msg)
        (setq track (send msg :rect))
    )
    (:loop ()
        (ros::rate 10)
        (setq alpha 0.001)
        (ros::rate 10)
        (while (ros::ok)
            (setq alpha 0.001)
            (if track
                (progn
                (if (= (send track :center :x) 0)
                    (send cmd_vel :angular :z 0.3)
                    (send cmd_vel :angular :z (* (- alpha) (- (send track :center :x) 315)))
                )
                (ros::ros-info "ang [~A]" (send track :center :x))
                (ros::publish "/cmd_vel" cmd_vel)))
            (ros::spin-once)
            (ros::sleep)
        )
        (exit)
    )
)

(setq *ri* (instance track-box-to-cmd-vel :init))
(send *ri* :loop)