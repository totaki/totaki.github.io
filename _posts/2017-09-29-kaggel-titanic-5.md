---
title: Kaggle, Titanic. x04
date: 2017-09-29 20:00 
layout: post
tags: машинное обучение, kaggle, catboost
prev_link: /kaggel-titanic-4
next_link: /kaggel-titanic-6
---

Настало время посмотреть на наши модели, а точнее на метрики которые они нам
выдают на кросс-валидации и попробовать сделать из этого какие-то выводы.

Данные мы уже загрузили в предыдущих эпизодах, сделали mappers для категориальных 
признаков в формате строки. Теперь получим данные для трейна и проверим на пропуски

{%  highlight python %}
train_x = train[['Pclass', 'MappedSex', 'MappedEmbarked'] + ['SibSp', 'Parch'] + ['Age', 'Fare']]
train_x.info()
{% endhighlight %} 

{%  highlight bash %}
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 891 entries, 0 to 890
Data columns (total 7 columns):
Pclass            891 non-null int64
MappedSex         891 non-null int64
MappedEmbarked    891 non-null int64
SibSp             891 non-null int64
Parch             891 non-null int64
Age               714 non-null float64
Fare              891 non-null float64
dtypes: float64(2), int64(5)
memory usage: 48.8 KB
{% endhighlight %}

В возрастном признаке оказались пропуски, просто заполним их средним

{%  highlight python %}
mean_age = train_x['Age'].mean()
train_x['Age'] = train_x['Age'].fillna(mean_age)
train_x.info()
{% endhighlight %} 

{%  highlight bash %}
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 891 entries, 0 to 890
Data columns (total 7 columns):
Pclass            891 non-null int64
MappedSex         891 non-null int64
MappedEmbarked    891 non-null int64
SibSp             891 non-null int64
Parch             891 non-null int64
Age               891 non-null float64
Fare              891 non-null float64
dtypes: float64(2), int64(5)
memory usage: 48.8 KB
{% endhighlight %}

Теперь все впорядке и можно посмотреть на первые результаты, предварительно получив наши метки для обученя.

{%  highlight python %}
train_y = train[target_col]
init_estimator = CatBoostClassifier()
scores = cross_validation.cross_val_score(init_estimator, train_x, train_y)
print('scores: %s' % ['%.4f' % s for s in scores])
print('mean: %.4f' % np.array(scores).mean())
{% endhighlight %} 

{%  highlight bash %}
scores: ['0.7811', '0.8451', '0.8249']
mean: 0.8171
{% endhighlight %}

Получилось не очень впечатляюще, но думаю для практически не обработанных данных норм.
Далее я захотел на то какие признаки наиболее весомые, используя встроенный ```get_feature_importance```. У меня это не получилось сделать, как мне кажется у них какой то баг, т.к. я пробовал несколькими способами это сделать и получал все время ошибку. При том в одной из ошибок я увидел такой код:
{%  highlight python %}
if not isinstance(y, Sequence):
     y = [y]
{% endhighlight %}
Мне кажется не совсем понятным решением.


Ну и ладно, попробуем пойти в лоб, у нас есть категориальные признаки, вещественные и количественные, попробуем обучить модель на этих наборах и посмотрим.

{%  highlight python %}
for features in [count_featuers, num_featuers, ['Pclass', 'MappedSex', 'MappedEmbarked']]:
    _estimator = CatBoostClassifier()
    scores = cross_validation.cross_val_score(_estimator, train_x[features], train_y)
    print('Features: %s' % features)
    print('scores: %s' % ['%.4f' % s for s in scores])
    print('mean: %.4f' % np.array(scores).mean())
{% endhighlight %}

{%  highlight bash %}
Features: ['SibSp', 'Parch']
scores: ['0.6431', '0.6465', '0.7037']
mean: 0.6644
Features: ['Age', 'Fare']
scores: ['0.6465', '0.6599', '0.7205']
mean: 0.6756
Features: ['Pclass', 'MappedSex', 'MappedEmbarked']
scores: ['0.7845', '0.8114', '0.8081']
mean: 0.8013
{% endhighlight %}

Оказалось, что категорильаные признаки дают лучший результат и близкий к начальному, можно попробовать поработать пока только с ними плотнее

