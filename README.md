CoinsVariationBase
==================

Assign the application - working with the database of stamp varieties of coins of the Russian Empire.
Cause the data structure is often changed along the way, was created the system which makes easy to change it.
Because the application is written mostly in the evenings after work, and because app was redone from qwidgwts to qml (and this process wasn't completly), and just because app is in a state "proof of concept", there is a lot of dirty hacks and just bad code in it. I will try fix the most it. The most obvious bad things:
-a very poor job with the conservation and adding values ​​in the foreign key
-there is no any processing which checks that images using in any table
-very bad user interface


Назначение приложения - работа с базой данных штемпельных разновидностей монет Российской Империи.
Так как структура данных часто менялась по ходу, была придумана система позволяющая  относительно легко ее менять.
Поскольку приложение пишется в основном вечерами после работы и из-за того что по ходу оно было переделано, да и просто по большому счету находится в данный момент в состоянии Proof of concept, в нем порядочное количество грязных хаков и просто говнокода, которые я постараюсь со временем исправить, из наиболее очевидных вещей:
-очень плохая работа с сохранением и подставновкой значений во внешние ключи
-нет обработки ненужности изображений
-совершенно никакой интерфейс сляпанный на коленке