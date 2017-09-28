---
title: Kaggle, Titanic. x03
date: 2017-09-28 20:00 
layout: post
tags: машинное обучение, kaggle, catboost
---

Последние в списке, это вещественные признаки.

[Предыдущий эпизод](/kaggel-titanic-3)

Сначала напишем вспомогательную функцию, которая будте нам сторить
на одном полотне два графика, это распреледения выживших и не выживших, в зависимости
от выбранного признака.

{%  highlight python %}
def plot_dist(column_name=None, df=None):
    plt.subplots(nrows=1, ncols=1, figsize=(16, 5))
    for i, c in zip([1, 0], ['blue', 'red']):
        _ = (
        	df[df['Survived'] == i][column_name]
        	if (df is not None)
        	else data[data['Survived'] == i][column_name])
        sns.distplot(_.dropna(), color=c, label='Survived == %s' % i)
    plt.legend()
{% endhighlight %}

Посмотрим на возраст.
{%  highlight python %}
plot_dist('Age')
{% endhighlight %}
![png](/assets/img/kaggle_titanic_3_1.png)

В целом распределение похоже на нормально, но слева видим выброс, посмотрим поближе
{%  highlight python %}
plot_dist(column_name='Age', df=data[data['Age'] <= 15])
{% endhighlight %}
![png](/assets/img/kaggle_titanic_3_2.png)
Дети до 4-х лет выживали в два раза чаще, а с 14 до 14 наоборот, можно подумать смешать их с возрастной меткой 14 и получить нормально распредленный признак.

Теперь посмотрим на распределение стоимости билета
{%  highlight python %}
plot_dist('Fare')
{% endhighlight %}
![png](/assets/img/kaggle_titanic_3_3.png)
Опять видим выброс слева, на этот раз очень большой, присмотримся и к нему
{%  highlight python %}
plot_dist(column_name='Fare', df=data[data['Fare'] <= 100])
{% endhighlight %}
![png](/assets/img/kaggle_titanic_3_4.png)
Тут можно признак разбить категории по стоимости билетов, 0-5, 5-10, 10-50, > 50. В нулевую стоимость возможно попали члены экипажа.

[Следующий эпизод](/kaggel-titanic-5)