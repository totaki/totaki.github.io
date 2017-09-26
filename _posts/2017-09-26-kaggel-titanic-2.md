---
title: Kaggle, Titanic. Эпизод 1
date: 2017-09-26 20:00 
layout: post
tags: машинное обучение, kaggle, catboost
---

Посмотрим поближе на наши данные.

{%  highlight python %}
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

data = pd.read_csv('./train.csv')
data.head()
{% endhighlight %}

<div class="dataframe-wrapper">
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>PassengerId</th>
      <th>Survived</th>
      <th>Pclass</th>
      <th>Name</th>
      <th>Sex</th>
      <th>Age</th>
      <th>SibSp</th>
      <th>Parch</th>
      <th>Ticket</th>
      <th>Fare</th>
      <th>Cabin</th>
      <th>Embarked</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>0</td>
      <td>3</td>
      <td>Braund, Mr. Owen Harris</td>
      <td>male</td>
      <td>22.0</td>
      <td>1</td>
      <td>0</td>
      <td>A/5 21171</td>
      <td>7.2500</td>
      <td>NaN</td>
      <td>S</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>1</td>
      <td>1</td>
      <td>Cumings, Mrs. John Bradley (Florence Briggs Th...</td>
      <td>female</td>
      <td>38.0</td>
      <td>1</td>
      <td>0</td>
      <td>PC 17599</td>
      <td>71.2833</td>
      <td>C85</td>
      <td>C</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>1</td>
      <td>3</td>
      <td>Heikkinen, Miss. Laina</td>
      <td>female</td>
      <td>26.0</td>
      <td>0</td>
      <td>0</td>
      <td>STON/O2. 3101282</td>
      <td>7.9250</td>
      <td>NaN</td>
      <td>S</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>1</td>
      <td>1</td>
      <td>Futrelle, Mrs. Jacques Heath (Lily May Peel)</td>
      <td>female</td>
      <td>35.0</td>
      <td>1</td>
      <td>0</td>
      <td>113803</td>
      <td>53.1000</td>
      <td>C123</td>
      <td>S</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>0</td>
      <td>3</td>
      <td>Allen, Mr. William Henry</td>
      <td>male</td>
      <td>35.0</td>
      <td>0</td>
      <td>0</td>
      <td>373450</td>
      <td>8.0500</td>
      <td>NaN</td>
      <td>S</td>
    </tr>
  </tbody>
</table>
</div>

В первую очередь бросаются в глаза поля ```PassengerId, Ticket, Cabin```, кажется он наврятли помогут нам в обучении, а скорее всего внесут только шума и сумятици, их смело можно выбросить.
Посмотрев на оставшиеся, можно выделить следующие группы:

- ```Pclass, Sex, Embarked``` - категориальные
- ```Sibsp, Parch``` - количетсвенные
- ```Age, Fare``` - числовые

Закодируем наши категориальные, которые строки, в число

{%  highlight python %}
def get_map(categories):
    filtered = filter(lambda x: isinstance(x,  str), categories)
    sortered_categories = sorted(filtered)
    return {k:v for v, k in enumerate(sortered_categories, 1)}

sex_map = get_map(data['Sex'].unique())
embarked_map = get_map(data['Embarked'].unique())

data['MappedSex'] = data['Sex'].apply(
    lambda i: sex_map[i])
data['MappedEmbarked'] = data['Embarked'].apply(
    lambda i: embarked_map[i] if isinstance(i, str) else 0)
{% endhighlight %}

Построим поближе на категориальные признаки
{%  highlight python %}
fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(16, 5))
for ax, f in zip(axes.flatten(), ['Pclass', 'MappedSex', 'MappedEmbarked']):
    ax.hist(
        [data[data['Survived'] == 0][f], data[data['Survived'] == 1][f]],
        len(data[f].unique()),
        label=['Survived 0', 'Survived 1'],
        histtype='bar')
    ax.legend(prop={'size': 10}) 
print(sex_map, embarked_map)
{% endhighlight %}
```{'male': 2, 'female': 1} {'C': 1, 'S': 3, 'Q': 2}```
![png](/assets/img/kaggle_titanic_1_1.png)

__Класс__:<br/>
Как видим в 3 классе соотношение количества невыживших к выжившим в несколько раз
больше. В 1 и 2 классе соотношение примерно совпадает, можно попрбовать ужать признак 
до 3 класс ```true/false```

Пол:<br/>
Тут без сюрпризов, женщин среди выживших больше и можно оставить все как есть.

Порт отправления:<br/>
0 категория это ```NaN```. Тут как видно опять в одной из категорий сильный дисбаланс, 
думаю данный признак должен сильно корелировать с классом в котором путешествовал пассажир,
связано с тем что порты находятся в райнах с разным социальным положением. В итоге если можно будет оставить оставить один признак или сжать в один.