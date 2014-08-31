# WRC-acft

(что-то вроде Wi-fi Remote Control aircraft)

Машинки в своё время катали долго и много, а вот летать (кроме виртуальности) как-то не приходилось.
Надо исправлять это досадное упущение. Так что...

## Альфа-версия

![whole.jpg](https://raw.githubusercontent.com/3bl3gamer/WRC-acft/master/media_v0.1/parts.jpg)

### Что

Модель самолёта Cessna 150. На оригинал похоже не слишком, зато выглядит просто и гуглится неплохо.

### Приборы и материалы

![parts.jpg](https://raw.githubusercontent.com/3bl3gamer/WRC-acft/master/media_v0.1/parts.jpg)

 * Raspberry Pi (R1)
 * RPi-camera (коробок)
 * Wi-Fi-донгл Dlink DWG-G122 ... (на фото случайно не попал)
 * [мотор](https://www.hobbyking.com/hobbyking/store/__25080__NTM_Prop_Drive_28_30S_800KV_300W_Brushless_Motor_short_shaft_version_.html)
 * [регулятор хода](https://www.hobbyking.com/hobbyking/store/__24562__HobbyKing_40A_ESC_4A_UBEC.html)
 * [аккумулятор](https://www.hobbyking.com/hobbyking/store/__9761__Turnigy_1800mAh_4S_20C_Lipo_Pack.html)
 * [пропеллеры](https://www.hobbyking.com/hobbyking/store/__34406__Turnigy_Slow_Fly_Glow_in_the_Dark_Propeller_8x4_5_2pcs_bag_.html)
 * [сервомоторы](https://www.hobbyking.com/hobbyking/store/__32095__Turnigy_TG9z_9g_1_7kg_0_12sec_Eco_Micro_Servo.html) (3 штуки, хотя надо бы 4)
 * бамбуковые шашлычные шампуры
 * 4 листа потолочной плитки
 * и клей для неё

### Софт

Простой.

Клиент (Andriod\_part) получает координаты пальца, переводит в ширину импульса (для PWM),
дописывает сбоку номер GPIO-пина, отправляет полученное в UDP.

Сервер (PRi\_part) слушает UDP, регулирует PWM для запрошенных пинов.

### Результаты

![after.jpg](https://raw.githubusercontent.com/3bl3gamer/WRC-acft/master/media_v0.1/after.jpg)

+3 трещины в корпусе, -1 пропеллер, полноценно взлететь, к сожалению, так и не получилось. Но.

### Выводы

Модель впринципе, способна разогнаться и взлететь с не очень ровной поверхности и может лететь горизонтально.

С направлением мотора и/или центром тяжести вышел косяк.

Управлять ещё учиться и учиться...

...и делать это лучше с дожйстика, а не с сенсорного экрана.

Нужно что-то делать со связью, потому что уже к 50 метрам между клиентом и сервером некоторые пинги начинают теряться.
Нужен специализированный приёмник-передатчик, хотя можно и [так](http://www.sohtell.se/DWL-G122/) попробовать.

И заменить RPIO на [pi-blaster](https://github.com/sarfata/pi-blaster/),
потому что с первым сервомоторы иногда колбасит от малых углов поворота.
