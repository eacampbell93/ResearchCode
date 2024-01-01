import pandas as pd
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.metrics import precision_score
from sklearn.metrics import classification_report
import numpy as np
from joblib import dump, load
from sklearn.metrics import confusion_matrix
from sklearn.metrics import roc_auc_score
import matplotlib.pyplot as plt
import pickle
import dill

file_path = '/mnt/isilon/masino_lab/campbelle2/Obesity_Prediction_Code/'

rand_seeds = load(file_path + 'rand_seeds_200.joblib')

with open(file_path + 'ml_data.pik', "rb") as f:
            data = dill.load(f)

x = data['x']
y = data['y']

param_grid = {
        'max_depth': [4, 6, 8, 12, 20, 50],
        'learning_rate': [0.0001, 0.001, 0.01, 0.1],
        'subsample': [ 0.1, 0.5, 0.9],
        'n_estimators': [10, 50, 200, 500, 1000, 2000, 3000]
}

grid = []
for max_depth in param_grid['max_depth']:
    for learning_rate in param_grid['learning_rate']:
        for subsample in param_grid['subsample']:
            for n_estimators in param_grid['n_estimators']:
                grid.append({'max_depth': max_depth, 'learning_rate': learning_rate, 'subsample': subsample, 
                            'n_estimators': n_estimators})


auc_dict = dict.fromkeys(rand_seeds)
prediction_probabilities = dict.fromkeys(rand_seeds)
for seed in rand_seeds:
    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.25, stratify = y, random_state = seed)

    auc_arr = []
    pred_prob = []
    for param in grid:
        clf = GradientBoostingClassifier(**param)
        clf = clf.fit(x_train, y_train)
        y_pred_prob = clf.predict_proba(x_test)
        auc = roc_auc_score(y_test, y_pred_prob[:, 1])

        auc_arr.append(auc)
        pred_prob.append(y_pred_prob)

    auc_dict[seed] = auc_arr
    prediction_probabilities[seed] = pred_prob


    temp_XGB_results = {'auc': auc_dict, 'pred_prob': prediction_probabilities}
        with open(file_path + 'XGB_temp_results_200.pik', "wb") as f:
             pickle.dump(temp_XGB_results, f, protocol=pickle.HIGHEST_PROTOCOL)

results = {'auc': auc_dict, 'prediction_probabilities': prediction_probabilities}

dump(results, file_path + 'XGB_results_200.joblib')               