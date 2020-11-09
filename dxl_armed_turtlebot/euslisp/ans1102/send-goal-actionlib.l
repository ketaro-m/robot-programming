#!/usr/bin/env roseus

(ros::roseus-add-msgs "move_base_msgs")

(ros::roseus "send_goal" :anonymous t)
(setq client (instance ros::simple-action-client :init
              "move_base" move_base_msgs::MoveBaseAction))
(send client :wait-for-server) ;; ActionLibのサーバと通信が接続されることを確認

(setq goal (instance move_base_msgs::MoveBaseGoal :init))
(send goal :target_pose :header :stamp (ros::time-now))
;; this parameter is for dxl_armed_turtlebot_navigation.launch
;; for roslaunch navigation_stage move_base_amcl_2.5cm.launch, use "map", 34, 32
(send goal :target_pose :header :frame_id "odom") ;; "map"
(send goal :target_pose :pose :position :x 1)     ;; 34
(send goal :target_pose :pose :position :y 1)     ;; 32
(send goal :target_pose :pose :orientation :w 1)
(ros::ros-info "send goal")
(ros::ros-info "~A" goal)
(send client :send-goal goal) ;;  目標位置姿勢をgoalとして送信
(ros::ros-info "wait for goal ...")
(setq ret (send client :wait-for-result)) ;; ロボットが目標位置姿勢に到達するまで待つ
(ros::ros-info "done")


