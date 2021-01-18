
# coding: utf-8

# In[1]:

import pandas as pd
import numpy as np
import re


# In[13]:

data = pd.read_csv('personnes.csv')
print(data)


# In[3]:

def lower_case(value): 
    print('Voici la valeur que je traite:', value)
    return value.lower()

data['prenom_min'] = data['prenom'].apply(lower_case)


# In[4]:

del data['prenom_min']


# In[5]:

VALID_COUNTRIES = ['France', "Côte d'ivoire", 'Madagascar', 'Bénin', 'Allemagne', 'USA']


# In[6]:

def check_country(country):
    if country not in VALID_COUNTRIES:
        print(' - "{}" n\'est pas un pays valide, nous le supprimons.'.format(country))
        return np.NaN
    return country


# In[7]:

def first(string):
    parts = string.split(',')
    first_part = parts[0]
    if len(parts) >= 2:
        print(' - Il y a plusieurs parties dans "{}", ne gardons que {}.'            .format(parts,first_part))  
    return first_part


# In[8]:

def convert_height(height):
    found = re.search('\d\.\d{2}m', height)
    if found is None:
        print('{} n\'est pas au bon format. Il sera ignoré.'.format(height))
        return np.NaN
    else:
        value = height[:-1] # on enlève le dernier caractère, qui est 'm'
        return float(value)

def fill_height(height, replacement):
    if pd.isnull(height):
        print('Imputation par la moyenne : {}'.format(replacement))
        return replacement
    return height


# In[9]:

data['email'] = data['email'].apply(first)
data['pays'] = data['pays'].apply(check_country)
data['taille'] = [convert_height(t) for t in data['taille']]
data['taille'] = [t if t<3 else np.NaN for t in data['taille']]

mean_height = data['taille'].mean()
data['taille'] = [fill_height(t, mean_height) for t in data['taille']]

data['date_naissance'] = pd.to_datetime(data['date_naissance'],format='%d/%m/%Y', 
                                        errors='coerce')


# In[10]:

data


# In[ ]:



