---
title: Kaggle, Titanic. x05
date: 2017-09-30 23:50 
layout: post
tags: машинное обучение, kaggle, catboost
prev_link: /kaggel-titanic-5
next_link: /kaggel-titanic-7
---

Покалдуем над данными. В конце предыдущего поста, я немного пожалуй ошибся решим колдавать над категориальными признаки, тут как раз думаю надо наоборот, попробовать выжить информацию из других.

Начнем с возраста, как помним там был выброс в начале, попробуем всех пассажиров до 15 лет в один, может таким образом мы получим лучшую обощающую функцию.

{%  highlight python %}
train_x['Age_v1'] = train_x['Age'].apply(lambda i: i if i > 15 else 15)
{% endhighlight %} 

Теперь попробуем этот новый признак добавить к категориальным и обучится только на нах
{%  highlight python %}
init_estimator = CatBoostClassifier()
scores = cross_validation.cross_val_score(
    init_estimator, train_x[['Pclass', 'MappedSex', 'MappedEmbarked', 'Age_v1']], train_y)
print('scores: %s' % ['%.4f' % s for s in scores])
print('mean: %.4f' % np.array(scores).mean()){% endhighlight %} 

{%  highlight bash %}
scores: ['0.7980', '0.8215', '0.8047']
mean: 0.8081
{% endhighlight %} 

Как видим результаты не впечатляют, а посмотрим, что нам дает просто возраст

{%  highlight python %}
init_estimator = CatBoostClassifier()
scores = cross_validation.cross_val_score(
    init_estimator, train_x[['Pclass', 'MappedSex', 'MappedEmbarked', 'Age']], train_y)
print('scores: %s' % ['%.4f' % s for s in scores])
print('mean: %.4f' % np.array(scores).mean()){% endhighlight %} 

{%  highlight bash %}
scores: ['0.7946', '0.8215', '0.8249']
mean: 0.8137
{% endhighlight %} 

И тут кажется я пошел вообще не тем путем, может стоил сначала попробовать поиграть с параметрами
классификитора. Благо __sklearn__ нам предоставляет такой инструмент GridSearchCV. Зададим интересующие параметры
{%  highlight bash %}
params = {
    'iterations': [250, 500, 750],
    'border': [0.5, 0.75],
    'depth': [4, 6, 8],
    'learning_rate': [0.03, 0.06, 0.09],
    'rsm': [0.5, 0.7, 1],
    'l2_leaf_reg': [1, 3, 5]
}

estimator_for_params = CatBoostClassifier()
clf = GridSearchCV(estimator_for_params, params)
clf.fit(
    train_x[count_featuers + num_featuers + ['Pclass', 'MappedSex', 'MappedEmbarked']],
    train_y
)
{% endhighlight %} 

На моем компьютере он будет считать не один час, так что результаты можно будет проанализировать только завтра.