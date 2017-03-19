CoinsVariationBase
==================

When I started this project I just wanted to create a database of Russian Imperia's coins with sqlite as data storage. After that I wanted to have ability to change database structure simple way, so I added some structure description in code and used QTableView to display data. Next step was creating struct.json as separate base structure description instead hardcoded one (because I didn't want to recompile all if I just need add one field to table, especially for few platforms - I used Windows and Ubuntu and also started to use Android) and using dinamicly generated qml as GUI (QTableView wasn't good on Android and styling didn't working, butit was in Necessitas time and Android port of Qt actually wasn't beta yet). Next I just began used my application with few bases and got something like simplify (or reduced? :) ) MS Access.

If someone plans to look throw sources, he should remember that this project is just pet project (so I can't spend a lot time to it), it was started with Qt 4.7 and a lot of used components (like Qt.Controls and android support) were unstable when it was firtly used, so it can be a lot dirty hacks in code (I tryed to remove it, but I don't sure that I removed all). Also a documentation (except doxyged comments) is in Russian because I am working alone and it is my native language. English translation is just in plans

https://www.dropbox.com/s/uyl2eiw5a5wcnhx/TestBase.zip?dl=0 - test base zip file. Test base is just more or less featubale piece of russian imperial coin's database (in Russian)

https://www.youtube.com/watch?v=gtKsirSclCg&feature=youtu.be - how it works


Изначально я собирался сделать для себя базу данных по разновидностям монет Российской империи с sqlite в качестве хранилища, но так уж получилось по ряду причин что в процессе мне захотелось иметь возможность быстро поменять структуру базы. Так в коде появилось формальное описание структуры базы, на основании которого данные изначально отрисовываись в QTableView. Позже это описание было вынесено в файл struct.json, за отображение данных стали отвечать динамически сгенеренные qml-файлы, оба этих изменения свзаны с портированием на Android: хотя формально QTableView и работал, он был совершенно не предназначен под мобильные устройства, в частности, скролбары были слишком мелкими, а изменение их с помощью стилей на Android'е не срабатывало (стоит отметить что это было во времена Necessitas, когда порт Qt на Android был даже не в бете), ну а вынесение struct.json связано просто с нежеланием перекомпилировать программу при каждом изменении структуры базы для нескольких платфор. Ну а дальше я просто стал использовать паралельно несколько баз с разной структурой и по факту программа превратилась в некое упрощенное подобие MS Access

Если вдруг кто-то решит заглянуть в исходники, не забывайте что программа пишется в свободное время, к тому же начала писаться еще во времена Qt 4.7 и бет различных компонентов, так что там может быть изрядное количество костылей (я  пытался их убрать, но не уверен что убрал все). Также поскольку я работаю один, зачатки документации есть только на родном для меня русском языке, а перевод на английский пока только в отдаленных планах

https://www.dropbox.com/s/uyl2eiw5a5wcnhx/TestBase.zip?dl=0 - архив с тестовой базой. Тестовая база представляет собой более-менее репрезентативный кусок БД по монетам Российской Империи

https://www.youtube.com/watch?v=gtKsirSclCg&feature=youtu.be - как оно работает
