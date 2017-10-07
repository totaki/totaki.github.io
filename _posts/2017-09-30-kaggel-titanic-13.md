---
title: Kaggle, Titanic. x0C
date: 2017-10-07 22:00 
layout: post
tags: машинное обучение, kaggle, catboost
prev_link: /kaggel-titanic-11
next_link: /kaggel-titanic-13
---

Начнем все с нуля. И в топку консольный catboost

На это раз возьмем все признаки, заполним пробелы какой-то, не важжно какой величиной

{%  highlight python %}
train['AgeChanged'] = train['Age'].fillna(train['Age'].min())
train['EmbarkedChanged'] = train['Embarked'].fillna('None')
train['CabinChanged'] = train['Cabin'].fillna('None')

features_for_train = [
    'Pclass',
    'Sex',
    'SibSp',
    'Parch',
    'Ticket',
    'Fare',
    'AgeChanged',
    'EmbarkedChanged',
    'CabinChanged',
    'Name'
]
target = 'Survived'

pool = cb.Pool(train[features_for_train], train[target], cat_features = [1, 4, 7, 8, 9])
cv = cb.cv(pool=pool, params={'loss_function': 'Logloss'})
plt.plot(cv["b'Logloss'_test_avg"], label='test')
plt.plot(cv["b'Logloss'_train_avg"], label='train')
plt.legend()
{% endhighlight %}

![png](/assets/img/001.png)

Картина таже, прямотаки какие-то магическое это число ```0.4```, будем теперь умнее и посмотрим на признаки 

{%  highlight python %}
model = cb.CatBoostClassifier()
model.fit(pool)
model.feature_importances_
{% endhighlight %}

{%  highlight bash %}
[5.931412427417776,
 31.142273508033735,
 1.2565017490279575,
 3.2875442107153665,
 18.651508258006636,
 11.588916663161687,
 12.24529969187031,
 7.149879648477668,
 8.746663843288864,
 0.0]
{% endhighlight %}

Попробуем выбрать из них только 4 самых значящих и посмотрим что получилось.

{%  highlight python %}
def get_features_index(numder, feautures_weights, features):
    indexsed = enumerate(feautures_weights)
    sorted_ = sorted(indexsed, key=lambda f: f[1], reverse=True)
    result = [features[f[0]] for f in sorted_[:numder]] 
    return result

features_for_train_2 = get_features_index(4, model.feature_importances_, features_for_train)
features_for_train_2
{% endhighlight %}
{%  highlight bash %}
['Sex', 'Ticket', 'AgeChanged', 'Fare']
{% endhighlight %}

Интересный набор получился. Посмотрим как это отобразилось на качестве.

{%  highlight python %}
pool2 = cb.Pool(train[features_for_train_2], train[target], cat_features = [0, 1])
cv2 = cb.cv(pool=pool2, params={'loss_function': 'Logloss'})
plt.plot(cv2["b'Logloss'_test_avg"], label='test')
plt.plot(cv2["b'Logloss'_train_avg"], label='train')
plt.legend()
{% endhighlight %}
![png](/assets/img/002.png)

Ну в общем кажется они не шибко изменились, можно работать только с этими признаки сначала.
