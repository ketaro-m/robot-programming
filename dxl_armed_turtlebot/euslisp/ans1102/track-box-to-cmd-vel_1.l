#!/usr/bin/env roseus


(ros::roseus-add-msgs "opencv_apps")
(ros::roseus-add-msgs "geometry_msgs")

(setq rect (instance opencv_apps::RotatedRectStamped :init)) ;; 大域変数として定義
(defun cb (msg)
  (let (area)
  ;; 画像処理の結果を取得
    (setq area (* (send msg :rect :size :width)
                  (send msg :rect :size :height)))
    (ros::ros-info "area = ~A, center = (~A, ~A)" area (send msg :rect :center :x) (send msg :rect :center :y))

    ;; 認識結果面積が一定値以上のときはrectに登録
    (if (> area (* 100 100))
        (setq rect msg))))

;; main
(ros::roseus "client")
(ros::subscribe "/camshift/track_box" opencv_apps::RotatedRectStamped #'cb)
(ros::advertise "/cmd_vel" geometry_msgs::Twist)

(ros::rate 10)
(while (ros::ok)
  (setq cmd-vel (instance geometry_msgs::Twist :init))
  ;; 古いrect = 認識結果は利用しない
  (setq rect-arrived (ros::time- (ros::time-now) (send rect :header :stamp)))
  (ros::ros-info "rect arrived ~A sec ago" (send rect-arrived :to-sec))
  ;; 最大1秒前の認識結果を利用
  (if (< (send rect-arrived :to-sec) 1.0)
      ;; 認識結果の領域の中心のx座標が320より小さければ（画像の半分より左），左回転する
      (if (< (send rect :rect :center :x) 320)
          (send cmd-vel :angular :z 0.1)
        (send cmd-vel :angular :z -0.1)))
  ;; cmd_velをpublish, 'rect_arrived.to_sec() < 1.0' がTrueにならなければ，
  ;; 全ての値が０になっているcmd_velがpublishされる．つまり，ロボットは停止する．
  ;; 対象物がカメラから消えた場合はロボットは止まる．
  ;; こうしないと，対象物がカメラから消えても最後に送った指令が送り続けられる．
  (ros::ros-info "~t~t~tpublish ~A" (send cmd-vel :angular :z))
  (ros::publish "/cmd_vel" cmd-vel)
  (ros::spin-once) ;;; roseus だとこれが必要
  (ros::sleep)
  )




