---
title: Kaggle, Titanic. x0D
date: 2017-10-08 22:00 
layout: post
tags: машинное обучение, kaggle, catboost
prev_link: /kaggel-titanic-13
next_link: /kaggel-titanic-15
---
	
Попробуем в последний раз потюнить параметры.

Для это я ниписал свою функцию, сразу отрисовывающую на графике.

На это раз возьмем все признаки, заполним пробелы какой-то, не важжно какой величиной

{%  highlight python %}
def search_best_params(pool, param_name, params_list, base_params={'loss_function': 'Logloss', 'iterations': 250}):
    colors = ['red', 'blue', 'green', 'pink', 'orange']
    colors.reverse()
    for param in params_list:
        color = colors.pop()
        base_params[param_name] = param
        cv = cb.cv(pool=pool, params=base_params)
        print('%s' % param, np.array(cv["b'Logloss'_test_avg"]).mean())
        plt.plot(cv["b'Logloss'_test_avg"], label=('test: %s' % param), color=color)
        plt.plot(cv["b'Logloss'_train_avg"], '--', label=('train: %s' % param), color=color)
    plt.legend()
{% endhighlight %}


### Overfiting detector
![png](/assets/img/003.png)

### L2 regularization
![png](/assets/img/004.png)

### Bagging temperature
![png](/assets/img/005.png)

### Tree depth
![png](/assets/img/006.png)

### Percentage of features to use at each iteration
![png](/assets/img/007.png)

### border_count
![png](/assets/img/008.png)

Как видим никаких более или менее вменяемых результатов не получилось сделать, пожалуй попытки
дойти самостоятельно я оставлю, в репозитории к catboost есть notebook с титаником, посмотрим как там решили задачу.