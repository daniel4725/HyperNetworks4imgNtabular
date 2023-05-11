#!/bin/bash
PYPROJ="/home/duenias/PycharmProjects/HyperNetworks/pyproj"
cd $PYPROJ

# args:
GPU="1"

exname="tst-DAFT-fset10-cw_mci09"  # the experiment name is the file name
metadata_path="metadata_by_features_sets/set-10.csv"   # set 4 is norm minmax (0 to 1), set 5 is std-mean
model="DAFT_preactive"
cnn_dropout="0.1"
init_features="32"
lr="0.0001"
L2="0.00001"
epochs="250"
batch_size="64"
tform="hippo_crop_lNr_l2r"  # hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scale
tform_valid="None"  # hippo_crop_2sides hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scaletform_valid="hippo_crop_2sides"   # hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scale
num_workers="1"
class_weights="-cw 0.9454 0.9 1.9906"

# flags:
with_skull=""             # "--with_skull"  or ""
no_bias_field_correct="--no_bias_field_correct"   # "--no_bias_field_correct" or ""
load2ram="-l2r"                    # "-l2r" or ""

adni_dir="/home/duenias/PycharmProjects/HyperNetworks/ADNI_2023/ADNI"

echo "starting cross validation exp..."
for data_fold in 0 1 2 3; do
  args="-exname $exname --model $model  --cnn_dropout $cnn_dropout --init_features $init_features  -lr $lr --L2 $L2  --epochs $epochs --batch_size $batch_size --data_fold $data_fold -tform $tform --metadata_path $metadata_path --GPU $GPU -wandb -rfs --adni_dir $adni_dir -cp_dir $PYPROJ/checkpoints -nw $num_workers $with_skull $no_bias_field_correct $load2ram $class_weights"
  python3 model_trainer.py $args
done
