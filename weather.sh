#!/bin/bash

# Запрос города через weather-Cli
output=$(weather-Cli get "$1")

# Извлечение данных с использованием регулярных выражений
city=$(echo "$output" | grep "City/Country" | awk '{print $2}')
country=$(echo "$output" | grep "City/Country" | awk -F'/' '{print $2}')
latitude=$(echo "$output" | grep "Latitude" | awk '{print $2}')
longitude=$(echo "$output" | grep "Longitude" | awk '{print $2}')
timezone=$(echo "$output" | grep "Timezone" | awk '{print $2}')
population=$(echo "$output" | grep "Population" | awk '{print $2}')
temperature=$(echo "$output" | grep "Temperature" | awk '{print $2}')
wind_direction=$(echo "$output" | grep "Wind Direction" | awk '{print $3}')
wind_speed=$(echo "$output" | grep "Wind Speed" | awk '{print $3 " " $4}')
condition=$(echo "$output" | grep "Weather Condition" | awk '{print $3}')
humidity=$(echo "$output" | grep "Humidity" | awk '{print $2}')
real_feel=$(echo "$output" | grep "Real Feel" | awk '{print $3}')
surface_pressure=$(echo "$output" | grep "Surface Pressure" | awk '{print $3}')
sealevel_pressure=$(echo "$output" | grep "Sealevel Pressure" | awk '{print $3}')
uv_index=$(echo "$output" | grep "UV Index" | awk '{print $3}')

# Вывод информации на русском языке без рамок
echo "Параметр                 Значение"
echo "------------------------- -------------------------"
echo "Город и страна           $city, $country"
echo "Широта                   $latitude"
echo "Долгота                  $longitude"
echo "Часовой пояс             $timezone"
echo "Население                $population"
echo "Температура              $temperature"
echo "Направление ветра        $wind_direction"
echo "Скорость ветра           $wind_speed"
echo "Погодное состояние       $condition"
echo "Влажность                $humidity"
echo "Ощущаемая температура    $real_feel"
echo "Поверхностное давление   $surface_pressure hPa"
echo "Давление на уровне моря  $sealevel_pressure hPa"
echo "Индекс УФ                $uv_index"
