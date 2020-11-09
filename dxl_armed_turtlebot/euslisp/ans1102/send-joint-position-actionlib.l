#!/usr/bin/env roseus

(ros::roseus-add-msgs "actionlib")
(ros::roseus-add-msgs "trajectory_msgs")
(ros::roseus-add-msgs "control_msgs")

(defun send_joint_position_actionlib ()
  ;; rosnode の初期化
  (ros::roseus "send_joint_position")

  ;; トピック名，メッセージ型を使ってActionLib clientを定義
  (setq client (instance ros::simple-action-client :init
                         "/fullbody_controller/follow_joint_trajectory"
                         control_msgs::FollowJointTrajectoryAction))
  (send client :wait-for-server) ;; ActionLibのサーバと通信が接続されることを確認

  ;; ActionLib client の goal を指定
  ;; http://wiki.ros.org/actionlib_tutorials/Tutorials の
  ;;   Writing a Simple Action Client (Python) を参照
  ;; __TOPIC_PREFIX__Action で actionlib.SimpleActionClient を初期化
  ;; ゴールオブジェクトは __TOPIC_PREFIX__Goal を使って生成
  (setq goal (instance control_msgs::FollowJointTrajectoryGoal :init))
  (send goal :trajectory (instance trajectory_msgs::JointTrajectory :init))
  (send goal :trajectory :header :stamp (ros::time-now))
  (send goal :trajectory :joint_names (list "arm_joint1" "arm_joint2" "arm_joint3"
                                            "arm_joint4" "arm_joint5" "arm_joint6"))
  (dotimes (i 5)
    (setq point (instance trajectory_msgs::JointTrajectoryPoint :init))
    (send point :positions (float-vector pi/2 0 (* (/ pi 4) (mod i 2)) 0 pi/2 pi/2))
    (send point :time_from_start (instance ros::duration :init (+ 1.0 i)))
    (send goal :trajectory :points
          (append (send goal :trajectory :points) (list point)))
    )

  ;; 目標姿勢をゴールとして送信
  (send client :send-goal goal)
  (ros::ros-info "wait for goal ...")
  (send client :wait-for-result) ;; ロボットの動作が終わるまで待つ．
  (ros::ros-info "done")
  )

;; メイン文．
(send_joint_position_actionlib)

