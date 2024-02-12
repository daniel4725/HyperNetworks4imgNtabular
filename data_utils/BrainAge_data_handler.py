import os
import cv2
import pandas as pd
from torch.utils.data import Dataset, DataLoader
import numpy as np
from tqdm import tqdm
import shutil
import pytorch_lightning as pl
import torch


class BrainAgeDataModule(pl.LightningDataModule):
    def __init__(self, config):
        super().__init__()
        transform_train = config.dataset_cfg.pop("transform_train")
        transform_valid = config.dataset_cfg.pop("transform_valid")
        self.batch_size = config.batch_size
        self.num_workers = config.num_workers

        assert (config.dataset_cfg.gender in [None, "M", "F"]), 'gender must be None, "M" or "F" !!'

        self.train_ds = BrainAge_Dataset(data_type="train", transform=transform_train, **config.dataset_cfg)
        self.valid_ds = BrainAge_Dataset(data_type="valid", transform=transform_valid, **config.dataset_cfg)
        self.test_ds = BrainAge_Dataset(data_type="test", transform=transform_valid, **config.dataset_cfg)

    # def prepare_data(self):
    #     return
    #
    # def setup(self, stage: str):
    #     return

    def train_dataloader(self):
        return DataLoader(dataset=self.train_ds, batch_size=self.batch_size, shuffle=True, num_workers=self.num_workers)

    def val_dataloader(self):
        return DataLoader(dataset=self.valid_ds, batch_size=self.batch_size, num_workers=self.num_workers)

    def test_dataloader(self):
        return DataLoader(dataset=self.test_ds, batch_size=self.batch_size, num_workers=self.num_workers)

    def predict_dataloader(self):
        return DataLoader(dataset=self.test_ds, batch_size=self.batch_size, num_workers=self.num_workers)


class BrainAge_Dataset(Dataset):
    def __init__(self, base_data_dir, gender=None, data_type=None,
                 transform=None, partial_data=False, ages=None):

        data_dir = os.path.join(base_data_dir, "data")

        if data_type is None:
            metadata_path = os.path.join(base_data_dir, "metadata_age_prediction.csv")
        else:
            metadata_path = os.path.join(base_data_dir, f"metadata_age_prediction_{data_type}.csv")

        metadata = pd.read_csv(metadata_path)
        if partial_data:
            data_end = int(len(metadata) * partial_data)
            metadata = metadata.loc[:data_end]
        if gender is None:
            self.metadata = metadata
        else:
            self.metadata = metadata.loc[metadata["Gender"] == gender].reset_index(drop=True)
        if ages is not None:
            ages_idx = (self.metadata["Age"] >= ages[0]) & (self.metadata["Age"] < ages[1])
            self.metadata = self.metadata.loc[ages_idx].reset_index(drop=True)
        self.data_dir = data_dir
        self.transform = transform
        self.only_tabular = False

    def __len__(self):
        return len(self.metadata)

    def __getitem__(self, index):
        gender = np.array(self.metadata.loc[index, ["Gender_F", "Gender_M"]]).astype(np.float32)
        age = np.array(self.metadata.loc[index, "Age"]).astype(np.float32)
        if self.only_tabular:
            return np.zeros((1, 1, 1, 1)), gender, age

        subject = self.metadata.loc[index, "Subject"]
        img_path = os.path.join(self.data_dir, f"{subject}.npy")
        img = np.load(img_path)

        if self.transform is not None:
            img = self.transform(img)

        return img[None, ...], gender, age  # add channel axis to the image

    def get_path_and_subject(self, index):
        subject = self.metadata.loc[index, "Subject"]
        if self.data_in_storage_server:
            img_path = os.path.join(self.data_dir, subject, "numpySave", f"{subject}.npy")
        else:
            img_path = os.path.join(self.data_dir, f"{subject}.npy")
        return img_path, subject


def create_MRI_metadata(csv_path, save_dir):
    csv = pd.read_csv(csv_path)
    relevant_gender = (csv["Gender"] == 'F') | (csv["Gender"] == 'M')
    relevant_lines = relevant_gender & csv["Age"].notnull()

    metadata = csv.loc[relevant_lines, ["Subject", "Gender", "Age", "ProjName"]]
    metadata = pd.get_dummies(metadata, columns=["Gender"])

    metadata = metadata.sample(frac=1).reset_index(drop=True)
    metadata.to_csv(os.path.join(save_dir, "metadata_age_prediction.csv"), index=False)

    train = metadata.sample(frac=0.8, random_state=0)  # 80% train
    rest_of_data = metadata.loc[~metadata.index.isin(train.index)]

    valid = rest_of_data.sample(frac=0.5, random_state=0)  # 50% of 20% = 10% validation
    test = rest_of_data.loc[~rest_of_data.index.isin(valid.index)]  # 10% test

    train.to_csv(os.path.join(save_dir, "metadata_age_prediction_train.csv"), index=False)
    valid.to_csv(os.path.join(save_dir, "metadata_age_prediction_valid.csv"), index=False)
    test.to_csv(os.path.join(save_dir, "metadata_age_prediction_test.csv"), index=False)


# def copy_data_to_server(metadata_path, dest_dir):
#     os.makedirs(dest_dir, exist_ok=True)
#     mri_ds = MRIDataset(data_in_storage_server=True)
#     for i in tqdm(range(len(mri_ds))):
#         img_path, subject = mri_ds.get_path_and_subject(i)
#         dest_path = os.path.join(dest_dir, subject + ".npy")
#         shutil.copyfile(img_path, dest_path)


if __name__ == "__main__":
    base_csv_path = "/media/rrtammyfs/labDatabase/BrainAge/Healthy_subjects_divided_pipe_v2.csv"
    save_metadata_dir = os.path.join(os.path.dirname(os.getcwd()), "Datasets", "BrainAgeDataset")
    create_MRI_metadata(base_csv_path, save_metadata_dir)

    # data_path = "/home/duenias/PycharmProjects/HyperFusion/Datasets/BrainAgeDataset/data"
    # copy_data_to_server(data_path)


    # shapes = []
    # for i in tqdm(range(len(mri_ds))):
    #     img, gender, age = mri_ds.__getitem__(i)
    #     shapes.append(img.shape)

    # with open('shapes', 'wb') as file:
    #     pickle.dump(shapes, file)
    #
    # print(set(shapes), len(shapes))
    #
    # with open('shapes', 'rb') as file:
    #     s = pickle.load(file)

    pass
