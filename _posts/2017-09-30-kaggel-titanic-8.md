---
title: Kaggle, Titanic. x07
date: 2017-10-02 22:30 
layout: post
tags: машинное обучение, kaggle, catboost
prev_link: /kaggel-titanic-7
next_link: /kaggel-titanic-9
---

Попробуем получить выборку со сбалансированными классами.

Я пытался быстро найти в документации __sklearn__ пример, но у меня не вышло, фукнция кажется простая, поэтому написал сам.

{%  highlight python %}
len_split = train_y[train_y == 1].shape[0]
def get_random_data(x_df, y_df, max_class):
    max_randint = x_df.shape[0]
    x = []
    y = []
    pos_count = 0
    neg_count = 0
    while len(x) < max_class * 2 and len(y) < max_class * 2:
        index = np.random.randint(max_randint - 1)
        if y_df.iloc[index] == 1 and pos_count < max_class:
            x.append(x_df.iloc[index].values)
            y.append(y_df.iloc[index])
            pos_count += 1
        elif y_df.iloc[index] == 0 and neg_count < max_class:
            x.append(x_df.iloc[index].values)
            y.append(y_df.iloc[index])
            neg_count += 1
        else:
            continue
    return x, y
{% endhighlight %} 

И попробуем опять обучится, только возьмем количество итерации 750 вместо 500.
{%  highlight python %}
train_x1, train_y1 = get_random_data(train_x, train_y, len_split)
estimator_4 = CatBoostClassifier(iterations=750)
scores = cross_validation.cross_val_score(
    estimator_4, train_x1, train_y1)
print('scores: %s' % ['%.4f' % s for s in scores])
print('mean: %.4f' % np.array(scores).mean())
{% endhighlight %} 

И опять лажа.
{%  highlight python %}
scores: ['0.8246', '0.8070', '0.8026']
mean: 0.8114
{% endhighlight %} 

Так что мы можем еще сделать, думаю крутить параметры модели смысла нет, все результаты крутятся
вокруг одного числа __0.80__. Попробуем посмотреть на те признаки, которые мы изначально выкинули
и начнем с номера кабина. Кажется кабины на разных палубах и в разных частях коробля могли быть ближе к шлюпках и соответсвенно увелить шанс выживания. Данный признак имеет много пропусков

{%  highlight python %}
data['Cabin'].dropna().shape
{% endhighlight %} 
{%  highlight python %}
(204,)
{% endhighlight %}

Посмотрим на то сколько пассажиров с этим признаком в наших целевых классах
{%  highlight python %}
def calc_cabin(class_):
    percent = (
        data[data['Survived'] == class_]['Cabin'].dropna().shape[0]
        / data[data['Survived'] == class_].shape[0]
    )
    return '{:.2%}'.format(percent)
{% endhighlight %} 
{%  highlight python %}
calc_cabin(1)
{% endhighlight %}
{%  highlight python %}
'39.77%'
{% endhighlight %}
{%  highlight python %}
calc_cabin(0)
{% endhighlight %} 
{%  highlight python %}
'12.39%'
{% endhighlight %}

Как видим уже дает хороший результат можно попробовать использовать признак наличие кабины или нет, а можно разбить на палубы и номера кабин, попробуем оба подхода и посмотрим какой даст лучший результат. Для начала получу все уникальные кабины и палубы.
{%  highlight python %}
cabin_lists = set(data.Cabin.dropna().unique())
def get_cabins_and_decks(cabins_list):
    cabins = set()
    decks = set()
    for cab in cabins_list:
        _ = re.findall(r"(\w)(\d{0,3})", cab)
        for i in itertools.chain.from_iterable(_):
            if i.isdigit():
                cabins.add(int(i))
            else:
                if i: decks.add(i)
    return cabins, decks

{% endhighlight %} 
{%  highlight python %}
cabins, decks = get_cabins_and_decks(cabin_lists)
print(cabins, decks)
{% endhighlight %}

{%  highlight python %}
{
	2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
	24, 25, 26, 27, 28, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 44,
	45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 62, 63, 64, 
	65, 66, 67, 68, 69, 70, 71, 73, 77, 78, 79, 80, 82, 83, 84, 85, 86, 87, 90, 
	91, 92, 93, 94, 95, 96, 98, 99, 101, 102, 103, 104, 106, 110, 111, 118, 121, 
	123, 124, 125, 126, 128, 148
} 
{
	'F', 'A', 'C', 'B', 'E', 'T', 'G', 'D'
}
{% endhighlight %}



