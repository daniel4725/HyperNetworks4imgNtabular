#!/bin/bash
PYPROJ="/home/duenias/PycharmProjects/HyperNetworks/pyproj"
cd $PYPROJ

#sh experiments/tst-MLP4tabular.sh

# args:
GPU="0"

exname="tst-mlp4tabular[16]_arch-set8_v2"  # the experiment name is the file name
metadata_path="metadata_by_features_sets/set-8.csv"  # set 4 is norm minmax (0 to 1), set 5 is std-mean
model="MLP4Tabular"
#------ MLP -------
dropout="0.6"
hidden_shapes="--hidden_shapes 16"  # "--hidden_shapes 4" or ""
only_tabular="--only_tabular"
ckpt_en="-ckpt_en"
cp_cont_path="" #"-cp_cont_path /media/rrtammyfs/Users/daniel/HyperProj_checkpoints/tst-mlp4tabular_minimal_arch-set8_22/tst-mlp4tabular_minimal_arch-set8_22-epoch=6-last.ckpt"

cnn_dropout="0.1"
init_features="32"
lr="0.0001"
L2="0.00001"
epochs="300"
batch_size="64"
tform="hippo_crop_lNr"  # hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scale
tform_valid="hippo_crop_2sides"  # hippo_crop_2sides hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scaletform_valid="hippo_crop_2sides"   # hippo_crop  hippo_crop_lNr  normalize hippo_crop_lNr_noise hippo_crop_lNr_scale
num_workers="5"
class_weights=""  # "-cw 1.2 1.2 1.99"  "-cw 0.9454 0.6945 1.9906"

# flags:
with_skull=""             # "--with_skull"  or ""
no_bias_field_correct="--no_bias_field_correct"   # "--no_bias_field_correct" or ""
load2ram=""                    # "-l2r" or ""

adni_dir="/home/duenias/PycharmProjects/HyperNetworks/ADNI_2023/ADNI"

echo "starting cross validation exp..."
for data_fold in 0; do
  args="-exname $exname --model $model  --cnn_dropout $cnn_dropout --init_features $init_features  -lr $lr --L2 $L2  --epochs $epochs --batch_size $batch_size --data_fold $data_fold -tform $tform --metadata_path $metadata_path --GPU $GPU -wandb -rfs --adni_dir $adni_dir -nw $num_workers $with_skull $no_bias_field_correct $load2ram $class_weights --dropout $dropout $only_tabular $hidden_shapes $ckpt_en $cp_cont_path"
  python3 model_trainer.py $args
done

echo "Exiting..."
exit 0




