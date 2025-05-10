# Используем базовый образ из Sail (PHP 8.1)
FROM php:8.1-fpm

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install \
    gd \
    pdo_mysql \
    pdo_pgsql \
    zip \
    bcmath

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Установка Node.js и npm (если требуется для Vite или других фронтенд-задач)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

# Копирование файлов проекта
WORKDIR /var/www
COPY . .

# Установка зависимостей Laravel
RUN composer install --optimize-autoloader --no-dev

# Установка зависимостей фронтенда (если есть package.json)
RUN if [ -f package.json ]; then npm install && npm run build; fi

# Настройка прав доступа
RUN groupadd -g 1000 www-data \
    && useradd -u 1000 -g www-data -m www-data \
    && chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Генерация ключа приложения
RUN php artisan key:generate --force

# Экспозиция порта для Render (10000)
EXPOSE 10000

# Запуск Laravel
CMD php artisan serve --host=0.0.0.0 --port=10000
