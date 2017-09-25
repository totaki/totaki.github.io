---
title: Kaggle, Titanic. Эпизод 0
layout: post
tags: машинное обучение, kaggle, catboost
---
В этом эпизоде я начну с того, что попробую обучить catboost на настройках по-умолчанию. С данными я не буду делать ни какой препроцессинг, только выкину явно лишнее. 

Небольшое отступление, насчет самой задачи, необходимо предсказать выживет ли пассажир, на печально известном
корабле "Титаник". Предлагается dataset со следюущими признаками:

Название|Описание|Принимаемые значения
:---|:---|:---|
survival 	|Выжил 	|0 = Нет, 1 = Да
Pclass 	|Класс билета |1 = высокий, 2 = средний, 3 = низкий
Sex 	|Пол|male=мужчина, female=женщина
Age 	|Возраст| float, если возраст примерный, тогда форма xx.5 	
Sibsp |Количество родственников на борту| int 	
Parch |Количетсво связей родитель/ребенок| int, у некоторых детей 0, т.к. путешествовали с нянями  	
Ticket |Номер билета| string 	
Fare 	|Стоимость билета| float 	
Cabin 	|Номер кабины| string 	
Embarked 	|Порт в котором сел пассажир| C = Cherbourg, Q = Queenstown, S = Southampton


<br/>И так, приступим, первым делом импортируем библиотеки и загрузим данные

{%  highlight python %}
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from catboost import Pool, cv, CatBoostClassifier
from sklearn import cross_validation

train = pd.read_csv('./train.csv')
test = pd.read_csv('./test.csv')
{% endhighlight %}

При первом приближении для обучения можно оставить только следующие признаки и получить данные для обучения
и метки классов.
{%  highlight python %}
features = ['Pclass', 'Sex', 'Age', 'SibSp', 'Parch', 'Fare']
data = train[['Survived'] + features]
data = data.dropna()
train_y = data['Survived']
train_x = data[features]
{% endhighlight %}

Теперь попробуем все это в лоб обучить и отправить первый результат на проверку. C catboost есть нюанс
мы можем передать категориальные признаки напрямую без преобразования, только надо указать в каких колонках
они находятся.
{%  highlight python %}
cat_features = [1]
estimator = CatBoostClassifier()
estimator.fit(train_x, train_y, cat_features=cat_features)
{% endhighlight %}

Получим предксказания
{%  highlight python %}
test_data = test[['PassengerId'] + features]
results_test = list(zip(
	test_data['PassengerId'],
	estimator.predict(test_data[features])
))
result_df = pd.DataFrame(results_test, columns=['PassengerId', 'Survived'])
result_df['Survived'] = result_df['Survived'].astype('int')
result_df.to_csv('test_1_results.csv', index=False)
{% endhighlight %}

### Результат

Итоговая точность ```0.63636``` и ```7958``` место, чуть лучше чем рандом. Кстати я забыл почистить тестовые данные от ```NaN```. В следующем эпизоде попробуем поближе посмотреть на данные.    


