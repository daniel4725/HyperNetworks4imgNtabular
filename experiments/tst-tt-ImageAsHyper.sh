#!/bin/bash
PYPROJ="/home/duenias/PycharmProjects/HyperNetworks/pyproj"
cd $PYPROJ

# args:
#GPU="0"
#data_fold="0"
GPU="$1"
data_fold="$2"

exname="$3"  # the experiment name is the file name
num_classes="3"
features_set="12"
model="$3"
cnn_dropout="0.1"
init_features="16"
lr="0.0001"
L2="0.00001"
epochs="250"
batch_size="32"
tform="hippo_crop_lNr_l2r"  # hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scale
tform_valid="None"  # hippo_crop_2sides hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scaletform_valid="hippo_crop_2sides"   # hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scale
num_workers="1"
class_weights=""  # "-cw 0.9454 0.85 1.9906"  "-cw 0.9454 0.6945 1.9906"  -cw 0.9454 1.2 1.8

# flags:
with_skull=""             # "--with_skull"  or ""
no_bias_field_correct="--no_bias_field_correct"   # "--no_bias_field_correct" or ""
load2ram="-l2r"            # "-l2r" or ""
ckpt_en="-ckpt_en"         # "-ckpt_en" or ""


adni_dir="/home/duenias/PycharmProjects/HyperNetworks/ADNI_2023/ADNI"
checkpoint_dir="/media/oldrrtammyfs/Users/daniel/HyperProj_checkpoints"
exname="$exname-fs$features_set"

args="-exname $exname --model $model --init_features $init_features  -lr $lr --L2 $L2  --epochs $epochs --batch_size $batch_size --data_fold $data_fold -tform $tform --features_set $features_set --GPU $GPU -wandb -rfs --adni_dir $adni_dir -cp_dir $checkpoint_dir -nw $num_workers $with_skull $no_bias_field_correct $load2ram $ckpt_en $class_weights --num_classes $num_classes"
python3 model_trainer.py $args

#exname="$exname-fs$features_set-c$num_classes"
#echo "starting cross validation exp..."
#for data_fold in 0 1 2 3; do
#  args="-exname $exname --model $model --init_features $init_features  -lr $lr --L2 $L2  --epochs $epochs --batch_size $batch_size --data_fold $data_fold -tform $tform --features_set $features_set --GPU $GPU -wandb -rfs --adni_dir $adni_dir -cp_dir $checkpoint_dir -nw $num_workers $with_skull $no_bias_field_correct $load2ram $ckpt_en $class_weights --num_classes $num_classes"
#  python3 model_trainer.py $args
#done

echo "Exiting..."
exit 0
