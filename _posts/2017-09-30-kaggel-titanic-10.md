---
title: Kaggle, Titanic. x09
date: 2017-10-04 22:00 
layout: post
tags: машинное обучение, kaggle, catboost
prev_link: /kaggel-titanic-9
next_link: /kaggel-titanic-11
---

Консольный catboost

Решил я попробовать catboost в консольной версии, т.к. кажется он может работать быстрее ибо чистые "плюсы" и не будет проблем по типу, таких когда python обертка над полученим признаков
не работает.

Сам catboost просто исполняемый файл. Первым делом решил попробовать сразу из CSV обучится,

{%  highlight bash %}
uncaught exception:
    address -> 0x10751a048
    what() -> "catboost/libs/data/load_data.cpp:315: wrong columns number in pool line 2: expected 12, found 13"
    type -> TCatboostException
Аварийный останов (сделан дамп памяти)
{% endhighlight %}

Это только пример ошибки, которые я получал, и пробовал передвать описание признаков, указывать разделитель, наличие заголовка. Все четно. Поэтому решил перевести все формат TSV, написал не большую утилиту для конвертации (надо бы её дополнить и можно будет приложить сюда).

Переконвертировал, попробовал запустить ...

{%  highlight bash %}
uncaught exception:
    address -> 0x107514648
    what() -> "catboost/libs/data/load_data.cpp:333: Factor C123 in column 11 and row 4 is declared as numeric and cannot be parsed as float. Try correcting column description file."
    type -> TCatboostException
Аварийный останов (сделан дамп памяти)
{% endhighlight %}

В общем помните про файл с описанием признаков, у него есть два способа записи:

сокращеная, все колонки которые не указаны, считаются числовыми признаками.
{%  highlight xml %}
0<\t>Target
3<\t>Categ<\t>wind direction
4<\t>Auxiliary
{% endhighlight %}

и полная
{%  highlight xml %}
0<\t>Target<\t>
1<\t>Num
2<\t>Num
3<\t>Categ<\t>wind direction
4<\t>Auxiliary
5<\t>Num
{% endhighlight %}

__ВАЖНО__ Мой вам совет, используйте всегда полную.

С этим я разобрался. Теперь меня ждал другой сюрприз

{%  highlight bash %}
uncaught exception:
    address -> 0x107513b08
    what() -> "catboost/libs/data/load_data.cpp:328: empty values not supported"
    type -> TCatboostException
Аварийный останов (сделан дамп памяти)
{% endhighlight %}

При запуске можно указать ```--nan-mode```, но почему то у меня это не сработало, поэтому пришлося выкинуть все колонки содержащие ```NaN```. В итоге я смог обучится, по ущущениями гораздо быстрее, чем в notebook. Осталось с ```NaN``` разобратся на этапе конвертации и разобрать палубы.

