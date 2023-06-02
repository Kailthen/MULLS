#!/bin/sh

set -e 

export PATH=/opt/fangyuan/MULLS/bin:${PATH}
# export PATH=./bin:${PATH}
which mulls_slam

#########################################################################################
#                                  MULLS SLAM                                           #
############################# part to configure (down)###################################
sequence_id=00

#experiment unique name
exp_id=00

#data path (base folder)
diskbase=/media/work/2t/a4d/argo2_parsed/train012/dc9c2d63-083f-32c3-90ff-943ca823a245.0.157

project_folder=${diskbase}/lidar_slam_mulls
pc_format=pcd

#input point cloud folder path
#pc_folder=${project_folder}/label_pcd  #used only in semanctic kitti
pc_folder=${diskbase}/center_lidar/data

#input ground truth pose file path (optional)
gt_body_pose_file=${project_folder}/${sequence_id}.txt #kitti ground truth file
#gt_body_pose_file=${project_folder}/pose_gt_lidar.txt

#input calibration file path (optional) 
calib_file=${project_folder}/calib.txt

#input config file path
# config_file=./script/config/lo_gflag_list_kitti_urban.txt
config_file=./script/config/lo_gflag_list_kitti_argo2.txt
#config_file=./script/config/lo_gflag_list_kitti_highway.txt
#config_file=./script/config/lo_gflag_list_kitti_ultrafast.txt
# config_file=./script/config/lo_gflag_list_64.txt

#input the frame you'd like to use
frame_begin=0
frame_end=999999
frame_step=1

############################### part to configure (up) ###################################

############################### no need to edit (down) ###################################

#output path
lo_adjacent_tran_file=${project_folder}/result/Rt_lo_${exp_id}.txt
lo_lidar_pose_file=${project_folder}/result/pose_l_lo_${exp_id}.txt
lo_body_pose_file=${project_folder}/result/pose_b_lo_${exp_id}.txt
gt_lidar_pose_file=${project_folder}/result/pose_l_gt.txt
lo_lidar_pose_point_cloud=${project_folder}/result/traj_l_lo_${exp_id}.pcd
gt_lidar_pose_point_cloud=${project_folder}/result/traj_l_gt.pcd
map_pc_folder=${project_folder}/result/map_point_clouds
timing_report_file=${project_folder}/result/timing_table_${exp_id}.txt
log_dir=${project_folder}/log

mkdir -p ${log_dir}
mkdir ${project_folder}/result
mkdir ${map_pc_folder}
mkdir ${map_pc_folder}_gt

rm -f ${pc_folder}_filelist.txt
ls ${pc_folder} >> ${pc_folder}_filelist.txt

#run (you can comment this part to directly evaluate the already calculated lidar odometry's result)
#--v : log_vebose_level, increase it to remove the logs
# gdbserver :1234 \
mulls_slam \
--colorlogtostderr=true \
-stderrthreshold 0 \
-log_dir ${log_dir} \
--v=1 \
--point_cloud_folder=${pc_folder} \
--pc_format=.${pc_format} \
--gt_body_pose_file_path=${gt_body_pose_file} \
--calib_file_path=${calib_file} \
--output_adjacent_lo_pose_file_path=${lo_adjacent_tran_file} \
--output_lo_lidar_pose_file_path=${lo_lidar_pose_file} \
--output_lo_body_pose_file_path=${lo_body_pose_file} \
--output_gt_lidar_pose_file_path=${gt_lidar_pose_file} \
--output_map_point_cloud_folder_path=${map_pc_folder} \
--lo_lidar_pose_point_cloud=${lo_lidar_pose_point_cloud} \
--gt_lidar_pose_point_cloud=${gt_lidar_pose_point_cloud} \
--timing_report_file=${timing_report_file} \
--frame_num_begin=${frame_begin} \
--frame_num_end=${frame_end} \
--frame_step=${frame_step} \
--flagfile=${config_file} \
--real_time_viewer_on=1 \
--gt_in_lidar_frame=0 \
--gt_oxts_format=0 \
--write_out_map_on=1 \
--write_out_gt_map_on=0 \
--write_map_each_frame=0
# --initial_scan2scan_frame_num=5

#please set the parameters in the config file 

#simple evaluation using evo (https://github.com/MichaelGrupp/evo)
evaluation_file=${project_folder}/result/Rt_lo_${exp_id}_evaluation.txt
#evo_imgs=${project_folder}/result/${exp_id}_evaluation_evo.zip

# evo_traj kitti ${lo_body_pose_file} --ref=${gt_body_pose_file} -p --plot_mode=xz
# evo_ape kitti ${gt_body_pose_file} ${lo_body_pose_file} -va --plot --plot_mode xz --save_results ${evo_imgs}

#simple evaluation using kitti_eval
#python ./python/kitti_eval.py ${lo_body_pose_file} ${gt_body_pose_file} ${lo_adjacent_tran_file} ${calib_file} ${timing_report_file} ${evaluation_file}

#cat ${config_file} >> ${evaluation_file}

# results (figures, table) would be output in the ./results folder

# replay the lidar odometry if you want
#vis_down_rate=1000
#gdb --args \
# replay_slam ${pc_folder} ${lo_lidar_pose_file} ${gt_lidar_pose_file} ${evaluation_file} .${pc_format} ${frame_begin} ${frame_end} ${frame_step} ${vis_down_rate}

############################### no need to edit (up) ###################################