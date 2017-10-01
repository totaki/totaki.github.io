---
title: Kaggle, Titanic. x06
date: 2017-10-01 18:30 
layout: post
tags: машинное обучение, kaggle, catboost
prev_link: /kaggel-titanic-6
next_link: /kaggel-titanic-8
---

За ночь по данной сетки ничего не расчиталось, поэтому будем считать все по одному.

Сначала подготовим общую функцию расчета для каждого параметра

{%  highlight python %}
def get_best_params(params):
    _estimator = CatBoostClassifier()
    _clf = GridSearchCV(_estimator, params)
    _clf.fit(
        train_x[count_featuers + num_featuers + ['Pclass', 'MappedSex', 'MappedEmbarked']],
        train_y
    )
    print(_clf.best_params_)
    return _clf
{% endhighlight %} 


Начнем с параметра ```border```, он отвечает за то какой порог мы будем использовать при отнесении, к тому или иному классу. По умолчанию __0.5__

{%  highlight python %}
border_clf = get_best_params(border=[0.5, 0.6, 0.7]])
{% endhighlight %}
{%  highlight python %}
{'border': 0.6}
{% endhighlight %}

Параметр ```rsm```, отвечает за то какая доля объектов обучающей выборки попадает
в обучение на каждой итерации. По умолчанию __1__
{%  highlight python %}
rsm_clf = get_best_params(rsm=[0.5, 0.7, 1]])
{% endhighlight %}
{%  highlight python %}
{'rsm': 0.7}
{% endhighlight %}

Параметр ```l2_leaf_reg```, отвечает за то сколько минимум объектов должно быть
в каждом листе. По умолчанию __3__
{%  highlight python %}
l2lr_clf = get_best_params(l2_leaf_reg=[3, 5, 7]])
{% endhighlight %}
{%  highlight python %}
{'l2lr': 5}
{% endhighlight %}

Вроде все параметры отличаются от тех которые у нас по умолчанию, так что есть надежда улучшить наши результаты.
{%  highlight python %}
estimator_2 = CatBoostClassifier(**{
        'rsm':0.7, 
        'l2_leaf_reg': 5,
        'border': 0.6
    })
scores = cross_validation.cross_val_score(
    estimator_2, train_x[count_featuers + num_featuers + ['Pclass', 'MappedSex', 'MappedEmbarked']], train_y)
print('scores: %s' % ['%.4f' % s for s in scores])
print('mean: %.4f' % np.array(scores).mean()){% endhighlight %}
{%  highlight python %}
scores: ['0.7912', '0.8249', '0.8249']
mean: 0.8137
{% endhighlight %}

И тут нас ждет разочарование, это хуже чем простое обучение с параметрами по умолчанию ```mean: 0.8227```. Плюс ко всему, с моими ресурсами расчеты проиходят долго, что уменьшает сложность экспериментов. Есть идея работать с уменьшенной выборкой, заодно исправить дисбаланс классов.
{%  highlight python %}
'%.2f' % (len(train_y)/sum(train_y))
{% endhighlight %}
{%  highlight python %}
'2.61'
{% endhighlight %}

