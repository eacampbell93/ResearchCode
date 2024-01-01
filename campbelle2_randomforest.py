import pandas as pd
from sklearn.ensemble import RandomForestClassifier
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
    'bootstrap': [True, False],
    'max_features': ['sqrt', 'log2', 1.0],
    'min_samples_leaf': [0.001, 0.01, 0.1, 1, 5, 10, 20, 50, 100],
    'n_estimators': [10, 100, 500, 800, 1000, 1200, 1500]
}

grid = []
for bootstrap in param_grid['bootstrap']:
        for max_features in param_grid['max_features']:
            for min_samples_leaf in param_grid['min_samples_leaf']:
                    for n_estimators in param_grid['n_estimators']:
                        grid.append({'bootstrap': bootstrap,
                            'max_features': max_features,'min_samples_leaf': min_samples_leaf, 'n_estimators': n_estimators })
                


auc_dict = dict.fromkeys(rand_seeds)
prediction_probabilities = dict.fromkeys(rand_seeds)
for seed in rand_seeds:
    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.25, stratify = y, random_state = seed)

    auc_arr = []
    pred_prob = []
    for param in grid:
        clf = RandomForestClassifier(**param)
        clf = clf.fit(x_train, y_train)
        y_pred_prob = clf.predict_proba(x_test)
        auc = roc_auc_score(y_test, y_pred_prob[:, 1])

        auc_arr.append(auc)
        pred_prob.append(y_pred_prob)

    auc_dict[seed] = auc_arr
    prediction_probabilities[seed] = pred_prob
    
    temp_RF_results = {'auc': auc_dict, 'pred_prob': prediction_probabilities}
        with open(file_path + 'RF_temp_results_200.pik', "wb") as f:
             pickle.dump(temp_RF_results, f, protocol=pickle.HIGHEST_PROTOCOL)
             
results = {'auc': auc_dict, 'prediction_probabilities': prediction_probabilities}

dump(results, file_path + 'RF_results_200.joblib')               


