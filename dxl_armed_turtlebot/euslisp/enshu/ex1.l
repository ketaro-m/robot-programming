(load "package://dxl_armed_turtlebot/euslisp/dxl-armed-turtlebot-interface.l")
(dxl-armed-turtlebot-init)
(ros::roseus-add-msgs "jsk_recognition_msgs")
;; クラスタリング結果である BoundingBox の topic 名
(defvar *topic-name* "/camera/depth_registered/boxes")
(defvar *bounding-box-list* nil)
;; init
(ros::roseus "send_goal" :anonymous t)
(ros::roseus-add-msgs "move_base_msgs")
(setq *c* (instance ros::simple-action-client :init "move_base" move_base_msgs::MoveBaseAction))
(ros::ros-info "wait-for-server")
(send *c* :wait-for-server)
(setq *tgt-coords* (make-coords))
;; コールバック関数
(defun bounding-box-array-cb (msg)
  (setq *bounding-box-list* (send msg :boxes)) ;; boxes は、BoundingBox の Array(Euslisp では list)
  ;; BoundingBox があれば表示する
  (when *bounding-box-list*
    (send *irtviewer* :draw-objects :flush nil)
    (mapcar #'(lambda (b)
		;; BoundingBox は、dimensions(直方体の幅・奥行き・高さ) をもつ
		(let* ((dims (ros::tf-point->pos (send b :dimensions)))
			(bx (make-cube (elt dims 0) (elt dims 1) (elt dims 2)))
			;; (1) BoundingBox のカメラ相対の座標系は、geometry_msgs/Pose という型で得られるので、Euslisp の coords に変換する
			(cam->obj-coords (ros::tf-pose->coords (send b :pose)))
			;; (2) *dxl-armed-turtlebot*モデルがカメラの座標系をもってるので、取得する
			(cam-coords (send
				     (send *dxl-armed-turtlebot* :camera_rgb_optical_frame_lk) :copy-worldcoords)))
			;; (3) Euslisp 内部での world 座標系の値にして、そこに make-cube の箱を設置する
			(send bx :newcoords (send cam-coords :transform cam->obj-coords))
			(send bx :worldcoords)
			(send bx :draw-on :flush nil :color #f(1 0 0)) ;; 描画
			;;;;;; ここでグローバル変数に格納 (複数見つかった場合，最後の BoundingBox でよい)
			(setq *tgt-coords* (send bx :worldcoords))
			bx))
	    *bounding-box-list*)
    (send *irtviewer* :viewer :viewsurface :flush)
    )
)

(ros::subscribe *topic-name* jsk_recognition_msgs::BoundingBoxArray #'bounding-box-array-cb 1)
(ros::ros-info "Hit enter to go target with MoveBaseAction")
(do-until-key
 (x::window-main-one) ;; IRT viewer の視点を変えられる。見にくければ変えよう
 (ros::spin-once)
 (ros::sleep)
 )
;;;;;; ここで ActionLib の MoveBaseGoal を設定
(setq goal (instance move_base_msgs::MoveBaseGoal :init))
(send goal :target_pose :header :stamp (ros::time-now))
(send goal :target_pose :header :frame_id "base_link")
(send goal :target_pose :pose :position :x (/ (elt (send *tgt-coords* :pos) 0) 1000))
(send goal :target_pose :pose :position :y (/ (elt (send *tgt-coords* :pos) 1) 1000))
(send goal :target_pose :pose :orientation :w 1)
(ros::ros-info "send_goal")
(send *c* :send-goal goal)
(ros::ros-info "wait for goal ...")
(send *c* :wait-for-result)
(ros::ros-info "done") 
