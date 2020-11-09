#!/usr/bin/env roseus

(ros::roseus-add-msgs "trajectory_msgs")

(defun send_joint_position ()
  ;; rosnode の初期化
  (ros::roseus "send_joint_position")

  ;; トピック名，メッセージ型を使ってパブリッシャを定義
  (ros::advertise "/fullbody_controller/command" trajectory_msgs::JointTrajectory 1)

  ;; publihser がサブスクライバと接続するのを待つ
  ;; これをしないと接続する前にpusblish()が呼ばれる
  ;; 簡単には(unix::sleep 1)などでもよい．
  (ros::duration-sleep 1) ;; ややこしいが(ros::sleep) は(ros::rate)に対してsleepする関数 https://euslisp-docs.readthedocs.io/en/latest/roseus/roseus/#rossleep

  (print (ros::get-num-subscribers "/fullbody_controller/command"))

  ;; 出力用メッセージを作成
  (setq joint-trajectory (instance trajectory_msgs::JointTrajectory :init))
  (send joint-trajectory :header :stamp (ros::time-now))
  (send joint-trajectory :joint_names '("arm_joint1" "arm_joint2" "arm_joint3"
                                        "arm_joint4" "arm_joint5" "arm_joint6"))

  (dotimes (i 5)
    (setq point (instance trajectory_msgs::JointTrajectoryPoint :init))
    ;; $ (setq point (instance trajectory_msgs::JointTrajectoryPoint :init))
    ;; #<trajectory_msgs::jointtrajectorypoint #X55bee493e018>
    ;; $ (send point :positions)
    ;; #f()
    ;; となるのでこれは float-vector だということがわかる．
    (send point :positions (float-vector pi/2 0 (* (/ pi 4) (mod i 2)) 0 pi/2 pi/2))
    (send point :time_from_start (instance ros::duration :init (+ 1.0 i)))
    (send joint-trajectory :points
          (append (send joint-trajectory :points) (list point)))
    )

  ;; メッセージをパブリッシュ
  (ros::publish "/fullbody_controller/command" joint-trajectory)

  ;; 動作終了を待つ
  (ros::duration-sleep 5)
  )

(send_joint_position)
