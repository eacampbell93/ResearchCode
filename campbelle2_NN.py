import pandas as pd
from sklearn.neural_network import MLPClassifier
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
from joblib import dump, load

file_path = '/mnt/isilon/masino_lab/campbelle2/Obesity_Prediction_Code/'

rand_seeds = load(file_path + 'rand_seeds_200.joblib')

with open(file_path + 'ml_data.pik', "rb") as f:
            data = dill.load(f)

x = data['x']
y = data['y']

param_grid = {
    'activation': ['tanh', 'relu'],
    'learning_rate': ['constant', 'adaptive'],
    'learning_rate_init': [0.1, 0.01, 0.01],
    'solver': ['adam'],
    'hidden_layer_sizes': [(30,50, 30), (100, 100, 100), (50, 100, 50), (75, 50, 25)]
}

grid = []
for activation in param_grid['activation']:
    for learning_rate in param_grid['learning_rate']:
        for learning_rate_init in param_grid['learning_rate_init']:
            for solver in param_grid['solver']:
                for hidden_layer_sizes in param_grid['hidden_layer_sizes']:
                    grid.append({'activation': activation, 'learning_rate': learning_rate, 'learning_rate_init': learning_rate_init, 'solver': solver,
                                'hidden_layer_sizes': hidden_layer_sizes})


auc_dict = dict.fromkeys(rand_seeds)
prediction_probabilities = dict.fromkeys(rand_seeds)
for seed in rand_seeds:
    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.25, stratify = y, random_state = seed)

    auc_arr = []
    pred_prob = []
    for param in grid:
        clf = MLPClassifier(**param)
        clf = clf.fit(x_train, y_train)
        y_pred_prob = clf.predict_proba(x_test)
        auc = roc_auc_score(y_test, y_pred_prob[:, 1])

        auc_arr.append(auc)
        pred_prob.append(y_pred_prob)

    auc_dict[seed] = auc_arr
    prediction_probabilities[seed] = pred_prob

    temp_NN_results = {'auc': auc_dict, 'pred_prob': prediction_probabilities}
    with open(file_path + 'NN_temp_results_200.pik', "wb") as f:
         pickle.dump(temp_NN_results, f, protocol=pickle.HIGHEST_PROTOCOL)

results = {'auc': auc_dict, 'prediction_probabilities': prediction_probabilities}

dump(results, file_path + 'NN_results_200.joblib')
