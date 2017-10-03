---
title: Kaggle, Titanic. x08
date: 2017-10-03 21:00 
layout: post
tags: машинное обучение, kaggle, catboost
prev_link: /kaggel-titanic-8
next_link: /kaggel-titanic-10
---

Проверим как влияет наличие признака __кабина__

{%  highlight bash %}
train_x['CabinExists'] = data['Cabin'].apply(lambda c: 1 if isinstance(c, str) else 0)
{% endhighlight %}

{%  highlight bash %}
scores = cross_validation.cross_val_score(
    CatBoostClassifier(), train_x, train_y)
print('scores: %s' % ['%.4f' % s for s in scores])
print('mean: %.4f' % np.array(scores).mean())
{% endhighlight %}

{%  highlight bash %}
scores: ['0.7845', '0.8215', '0.8215']
mean: 0.8092
{% endhighlight %}

Как мы можем видет качество ухудшилось, честно я думал что станет хотя бы не хуже. Есть подозрение
что если я добавлю признак палуба и номер каюты, это ничего не даст. Есть еще вариант, что я где-то что-то уже сделал не так. Можно было бы конечно обратиться к интернету посмотреть разные notebooks, но хочется самому прочувстовать весь это процесс одучения от начала и до конца. 

Для продолжения экпериментов надо сначала навести порядок в notebook. Так же воспользоваться методами визуализации которые есть в __catboost__

