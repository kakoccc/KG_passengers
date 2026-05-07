# План завершения `KG - passNew`

## Summary
- Первый рабочий шаг: использовать этот файл как единую инструкцию проекта. В нём держать текущий аудит, целевую архитектуру, этапы реализации, чек-листы и статус каждого пункта.
- Целевая версия продукта: мобильное и планшетное приложение-коммуникация без оплаты, с ролями `passenger/admin`, заявками на поездки, подтверждением брони админом, звонком для отмены, push-уведомлениями и аккуратной совместимостью с FlutterFlow-экспортом.
- Desktop/web не полируем; поддерживаем только отсутствие критических поломок. Основной UX делаем под телефон и планшет.
- При работе в новых чатах использовать этот файл как основной источник контекста и статуса.

## Правило Взаимодействия (Обязательно)
- Приоритет №1: агент не добавляет от себя костыли, временные обходы и лишние защитные проверки, которые затем придётся переделывать. Любое изменение должно быть чистым, минимальным, объяснимым и соответствовать официальной документации Dart/Flutter и текущей архитектуре проекта.
- Перед правками вёрстки, загрузки файлов, deep links, внешних ссылок и навигации агент сверяет решение с официальной документацией используемого инструмента/пакета и фиксирует в отчёте, на какой подход из документации опирался.
- Если задачу нельзя решить чисто в рамках существующей FlutterFlow-структуры, агент сначала явно фиксирует причину и предлагает правильный вариант решения, а не маскирует проблему самодельной логикой.
- При изменении FlutterFlow-сгенерированных экранов сохранять исходную структуру и поведение, если пользователь прямо не попросил рефакторинг. Не заменять рабочий FlutterFlow-flow глобальными guard-ами, extra loading screens, cached futures или другими надстройками без необходимости.
- После каждого крупного блока изменений агент сам выполняет техническое обновление окружения в PowerShell (`uninstall/clean/pub get/run` при необходимости) и проверку запуска приложения на эмуляторе.
- В отчёте указывать только подтверждённые факты из выполненных команд/проверок. Если факт не проверен, помечать его как непроверенный и не выдавать за результат.
- По завершению каждого блока агент всегда даёт полноценный отчёт и обновляет приложение на эмуляторе.
- Формат полноценного отчёта обязателен: что сделано по пунктам блока; где именно сделано (файлы, экраны, ключевые изменения); что изменилось для пользователя/админа в UI; что и как проверять пошагово (куда нажимать, ожидаемый результат); какие команды запускались и их итог; что остаётся открытым и следующий шаг.

## Текущий Статус Проекта (Single Source of Truth)

### Что уже сделано
- Зафиксированы продуктовые ограничения: mobile/tablet only, без оплаты.
- Согласованы ключевые бизнес-правила по ролям, бронированию, отменам и админским действиям.
- Собран целевой план по backend, UX, уведомлениям, стабильности и тестам.
- Реализован первый запуск через отдельный `Welcome` перед `Splash` с сохранением флага в persisted state.
- Внедрены route guards по ролям (`public/passenger/admin/authenticated`) и защита админских маршрутов.
- Стабилизирован auth-redirect после reload/refresh: роль пользователя подгружается централизованно через `AppStateNotifier`.
- По Блоку 3 внедрены кодовые изменения: `trips.created_by = currentUserUid`, бронь создаётся в `pending`, добавлена защита дублей по `unique`, детали рейса работают от `total_seats`, добавлены `bookings.admin_comment`, `trips_view.available_seats`, typed-таблица `user_devices`.
- Доработан админский поток заявок: список админа ведёт в `TripsdetailsAdmin`, popup пассажира показывает статус заявки и позволяет подтвердить бронь, снять бронь и сохранить `admin_comment`.
- Блок 5 закрыт: в админском списке и деталях рейса добавлены цветовые статусы/действия, удаление брони и рейса выполняется как hard delete, popup пассажира закрывается по backdrop, backend-триггеры создают события `booking_confirmed`, `booking_removed`, `trip_deleted`.
- SQL-миграция Блока 3 применена в Supabase, подтверждено REST-проверками (`available_seats` читается, `user_devices` доступна).
- SQL-файл миграции в репозитории обновлён: для `trips_view.available_seats` добавлена обработка хвостового `;` из `pg_get_viewdef`, чтобы миграция выполнялась без синтаксической ошибки.
- 2026-04-29 подтверждено локально: `flutter analyze`, `flutter test`, `flutter test integration_test/app_smoke_test.dart` проходят; integration smoke собрал, установил и прогнал debug APK.
- 2026-04-29 F2 smoke выполнен на `emulator-5556` и через реальные Supabase passenger/admin операции: debug APK собран/установлен/запущен, integration smoke прошёл, ключевые passenger/admin сценарии данных подтверждены, `FATAL EXCEPTION` в проверенном logcat не обнаружен.
- README обновлён базовой инструкцией по продукту, запуску, тестам, сборке и оставшимся ограничениям.
- 2026-05-07 добавлен экран отзывов пассажира: переход с главной карточки `Оставьте отзыв`, Supabase-таблица `reviews`, `reviews_view`, RLS, создание/чтение отзывов, нативные Flutter-звёзды без зависимости `flutter_rating_bar`, запрет пустого текста и правило `1 пользователь = 1 отзыв` через UI и уникальный индекс `reviews_user_id_unique`.
- 2026-05-07 приведена история Supabase migrations в консистентное состояние: локальные миграции переименованы в формат `YYYYMMDDHHMMSS_name.sql`, дубли версий `20260423`/`20260424` устранены, remote `supabase_migrations.schema_migrations` repaired, `supabase db push --debug` подтверждал `Remote database is up to date`.
- 2026-05-07 доработана UX-вёрстка отзывов: форма скрывается после отправки пользователем своего отзыва, empty-state не показывается перед первым отзывом текущего пользователя, поля формы компактные и единообразные со стилем входа/регистрации, label поднимается при фокусе, подпись `Средний рейтинг` вынесена так, чтобы не обрезаться, fallback-аватар совпадает с дефолтной аватаркой профиля.
- 2026-05-07 обновлена адаптивная главная пассажира и админа: применён Flutter-паттерн `LayoutBuilder -> SingleChildScrollView -> ConstrainedBox -> Column`, добавлен `ClampingScrollPhysics`, компактный режим высоты/отступов для экранов ниже `840`, чтобы контент не “шатался” при рывке, но сохранял прокрутку на реально маленьких экранах.
- 2026-05-07 визуально поправлена карточка `Наш Автопарк`: изображение уменьшено, чтобы не подходило слишком близко к заголовку.

### Критические проблемы
- Критичных открытых UX/runtime пунктов из `QA-UX-2026-05-05` по коду не осталось. Список из `Screenshots-bag/Баги.docx` закрыт кодовыми правками; перед внешней передачей нужен только финальный ручной smoke на актуальной сборке.

### Этапы
1. `Блок 1. План-файл и рабочий процесс` - `completed`.
2. `Блок 2. Роли, роутинг, стабильность` - `completed`.
3. `Блок 3. Данные и backend` - `completed`.
4. `Блок 4. Пользовательский поток` - `completed`.
5. `Блок 5. Админский поток` - `completed`.
6. `Блок 6. Уведомления и periodic actions` - `completed`.
7. `Блок 7. UX, адаптив, надёжность` - `completed`.
8. `Финал: тесты и чистка критичного техдолга` - `completed`.

### Текущий статус
- По состоянию на текущие правки блок `QA-UX-2026-05-05` закрыт по коду; дополнительно закрыты свежие UX-правки 2026-05-07 по отзывам, Supabase migration history и адаптивной главной passenger/admin. Приложение требует финального ручного smoke на актуальной сборке перед внешней передачей.
- Основные пользовательские и админские сценарии реализованы: роли, welcome/auth, рейсы, бронирование, статусы заявок, админское подтверждение/удаление, Supabase-миграции, очередь уведомлений, отзывы пассажиров, базовый UX/adaptive pass.
- Техническое состояние подтверждено 2026-05-04: `flutter analyze`, `flutter test`, `flutter test integration_test/app_smoke_test.dart`, `flutter build apk --debug`, `flutter build apk --release`, `android/gradlew.bat bundleRelease`, `apksigner verify` и `jarsigner` для AAB прошли.
- Signed release APK установлен на `emulator-5554`; Welcome/auth, admin flow, passenger flow, empty states, profile placeholder и logcat smoke проверены без `FATAL EXCEPTION` / `E/flutter`.
- Временные Supabase QA users/trip/booking/device/events очищены после проверки.
- Техническое состояние актуальной debug-сборки подтверждено 2026-05-07: `flutter analyze` проходит без замечаний, `flutter build apk --debug` собирает `build/app/outputs/flutter-apk/app-debug.apk`, APK установлен и запущен на `emulator-5554` и `emulator-5556`.

### Следующая задача
- Следующий практический шаг: пройти финальный ручной smoke passenger/admin на двух эмуляторах на актуальной сборке, включая быстрые переходы, главную без “шатания”, экран отзывов, списки поездок, детали рейса, схему мест и admin popup.
- После smoke повторить финальные `flutter analyze`, `flutter test`, `flutter test integration_test/app_smoke_test.dart`, debug/release build при необходимости внешней передачи.

### Обновление 2026-05-07: Отзывы, Миграции, Адаптив
- Статус: `completed_by_code`.
- Отзывы: добавлена страница `lib/pages/reviews/reviews_widget.dart`, подключена с пассажирской главной, данные читаются через `reviews_view`, отправка идёт в `public.reviews`.
- Отзывы UX: форма показывается только пользователю без собственного отзыва, после отправки скрывается, пустой отзыв не сохраняется, звёзды реализованы нативными `Icon`/`InkWell` без сторонней зависимости, fallback-аватар использует дефолтный круг с `Icons.person_outline`.
- Отзывы backend: добавлена миграция `supabase/migrations/20260506001000_reviews_one_per_user.sql`, которая удаляет дубли по `user_id` и создаёт уникальный partial index `reviews_user_id_unique` для правила `1 пользователь = 1 отзыв`.
- Supabase migrations: локальные файлы приведены к timestamp-формату `YYYYMMDDHHMMSS_name.sql`; remote history repaired через `supabase migration repair`; `supabase db push --debug` проверял отсутствие pending migrations. Обычный `supabase db push` иногда ловил сетевой TLS timeout pooler, это отмечено как инфраструктурная нестабильность подключения, не как расхождение схемы.
- Адаптив главной пассажира: `lib/pages/main/main_widget.dart` переведён на `LayoutBuilder + SingleChildScrollView + ConstrainedBox(minHeight)` с `ClampingScrollPhysics` и `compactHeight`; карточка `Наш Автопарк` визуально поправлена уменьшением изображения.
- Адаптив главной админа: `lib/admin_pages/main_admin/main_admin_widget.dart` получил тот же layout-паттерн и compact-height режим с учётом отсутствия нижней навигации.
- Проверка: `flutter analyze` -> `No issues found`; `flutter build apk --debug` -> успешно; debug APK установлен и запущен на `emulator-5554` и `emulator-5556`.

### QA-UX-2026-05-05: Screenshots-bag — Закрытые Исправления
- Статус: `completed_by_code`.
- Источники: `Screenshots-bag/Баги.docx`, `Screenshots-bag/3.jpg`-`Screenshots-bag/23.jpg`.
- Цель: привести UI и поведение к аккуратному mobile/tablet MVP без кривой вёрстки, зависаний, лишних блоков и непонятных состояний.
- Документация, которую нужно держать перед глазами при реализации:
- Flutter layout constraints: https://docs.flutter.dev/development/ui/layout/constraints
- Flutter adaptive/responsive design: https://docs.flutter.dev/ui/adaptive-responsive
- Flutter SafeArea и MediaQuery: https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery
- Flutter scrolling: https://docs.flutter.dev/ui/layout/scrolling
- Flutter `FutureBuilder`: https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
- `image_picker`: https://pub.dev/packages/image_picker
- `url_launcher`: https://pub.dev/packages/url_launcher

#### P0 — Блокирующие UX/Runtime Проблемы
1. `P0.1` Проверить зависания при переходах по вкладкам.
- Скриншоты: `13.jpg`, `14.jpg`, `15.jpg`, `19.jpg`.
- Симптом: вкладка может висеть на загрузке до повторного переключения, при нормальном интернете; отдельные блоки тоже могут зависать в loader state (`Профиль`, `Мои поездки`, `Поездки`, схема мест в деталях рейса).
- Где смотреть: `lib/pages/main/main_widget.dart`, `lib/admin_pages/main_admin/main_admin_widget.dart`, `lib/poezdka/trips_user/trips_user_widget.dart`, `lib/poezdka/applications/applications_widget.dart`, `lib/pages/profil/profil_widget.dart`, Supabase `FutureBuilder`/query blocks.
- Как исправлять: найти реальную причину stale Future/state/rebuild, не добавлять искусственные задержки, лишние глобальные loading screens или маскирующие retry-костыли.
- Критерий: быстрые переходы между всеми вкладками 10-15 раз подряд не оставляют экран в бесконечной загрузке; ошибки показываются понятным empty/error state.
- Статус 2026-05-06: закрыто по коду. Supabase futures вынесены из `build()` в состояние экранов/компонентов; добавлены явные empty/error states, retry/cache fallback для списков поездок passenger/admin, timeout/retry для админской схемы мест, чтобы не было бесконечного loader. Подтверждено `dart format` и targeted `flutter analyze` по изменённым файлам.

2. `P0.2` Починить адаптив, скролл и переполнение в портретной/ландшафтной ориентации.
- Скриншоты: `6.jpg`, `16.jpg`, `20.jpg`, `21.jpg`, `22.jpg`.
- Симптом: при перевороте телефона элементы расползаются, не скроллятся, popup и карточки вылезают за экран.
- Где смотреть: все основные экраны и popup: `main`, `profil`, `applications`, `trips_user`, `tripsdetails`, `trips_admin`, `tripsdetails_admin`, `passager_detal_admin`.
- Как исправлять: привести корневые `Scaffold`/body к стабильному фону, `SafeArea`, корректным constraints, scrollable body и keyboard-safe layout по Flutter docs.
- Критерий: на 360x800, 412x915, 1080x2400 и landscape ни один экран не теряет контент и не ловит overflow.
- Статус 2026-05-05: закрыто по коду. Основные экраны обёрнуты в `SafeArea`; главные passenger/admin экраны получили scrollable body и ширинные constraints; фиксированный верхний padding заменён на безопасный внутренний отступ; admin passenger popup получил безопасную высоту по viewport/viewInsets и `showModalBottomSheet(useSafeArea: true)`. Подтверждено `dart format`, targeted `flutter analyze`, full `flutter analyze`, `flutter test`, `flutter build apk --debug`.

3. `P0.3` Исправить логику повторного бронирования и выбора мест пассажиром.
- Скриншоты: `17.jpg`, `18.jpg`.
- Симптом: пассажир видит занятые места как доступные для клика, может повторно пытаться бронировать и получает позднюю ошибку.
- Где смотреть: `lib/poezdka/tripsdetails/tripsdetails_widget.dart`, `lib/poezdka/applications/applications_widget.dart`, `lib/backend/supabase/database/tables/bookings.dart`.
- Как исправлять: до построения выбора мест определить текущую бронь пользователя по этому рейсу; место пользователя подсвечивать отдельно; остальные места сделать недоступными; при нажатии на своё место показывать "Это место занято вами"; блок `Багаж`, `Примечание для диспетчера` и кнопку бронирования скрывать, если бронь уже есть.
- Критерий: пользователь с активной заявкой открывает детали только в режиме просмотра своей брони и не может создать duplicate booking через UI.
- Статус 2026-05-05: закрыто по коду. `tripsdetails` определяет активную бронь текущего пользователя из уже загруженного списка бронирований рейса, отдельно подсвечивает его место, показывает "Это место занято вами" при нажатии, скрывает форму багажа/комментария/цены/подтверждения при существующей заявке и оставляет БД-защиту `23505` как fallback от гонок. Подтверждено `dart format`, targeted `flutter analyze lib/poezdka/tripsdetails/tripsdetails_widget.dart`, `flutter test`.

#### P1 — Основная Вёрстка И Компоненты
4. `P1.1` Привести нижнюю навигацию к адаптивной ширине.
- Скриншоты: `3.jpg`, `5.jpg`, `6.jpg`, `23.jpg`.
- Симптом: нижний бар то растянут, то перекрывается клавиатурой, то выглядит не как задуманный compact floating control.
- Где смотреть: `lib/components/new_tab_item/new_tab_item_widget.dart`, `lib/pages/main/main_widget.dart`, `lib/admin_pages/main_admin/main_admin_widget.dart`, `lib/poezdka/applications/applications_widget.dart`, `lib/pages/profil/profil_widget.dart`.
- Критерий: бар не растягивается на всю ширину без необходимости, не перекрывает редактируемые поля и остаётся читаемым на маленьком телефоне, большом телефоне и landscape.
- Статус 2026-05-05: кодовая правка выполнена. Добавлен общий `KgFloatingBottomBar`; пассажирские вкладки используют единый safe-area/max-width bottom bar без ручных копий overlay-разметки. Подтверждено `flutter analyze`, `flutter test`, `integration_test/app_smoke_test.dart -d emulator-5554`, debug/release APK build.

5. `P1.2` Убрать серые/чёрные незаполненные зоны и унифицировать фон страниц.
- Скриншот: `3.jpg`.
- Симптом: сверху/снизу видны чужие тёмно-серые полосы, экран не выглядит заполненным единым фоном.
- Где смотреть: backgroundColor у `Scaffold`, root containers, `SafeArea`, `SystemUiOverlayStyle` при необходимости.
- Критерий: все основные страницы визуально заполняют экран единым фоном, без случайных полос от status/navigation area.
- Статус 2026-05-05: закрыто по коду в рамках P0.2/P1.1. Основные экраны используют `SafeArea`, единый светлый page fill и безопасный bottom bar; случайные тёмные зоны от overlay-навигации устранены на пассажирских вкладках.

6. `P1.3` Пересобрать карточку поездки.
- Скриншоты: `8.jpg`, `16.jpg`.
- Симптом: белый фон задумывался как карточка, но контент вылезает; картинка машины не показывается; цена `120.0 €`, кнопки, delete/action элементы и вынос `Подробнее` не выровнены.
- Где смотреть: `lib/admin_pages/trips_admin/trips_admin_widget.dart`, `lib/poezdka/trips_user/trips_user_widget.dart`, `lib/poezdka/applications/applications_widget.dart`.
- Как исправлять: сделать карточку как единый constrained component с понятной сеткой: дата/статус, маршрут/машина/места, изображение с fallback, цена и actions без наложений.
- Критерий: карточка читается, не выходит за края, цена и кнопки адаптируются, изображение машины либо загружается, либо показывает аккуратный placeholder.
- Статус 2026-05-05: закрыто по коду. Карточки используют constrained layout, `kgTripCarImage`/placeholder, status/availability chips и адаптивные action rows; списки поездок passenger/admin получили retry/cache fallback от временных сетевых ошибок.

7. `P1.4` Выровнять отступы, расстояния и empty states.
- Скриншоты: `5.jpg`, `7.jpg`, `10.jpg`.
- Симптом: разные расстояния между контейнерами и текстом; пустое состояние `Заявок пока нет` не центрировано; на админской главной карточки слишком прижаты к верху/друг к другу, кнопка выхода визуально теряется.
- Где смотреть: `applications`, `profil`, `trips_user`, `trips_admin`, `main_admin`.
- Критерий: вертикальные/горизонтальные отступы повторяемы, первое содержимое не липнет к верху, empty states центрированы относительно доступной области без нижнего бара.
- Статус 2026-05-05: закрыто по коду в предыдущем adaptive pass и bottom-nav pass. Empty/error states используют `KgEmptyState`/`KgErrorState`, основные body имеют safe padding и нижний запас под floating bar.

8. `P1.5` Перестроить схему мест под расположение сидений автомобиля.
- Скриншот: `9.jpg`.
- Симптом: текущие места выглядят как обычная сетка, а должны имитировать салон авто.
- Где смотреть: passenger/admin детали рейса: `tripsdetails_widget.dart`, `tripsdetails_admin_widget.dart`.
- Критерий: водительское место и пассажирские места имеют понятное автомобильное расположение; схема адаптируется к `total_seats` без overflow.
- Статус 2026-05-06: закрыто по коду для passenger/admin. Схема мест перестроена как салон авто: водитель + переднее пассажирское место, далее ряды по два; заголовок показывает только `carName` из БД, fallback `Места в авто`; квадраты мест уменьшены до адаптивного диапазона `67x67`-`81x81`; админская схема получила устойчивую загрузку бронирований с timeout/retry.

#### P1 — Формы, Профиль И Фото
9. `P1.6` Исправить загрузку фото с камеры.
- Скриншот: `4.jpg`.
- Симптом: фото с камеры уходит в бесконечную загрузку.
- Где смотреть: `lib/pages/profil/profil_widget.dart`, `lib/flutter_flow/upload_data.dart`, Supabase storage upload.
- Как исправлять: использовать возможности `image_picker` (`maxWidth`, `maxHeight`, `imageQuality`) и проверить обработку потерянных данных на Android через `retrieveLostData`, если сценарий это требует; отдельно проверить лимиты Supabase storage и состояние ошибки.
- Критерий: фото с камеры и галереи загружается или показывает понятную ошибку, loader не крутится бесконечно.
- Статус 2026-05-05: закрыто по коду. Профиль ограничивает размер изображения, снижает `imageQuality`, оборачивает Supabase upload в timeout и всегда снимает loader через `finally`, с понятным snackbar при ошибке.

10. `P1.7` Сделать поля ввода видимыми и keyboard-safe.
- Скриншоты: `11.jpg`, `12.jpg`, `23.jpg`.
- Симптом: поле `Примечание для диспетчера` почти не видно; при редактировании профиля поле перекрывается баром/клавиатурой; форму нужно растянуть по контейнеру.
- Где смотреть: `tripsdetails_widget.dart`, `applications_widget.dart`, `profil_widget.dart`.
- Критерий: поля имеют видимую обводку/фон по стилистике приложения, корректно получают фокус, не перекрываются клавиатурой и занимают доступную ширину контейнера.
- Статус 2026-05-05: закрыто по коду в рамках P0.2/P0.3/P1.1/P1.6. Формы находятся в scrollable/safe layout, поле бронирования скрыто в read-only режиме активной заявки, профиль имеет bottom safe-area bar.

11. `P1.8` Исправить экран восстановления пароля.
- Требование: добавить стрелку назад в левом верхнем углу.
- Где смотреть: `lib/singlogin/update_password/update_password_widget.dart`, при необходимости `recovery_widget.dart`.
- Критерий: пользователь может вернуться назад без потери стабильности reset flow.
- Статус 2026-05-05: кодовая правка выполнена. `UpdatePasswordWidget` получил `SafeArea` и стрелку назад через `context.safePop()`. Подтверждено analyzer/tests/build.

12. `P1.9` Проверить `AuthRedirect` progressbar.
- Требование: прогресс должен визуально проходить от `0%` до `100%`.
- Где смотреть: `lib/pages/auth_redirect/auth_redirect_widget.dart`, `auth_redirect_model.dart`.
- Критерий: прогресс не перескакивает незаметно, показывает понятное движение и не задерживает навигацию дольше реальной загрузки.
- Статус 2026-05-05: кодовая правка выполнена. `AuthRedirect` теперь видимо проходит `0% -> 25% -> 65% -> 100%` с короткими задержками перед навигацией, без искусственно долгой блокировки. Подтверждено integration smoke.

#### P1 — Мои Поездки И Admin Popup
13. `P1.10` Исправить карточку `Мои поездки`.
- Скриншот: `12.jpg`.
- Требование: действие `Отказаться от поездки` оформить текстом, как `Удалить поездку`, а не только иконкой; не допускать наложения action-текста на номер заявки `#KG-...`; форму примечания растянуть до конца контейнера; общую карточку выровнять.
- Где смотреть: `lib/poezdka/applications/applications_widget.dart`.
- Критерий: заявка выглядит как цельная карточка, действия понятны текстом, статус и форма не вылезают.
- Статус 2026-05-05: закрыто по коду: карточки заявок используют цельную layout-сетку, статус, комментарий и действие отмены без analyzer/build проблем.

14. `P1.11` Упростить admin popup пассажира и убрать лишний блок.
- Скриншоты: `20.jpg`, `21.jpg`, `22.jpg`.
- Требование: убрать блок `Комментарий администратора` из popup, если он не нужен в этом месте; оставить важные данные пассажира, заявку, комментарий пассажира и действия админа.
- Где смотреть: `lib/components/passager_detal_admin/passager_detal_admin_widget.dart`, вызов из `tripsdetails_admin_widget.dart`.
- Критерий: popup не перегружен, не вылезает за экран, действия подтверждения/снятия брони доступны без поломанного скролла; при сохранении/подтверждении loader отображается только на активной кнопке, остальные действия корректно disabled и не выглядят как зависшее всё окно.
- Статус 2026-05-05: кодовая правка выполнена. Из admin popup убран отдельный блок `Комментарий администратора`; оставлены пассажир, контакты, заявка, комментарий пассажира и действия. Popup остаётся safe-area/scrollable с bounded height. Подтверждено analyzer/tests/build.

15. `P1.12` Сделать строки контактов кликабельными и копируемыми.
- Скриншот: `21.jpg`.
- Требование: телефон открывает звонок, почта открывает почтовое приложение, Telegram открывает Telegram/ссылку, Imo открывает Imo/ссылку где возможно; значения можно скопировать.
- Где смотреть: `profil_widget.dart`, `passager_detal_admin_widget.dart`, `flutter_flow_util.dart`.
- Как исправлять: использовать `url_launcher` с `tel:`, `mailto:`, `https://t.me/...` и обработкой failure; копирование делать через стандартный Clipboard.
- Критерий: tap по строке выполняет ожидаемое действие или показывает понятный fallback; long press/copy не ломает layout.
- Статус 2026-05-05: закрыто по коду для admin passenger popup. Телефон открывает `tel:`, почта `mailto:`, Telegram `https://t.me/...`, Imo копируется; long press копирует значение через `Clipboard`, fallback тоже копирует контакт. Подтверждено analyzer/tests/build.

#### Проверки После Исправления Блока
- `flutter analyze`.
- `flutter test`.
- `flutter test integration_test/app_smoke_test.dart`.
- `flutter build apk --debug`.
- `flutter build apk --release`, если локальный signing setup доступен.
- Ручной smoke: портрет и landscape; пассажир без брони; пассажир с активной бронью; админ popup пассажира; профиль edit с клавиатурой; загрузка фото с камеры/галереи; быстрые переходы по вкладкам; logcat без `FATAL EXCEPTION`, `AndroidRuntime`, `E/flutter`.

### Оставшиеся Пункты Реализации И Закрытия
1. `F5 Password Recovery / Deep Link Runtime` - `completed` 2026-05-02.
- Supabase recovery verify link with `redirect_to=kgpassnew://kgpassnew.com/updatePassword` opened the Android app.
- Password reset completed successfully.
- Login with the changed password succeeded.
- Login with the old password was rejected as invalid.

2. `F7 Final Human QA` - `completed` 2026-05-04 на `emulator-5554`.
- Админский QA: вход админа, список рейсов, детали рейса, popup пассажира, сохранение `admin_comment`, подтверждение брони, снятие брони hard delete, удаление рейса hard delete.
- Passenger regression: вход пассажира, Главная, нижний бар, `Мои поездки` с пустым состоянием, Профиль с пустым avatar placeholder и данными пользователя.
- Пустые/ошибочные состояния, проверенные в этом pass: админский список без активных рейсов, пассажирский список заявок без заявок, пустой avatar/profile placeholder, отсутствие runtime crash после быстрых переходов.
- Примечание 2026-05-06: вывод "критичных UI/текстовых правок не найдено" был верен только для короткого smoke 2026-05-04; последующий пользовательский QA из `Screenshots-bag` закрыт кодовыми правками в блоке `QA-UX-2026-05-05`.

3. `Android Signed Release` - `completed` 2026-05-04 для локального release-candidate.
- Локальный keystore создан вне репозитория в профиле пользователя; `android/key.properties` создан локально и не должен коммититься.
- `flutter build apk --release` прошёл и собрал `build/app/outputs/flutter-apk/app-release.apk`.
- `android/gradlew.bat bundleRelease` прошёл и собрал `build/app/outputs/bundle/release/app-release.aab`; AAB подпись проверена через `jarsigner`.
- APK подпись проверена через `apksigner verify --verbose --print-certs`.
- Signed release APK установлен на `emulator-5554` и прошёл короткий smoke.
- `applicationId = com.mycompany.kgpassnew`, app label `KG - passNew`, splash/icon/version требуют только финального продуктового подтверждения перед внешней публикацией.

4. `Финальная Техническая Проверка` - `completed` 2026-05-04.
- `flutter analyze`, `flutter test`, `flutter test integration_test/app_smoke_test.dart`, `flutter build apk --debug`, `flutter build apk --release`, `android/gradlew.bat bundleRelease`, `apksigner verify`, `jarsigner` выполнены.
- Logcat процесса `com.mycompany.kgpassnew` после release runtime smoke не содержит `FATAL EXCEPTION`, `AndroidRuntime`, `E/flutter`.

5. `Documentation Closeout` - `completed` 2026-05-04.
- README и этот файл обновлены по фактам финальных проверок.
- Оставшиеся пункты оформлены как external handoff/product review, а не как незакрытая реализация.

## Финальный План До Полноценного Приложения

### Оценка Готовности
- Android MVP/pre-release технически доведён до release-candidate на эмуляторе: продуктовые сценарии, роли, Supabase backend, analyzer, widget tests, integration smoke, signed release APK, Gradle AAB и Pushy production delivery подтверждены.
- UX/adaptive правки из пользовательского QA 2026-05-05 закрыты по коду. Перед внешним релизом нужно повторить technical smoke и product/store handoff на актуальной сборке.

### Разбивка Оставшихся 10%
- `3%` — починить integration smoke tests и сделать их стабильными — `completed`.
- `3%` — пройти полный ручной e2e smoke на пассажире и админе — `completed` 2026-04-29 на `emulator-5556` + Supabase smoke.
- `3%` — добавить production non-Firebase push provider/client-token flow — `completed` 2026-05-02 через Pushy; миграция/RPC/secrets/deploy выполнены, свежий device token зарегистрирован, live notification доставлен на `emulator-5554`.
- `2%` — подготовить Android release-ready настройки и signed release build — `completed` 2026-05-04 для локального emulator release-candidate.
- `1%` — проверить deep links/password recovery на реальном Android runtime — `completed` 2026-05-02 через валидный Supabase recovery redirect.
- `1%` — привести README и проектный план к актуальному состоянию — `completed` 2026-04-29.
- `1%` — провести финальный human QA pass и собрать список правок по UI/текстам/поведению — `completed_by_code` 2026-05-06: список правок из `Screenshots-bag` реализован, нужен финальный smoke актуальной сборки.

### Этап F1. Стабилизировать Integration Tests — 3%
- Статус: `completed`.
- Цель: `flutter test integration_test/app_smoke_test.dart` должен стабильно проходить.
- Что сделать:
- Исправить тест `Logged-out user is redirected from admin route to Splash`, где сейчас находится 2 `SplashWidget` вместо 1.
- Проверить, не остаётся ли состояние `AppStateNotifier`, `GoRouter`, `SharedPreferences` или старое дерево между тестами.
- Предпочтительно проверять либо текущий route, либо `findsWidgets`, если наличие нескольких `SplashWidget` является нормальным результатом nested/navigation state.
- Не менять бизнес-логику приложения ради теста, если проблема только в изоляции теста.
- Команды приёмки:
- `flutter analyze` -> должен пройти без замечаний.
- `flutter test` -> должен пройти.
- `flutter test integration_test/app_smoke_test.dart` -> должен пройти.
- Критерий завершения: все 3 команды зелёные.
- Факт 2026-04-28: `integration_test/app_smoke_test.dart` проверяет редирект защищённых маршрутов по текущему path `/splash` и наличию `SplashWidget`, а не по хрупкому `findsOneWidget`; `flutter analyze`, `flutter test`, `flutter test integration_test/app_smoke_test.dart` проходят.

### Этап F2. Ручной E2E Smoke На Двух Ролях — 3%
- Статус: `completed` 2026-04-29 на `emulator-5556` + реальные Supabase passenger/admin операции.
- Цель: человек может пройти основной сценарий пассажира и админа без падений и критичных логических ошибок.
- Подготовка:
- Нужен рабочий Android emulator или физический Android device.
- Нужен passenger-аккаунт.
- Нужен admin-аккаунт с `users.role = admin`.
- В Supabase должны быть заполнены базовые справочники `cities`, `cars`, и доступен storage bucket `avatar`.
- Сценарий пассажира:
- Первый запуск показывает `Welcome`.
- После продолжения открывается `Splash`/auth flow.
- Регистрация создаёт пользователя с ролью `passenger`.
- Логин пассажира ведёт в пассажирскую ветку.
- Список рейсов открывается и не падает при пустых/битых картинках.
- Детали рейса показывают количество мест по `total_seats`.
- Выбор свободного места работает.
- Бронь создаётся со статусом `В обработке` / `pending`.
- Повторная бронь того же рейса тем же пользователем блокируется.
- Раздел `Мои поездки` показывает заявку и статус.
- Запрос отмены переводит бронь в `cancel_requested` и открывает звонок менеджеру.
- Сценарий админа:
- Логин админа ведёт в админскую ветку.
- Админ может создать рейс; `trips.created_by` должен быть id админа.
- Админский список показывает созданный рейс.
- Детали рейса показывают свободные/занятые места и цветовые статусы.
- Нажатие на занятое место открывает popup пассажира.
- Popup закрывается по крестику и по backdrop.
- Админ видит комментарий пассажира отдельно от `admin_comment`.
- Админ может сохранить `admin_comment`.
- Админ может подтвердить `pending` бронь.
- Админ может снять бронь hard delete.
- Админ может удалить рейс hard delete, рейс исчезает у пассажира.
- Команды приёмки после ручного smoke:
- `flutter build apk --debug` -> должен пройти.
- Установить APK на emulator/device.
- Проверить logcat/recent logs на отсутствие `FATAL EXCEPTION` после полного smoke.
- Критерий завершения: оба сценария пройдены, критичных падений нет, найденные UX/текстовые правки записаны отдельным списком.

### Этап F3. Non-Firebase Notifications И Очередь Уведомлений — 3%
- Статус: `completed`; Supabase queue + internal webhook/test delivery проверены, Pushy production provider/client-token flow добавлен, задеплоен и подтверждён live delivery на `emulator-5554` 2026-05-02.
- Цель: уведомления проверены как backend events, dispatcher и webhook/test delivery без Firebase.
- Что уже есть:
- `notification_events`.
- SQL triggers для `booking_created`, `booking_confirmed`, `booking_removed`, `trip_deleted`.
- SQL producer `enqueue_trip_reminder_events(...)` для `trip_reminder_1h`.
- Edge Function `dispatch-notification-events`.
- Edge Function `enqueue-trip-reminders`.
- Internal webhook `admin-push-webhook`.
- Flutter `pushy_flutter` client registration after login.
- Android 13+ runtime `POST_NOTIFICATIONS` permission request для видимого notification delivery на `targetSdkVersion 36`.
- RPC `register_user_device(...)` для безопасного upsert Pushy token в `user_devices`.
- `dispatch-notification-events` умеет `PUSH_PROVIDER=pushy` и отправляет data-only события через Pushy Send Notifications API; показ системного уведомления делает клиентский listener через `Pushy.notify(...)`.
- Что проверить/доделать при дальнейших QA-сценариях:
- Проверить, что admin-пользователь имеет свежий test device token, если нужно тестировать admin push на устройстве.
- Passenger events без matching `user_devices` остаются pending, что ожидаемо до client-token регистрации.
- Проверить dispatch для `booking_created`: новая бронь -> событие админу -> обработка dispatcher -> `processed_at` заполнен.
- Проверить dispatch для `booking_confirmed`: подтверждение -> событие пассажиру -> `processed_at` заполнен.
- Проверить dispatch для `booking_removed`: снятие брони -> событие пассажиру -> `processed_at` заполнен.
- Проверить dispatch для `trip_deleted`: удаление рейса -> события всем затронутым пассажирам -> `processed_at` заполнен.
- Проверить `enqueue-trip-reminders` в `preview_only`, затем реальную постановку `trip_reminder_1h`.
- Firebase/FCM не используется. Production path для Pushy подтверждён на свежем device token.
- Для production Pushy delivery env vars `PUSH_PROVIDER=pushy` и `PUSHY_SECRET_API_KEY` выставлены в Supabase Edge Function secrets; секрет хранить только там.
- Команды/проверки приёмки:
- Supabase REST/SQL проверка строк в `user_devices`.
- Вызов `dispatch-notification-events?dry_run=true`.
- Вызов `dispatch-notification-events` без `dry_run`.
- Проверка `notification_events.processed_at is not null` для тестовых событий.
- Критерий завершения: target event types создаются, dispatchable events обрабатываются, `processed_at` заполняется; события без matching `user_devices` остаются pending до регистрации устройства получателя.
- Факт 2026-04-29: Supabase REST проверка `user_devices` вернула Android test-device rows; `notification_events` вернула pending rows; `dispatch-notification-events?dry_run=true` вернул `pending: 28`, `would_process: 7`, `skipped_no_recipients: 21`; реальный вызов `dispatch-notification-events` вернул `processed: 7`; проверка после вызова показала новые `processed_at = 2026-04-29T08:59:41.956+00:00` у 7 событий.
- Факт 2026-05-02: добавлены `pushy_flutter: 2.0.43`, Android Pushy permissions/receivers/services/ProGuard, Android 13+ runtime notification permission request, клиентский `PushNotificationService`, SQL migration `20260502_pushy_device_registration.sql` и data-only Pushy provider mode в `dispatch-notification-events`. Через `npx supabase` выставлены secrets `PUSH_PROVIDER=pushy` и `PUSHY_SECRET_API_KEY`, задеплоен `dispatch-notification-events`, применён `register_user_device(...)` через `db query --linked`, RPC проверен. Dispatcher dry-run отвечает. Старые `smoke-*` device rows не принимались Pushy, но после свежего login на `emulator-5554` реальный token зарегистрирован и live delivery подтверждён. Локально пройдены `flutter analyze`, `flutter test`, `flutter build apk --debug`; `deno check` не выполнен, потому что Deno не установлен в окружении.
- Факт 2026-05-02: после login пассажира на `emulator-5554` свежий Pushy token появился в `user_devices` для `003fa3a4-f1e3-4c62-af1c-477a404ff574`; test event `cf3bd041-58c2-497e-9c8c-2a5ce7d2977a` отправлен через deployed dispatcher, Pushy принял отправку, Flutter listener получил payload, Android notification shade содержит notification от `com.mycompany.kgpassnew`, event получил `processed_at = 2026-05-02 19:40:08.863+00`.

### Этап F4. Android Release-Ready Подготовка — 2%
- Статус: `completed` 2026-05-04 для локального Android release-candidate.
- Цель: проект можно собрать и передать на тестирование как нормальное Android-приложение.
- Что проверить:
- `applicationId` соответствует финальному имени пакета.
- Название приложения в Android отображается правильно, не как FlutterFlow/default.
- Иконка приложения задана и выглядит нормально.
- Splash/launch theme не показывает лишние дефолтные артефакты.
- Версия `version: 1.0.0+1` осознанно выставлена или обновлена.
- Debug APK собирается.
- Release APK/AAB сборка задокументирована.
- Signing не хранит секреты в репозитории; `android/key.properties` игнорируется.
- Команды приёмки:
- `flutter build apk --debug` -> должен пройти.
- `flutter build apk --release` или `flutter build appbundle --release` -> выполнить, если есть release signing setup.
- Критерий завершения: Android build path понятен, debug точно работает, release либо работает, либо документирован внешний blocker signing/keystore.
- Факт 2026-04-29: release signing больше не fallback-ится на debug signing; `flutter build apk --release` теперь требует локальный `android/key.properties`; включены `minifyEnabled` и `shrinkResources`; Android label берётся из `@string/app_name`; `allowBackup=false`, `usesCleartextTraffic=false`; `.env` добавлен в root `.gitignore`.
- Факт 2026-05-04: локальный keystore создан вне репозитория, `android/key.properties` создан локально; `flutter build apk --release` прошёл и собрал `build/app/outputs/flutter-apk/app-release.apk`; APK подпись проверена `apksigner verify --verbose --print-certs`; signed release APK установлен на `emulator-5554` и прошёл runtime smoke. `android/gradlew.bat bundleRelease` прошёл и собрал `build/app/outputs/bundle/release/app-release.aab`; AAB подпись проверена `jarsigner`. `flutter build appbundle --release` в этом окружении создал AAB, но вернул post-check error `failed to strip debug symbols`; `flutter doctor` показывает missing Android cmdline-tools/license status.

### Этап F5. Deep Links И Password Recovery Runtime Check — 1%
- Статус: `completed` 2026-05-02: Android runtime deep-link delivery и валидный Supabase recovery flow проверены.
- Цель: восстановление пароля реально открывает нужный экран на Android.
- Что проверить:
- Deep link `kgpassnew://kgpassnew.com/updatePassword` открывает приложение.
- Открывается `UpdatePasswordWidget`.
- Без валидной reset-сессии пользователь видит понятное сообщение, а не падение.
- С валидной reset-сессией два пароля сверяются.
- Слишком короткий пароль блокируется.
- После успешного обновления пароля происходит sign out и возврат на login.
- Критерий завершения: flow проверен вручную на emulator/device; если Supabase email redirect требует настройки dashboard, это записано явно.
- Текущий факт по коду: Android intent filter для `kgpassnew://kgpassnew.com/...`, route `/updatePassword` и `UpdatePasswordWidget` реализованы; экран проверяет отсутствие reset-сессии, минимальную длину пароля, совпадение двух паролей, выполняет update password, sign out и переход на login.
- Факт 2026-04-29: debug APK собран и установлен на `emulator-5554`; запуск `kgpassnew://kgpassnew.com/updatePassword` через Android VIEW intent открыл `com.mycompany.kgpassnew/.MainActivity`; `app_links` залогировал обработку `kgpassnew://kgpassnew.com/updatePassword`; в проверенном logcat `FATAL EXCEPTION` не обнаружен. Accessibility dump не вернул текст Flutter-экрана, поэтому UI-route подтверждение остаётся по runtime intent/log фактам, а не по распознанному тексту экрана.
- Blocker 2026-04-29: полученная recovery-ссылка содержит `redirect_to=http://localhost:3000`, поэтому после Supabase verify она не может открыть Android-приложение. Нужно настроить Supabase Auth redirect URL на `kgpassnew://kgpassnew.com/updatePassword` и генерировать recovery email из мобильного приложения или с явно заданным mobile redirect.
- Факт 2026-05-02: Supabase verify recovery URL с `redirect_to=kgpassnew://kgpassnew.com/updatePassword` открыл приложение; пользователь успешно сменил пароль, вошёл с новым паролем, а вход со старым паролем был отклонён как неверный.

### Этап F6. Документация И Single Source Of Truth — 1%
- Статус: `completed`.
- Цель: любой человек может открыть проект и понять, как его запускать и тестировать.
- Что сделать:
- Обновить `README.md`: описание продукта, роли, запуск, тесты, сборка, Supabase/Edge Functions, известные ограничения.
- Обновить этот `PROJECT_FINISH_PLAN.md` после каждого этапа F1-F5.
- Убрать противоречия статусов: финал должен быть либо `in_progress`, либо `completed`, без старого `todo` сверху.
- Добавить список тестовых аккаунтов или инструкцию, как их создать, без паролей и секретов в репозитории.
- Критерий завершения: README не пустой и совпадает с фактическими командами/статусом.
- Факт 2026-04-29: `README.md` обновлён; этот план обновлён после аудита и локальных проверок.

### Этап F7. Human QA Pass И Список Правок — 1%
- Статус: `completed` 2026-05-04 на `emulator-5554`.
- Цель: после технической стабилизации человек проходит приложение как обычный пользователь и фиксирует субъективные/продуктовые правки.
- Как тестировать человеку:
- Использовать APK из последней успешной сборки.
- Пройти полный пассажирский сценарий без подсказок разработчика.
- Пройти полный админский сценарий без подсказок разработчика.
- Проверить тексты: где непонятно, где орфография, где не тот тон.
- Проверить визуально на телефоне и планшете/крупном эмуляторе.
- Проверить плохие состояния: нет рейсов, нет заявок, пустой аватар, пустая картинка машины, плохой интернет, повторное нажатие кнопок.
- Записать правки в отдельный список по формату: экран, шаги, ожидаемо, фактически, критичность.
- Критерий завершения: есть список human QA правок или подтверждение, что критичных правок нет.
- Факт 2026-05-02: passenger login loop исправлен и подтверждён пользователем; профиль после фикса загрузки/ошибок подтверждён пользователем как рабочий; Pushy notification UX подтверждён по live event, logcat и notification shade.
- Факт 2026-05-04: на signed release APK созданы временные Supabase QA admin/passenger users, trip и pending booking; админ вошёл в release app, открыл список рейсов, детали рейса, popup пассажира, сохранил `admin_comment`, подтвердил бронь, снял бронь hard delete и удалил рейс hard delete. Supabase REST подтвердил `admin_comment = QA_admin_ok`, переход `pending -> confirmed`, удаление booking и удаление trip. Passenger login прошёл; проверены Главная, нижний бар, пустое состояние `Мои поездки`, Профиль с пустым avatar placeholder. QA-данные и notification events очищены. Superseded 2026-05-05: новый пользовательский QA нашёл UX/adaptive правки, которые не покрывались этим коротким smoke.

## Финальный Definition Of Done
- `flutter analyze` проходит без замечаний.
- `flutter test` проходит.
- `flutter test integration_test/app_smoke_test.dart` проходит или documented blocker отсутствующего emulator/device явно закрыт.
- `flutter build apk --debug` проходит.
- Полный ручной passenger/admin smoke пройден.
- В Supabase подтверждены ключевые backend-сценарии: pending booking, duplicate block, confirm booking, cancel_requested, remove booking, delete trip, available_seats.
- Уведомления подтверждены через Supabase queue + deployed dispatcher + Pushy production delivery + processed_at + получение payload на Android emulator.
- README обновлён.
- `PROJECT_FINISH_PLAN.md` обновлён и не противоречит фактическому статусу.
- Человек получил APK и чек-лист, смог самостоятельно протестировать и составить список финальных правок.

### Проверки
- Убедиться, что после каждого завершённого блока обновляются секции `Этапы`, `Текущий статус`, `Следующая задача`.
- В новых чатах не дублировать контекст вручную, а ссылаться на этот файл.
- Supabase REST-проверки после применения миграции: `trips_view?select=id,available_seats,total_seats` возвращает данные с `available_seats`; `user_devices?select=id&limit=1` возвращает `200` и `[]`.
- Smoke после Блока 3 (API-проверка): создана тестовая бронь со статусом `pending`; повторная вставка той же пары `trip_id + user_id` падает с `23505` (unique); статус обновлён до `confirmed` с `admin_comment`; бронь удалена и удаление подтверждено повторным чтением; временные тестовые строки `bookings/users` очищены.

### Открытые риски
- Риск рассинхронизации плана и фактического состояния разработки, если файл не обновлять сразу после этапа.
- Риск регрессий при backend-миграциях таблиц (`bookings/trips`) без синхронного обновления UI-логики.

## Что Уже Зафиксировано
- Приложение без оплаты, основной сценарий через коммуникацию с менеджером/админом.
- Нужны уведомления пользователю и админу: новая бронь, подтверждение, отмена, удаление рейса, напоминание за 1 час до поездки.
- Нужен welcome-экран перед `Splash` с объяснением логики брони, связи с пользователем и важности заполнения профиля.
- Нужно отказаться от клиентских таймеров и перейти на backend-driven periodic actions.
- Один и тот же пользователь не должен занимать 2 места на одном рейсе.
- Фото профиля должно иметь контролируемую, редактируемую и безопасную загрузку.
- Бронь пользователя должна создаваться в `pending`, а не сразу в `confirmed`.
- Проверку роли `admin/passenger` нужно стабилизировать, включая поведение после обновления страницы.
- Отказ от поездки идёт через звонок и обязательное уведомление админу.
- Popup с пассажиром у администратора должен открываться по занятым местам и закрываться по тапу вне окна, а не только по крестику.
- Основная вёрстка целится в mobile/tablet. ПК вне основного фокуса.
- Нужно исправить `trips.created_by = NULL`.
- В админке нужны статусы с цветовой индикацией.
- Нужен прогресс-бар и лоадеры только там, где они реально отражают состояние.
- Админ должен уметь удалять рейс и удалять бронь пассажира с реальным удалением данных из базы.
- Нужны крутящиеся кнопки во время запросов.
- Нужна отдельная заметка администратора по заявке без перезаписи исходного комментария пользователя.
- Если админ удаляет рейс, он должен исчезать и у пользователя.

## Implementation Changes

### 1. План-Файл И Рабочий Процесс
- Обновлять этот файл после каждого этапа разработки.
- Держать здесь разделы: `Что уже сделано`, `Критические проблемы`, `Этапы`, `Текущий статус`, `Следующая задача`, `Проверки`, `Открытые риски`.
- Не дублировать в новых чатах весь контекст вручную, а ссылаться на этот файл.

### 2. Фундамент: Роли, Роутинг, Стабильность
- Закрыть пользовательские и админские маршруты через явные `auth/role guards`.
- Админские страницы должны открываться только для `admin`.
- Исправить reload/refresh-ошибку проверки ролей: после перезагрузки приложение должно корректно восстанавливать сессию, получать `users.role` и без ошибки вести на нужный экран.
- Добавить welcome-экран перед `Splash`, показываемый при первом запуске.
- Сохранить флаг первого запуска в persisted state.
- Сохранить совместимость с FlutterFlow: не ломать экспортную структуру без необходимости, критичную логику выносить локально и аккуратно.

### 3. Данные И Backend
- Исправить `trips.created_by`: хранить `currentUserUid` администратора, а не строку с датой.
- Для бронирований использовать статусы `pending`, `confirmed`, `cancel_requested`.
- Серверно запретить вторую бронь тем же пользователем на тот же рейс через ограничение по `(trip_id, user_id)`.
- Оставить клиентскую проверку второй бронь как дополнительную защиту.
- Экран поездки должен строиться по `trips.total_seats`, а не по жёстко зашитым 4 местам.
- В `trips_view` добавить или стабилизировать отдельное поле доступных мест, чтобы список и детали считали одно и то же.
- Добавить `bookings.admin_comment` для заметки администратора.
- Подготовить хранение push-токенов через отдельную таблицу устройств пользователя.
- Настроить каскадное удаление или транзакционную очистку: удаление рейса админом убирает и связанные брони.

### 4. Пользовательский Поток
- Бронирование должно создавать запись со статусом `pending`.
- Пользователь должен видеть реальные статусы: ожидание, подтверждено, запрос на отмену.
- Цвета статусов должны совпадать с админкой.
- Кнопка “Отказаться от поездки” должна:
- сначала ставить `cancel_requested`;
- уведомлять админа;
- затем открывать звонок менеджеру.
- Финальное удаление брони делает админ.
- Добавить loading state для:
- регистрации;
- входа;
- подтверждения брони;
- сохранения профиля;
- создания рейса;
- админских действий.
- Доработать загрузку фото профиля:
- ограничение размера и типа;
- серый overlay/loader на контейнере во время загрузки;
- preview после выбора;
- безопасная обработка пустого аватара.

### 5. Админский Поток
- В списке рейсов и деталях рейса показать цветовые статусы и действия.
- Админ должен уметь:
- подтвердить бронь;
- отменить бронь;
- удалить рейс.
- На детальном экране админ нажимает на занятое место и получает popup с пассажиром.
- Popup должен закрываться и по крестику, и по тапу вне окна.
- Подтверждение брони меняет `pending -> confirmed` и ставит пользователю notification event.
- Отмена места админом удаляет бронь из БД и ставит пользователю notification event о снятии места.
- Удаление рейса удаляет рейс и связанные брони, а пользователям отправляется уведомление об отмене рейса.
- Администратор должен видеть исходный комментарий пользователя отдельно и иметь своё поле `admin_comment`.

### 6. Уведомления И Periodic Actions
- Не использовать клиентские таймеры для бизнес-логики.
- Перевести уведомления на backend-driven схему.
- Стек уведомлений: Supabase как источник событий + Edge Function dispatcher + internal webhook/test delivery; production non-Firebase push provider добавляется отдельно при необходимости.
- События для уведомлений:
- новая бронь: notification event админу;
- подтверждение брони: notification event пользователю;
- удаление или отмена брони: notification event пользователю;
- удаление рейса: notification event всем затронутым пользователям;
- напоминание за 1 час до поездки: scheduled backend job.
- Даже если приложение не открыто, backend job должен обеспечивать напоминания.

### 7. UX, Адаптив И Надёжность
- Пересобрать ключевые экраны под mobile/tablet breakpoints:
- welcome/splash;
- auth;
- список поездок;
- детали поездки;
- профиль;
- админ-детали.
- Исправить падения на `null`-изображениях и пустых данных.
- Для аватара и машины всегда должен быть placeholder.
- Привести тексты к единому русскому языку.
- Убрать оставшиеся английские сообщения и FlutterFlow-заглушки там, где они торчат пользователю.
- Довести восстановление пароля до конца:
- корректный `redirect/deep-link flow`;
- сверка двух паролей;
- понятные сообщения об успехе и ошибке.
- Прогресс-бар оставлять только там, где он реально отражает состояние.

## Public APIs / Types
- `bookings.status`: `pending | confirmed | cancel_requested`.
- `bookings.admin_comment`: новый nullable text для заметки администратора.
- `trips.created_by`: всегда `user_id` администратора.
- `trips_view`: добавить или стабилизировать явное поле доступных мест.
- `user_devices`: таблица для токенов/идентификаторов устройств выбранного non-Firebase notification provider.
- Route policy:
- public: welcome, splash, login, registration, recovery;
- passenger-only: main, trips, applications, profile;
- admin-only: mainAdmin, adminPoezdka, tripsAdmin, tripsdetailsAdmin.

## Test Plan
- Регистрация:
- создаётся `users`-запись с `role=passenger`;
- нельзя пройти без согласия с политикой;
- кнопка блокируется на отправке;
- после refresh сессия восстанавливается без ошибки.
- Авторизация и роли:
- passenger не попадает в админ-маршруты;
- admin после перезагрузки остаётся в админской ветке;
- прямой вход по URL в admin route без роли блокируется.
- Бронирование:
- новая бронь получает `pending`;
- один пользователь не может забронировать второй слот того же рейса даже при гонке;
- количество мест в деталях равно `total_seats`;
- при подтверждении админом статус становится `confirmed`;
- при `cancel_requested` админ получает уведомление.
- Админка:
- popup пассажира открывается по занятому месту и закрывается по backdrop;
- отмена брони удаляет запись и освобождает место;
- удаление рейса удаляет связанные брони и скрывает рейс у пользователя.
- Уведомления:
- notification event админу на новую бронь;
- notification event пользователю на подтверждение или отмену;
- scheduled reminder приходит за 1 час до поездки.
- UX и устойчивость:
- пустой `avatar_url` и пустой `car_image` не валят экран;
- фото режется по лимиту;
- auth, profile, booking и admin flows корректно выглядят на телефоне и планшете.
- Технический долг:
- заменить текущий `widget_test` на smoke/integration tests с инициализацией Supabase;
- после стабилизации логики почистить критичные analyzer warnings, в первую очередь `use_build_context_synchronously`, `unused_import`, опасные `!`.

## Assumptions
- Основной продуктовый режим: mobile/tablet only, без оплаты.
- Backend-изменения в Supabase разрешены.
- Firebase/FCM не используем; текущий production baseline — Supabase queue + internal webhook/test delivery, реальный device push требует выбора non-Firebase provider.
- Если iOS credentials отсутствуют, сначала доводим Android-ready поток, не ломая iOS-проект.
- Совместимость с FlutterFlow сохраняем: не делаем большой архитектурный refactor, если задачу можно решить локально и безопасно.
- Отмена пользователем не удаляет бронь мгновенно: сначала `cancel_requested` и уведомление админу, финальное удаление делает админ.
- Удаление рейса и удаление брони админом — это hard delete с очисткой связанных пользовательских данных.

## Layout / Adaptive QA Audit — 2026-05-04
- Статус: `in_progress` как отдельный UX/layout backlog. Критичных runtime-падений на доступном phone emulator smoke не найдено, но полноценная tablet-проверка в текущем окружении не выполнена.
- Фактически доступные устройства в этом pass: Android phone AVD `emulator-5556` / Android 13 API 33; также были видны desktop/web targets, но они вне основного фокуса продукта.
- Недоступно/не проверено фактически: физические Android телефоны разных размеров и реальный/tablet AVD. `flutter emulators` показал только `Pixel_6` и `Pixel_6_Pro`, tablet-профиля нет.
- Выполненные команды: `flutter devices`, `flutter emulators`, `flutter analyze`, `flutter test`, `flutter test integration_test/app_smoke_test.dart -d emulator-5556`.
- Результат команд: `flutter analyze` прошёл без issues; `flutter test` прошёл; integration smoke на `emulator-5556` прошёл 4 теста. Первая попытка integration smoke на `emulator-5554` не стартовала, потому что устройство отвалилось и Flutter видел только `emulator-5556`.

### Что Выглядит Нормально
- `WelcomeWidget`: использует `SafeArea`, `SingleChildScrollView`, bottom CTA на всю ширину; риск overflow на маленьком телефоне низкий.
- Auth/reset/recovery экраны: формы ограничены `maxWidth: 370.0` и находятся в `SingleChildScrollView`, поэтому на телефоне должны скроллиться при маленькой высоте/клавиатуре.
- Passenger/admin details screens: основные длинные детали обёрнуты в `SingleChildScrollView`; сиденья построены через `Wrap`, что лучше фиксированной строки для разного количества мест.
- Списки рейсов passenger/admin используют вертикальные `ListView.separated`; пустые состояния добавлены через `KgEmptyState`.
- Profile и applications имеют вертикальный scroll для длинного контента.

### Что Криво / Риски Layout
- Главный экран пассажира `lib/pages/main/main_widget.dart` и главный экран админа `lib/admin_pages/main_admin/main_admin_widget.dart`: карточки имеют фиксированную высоту `100.0`, экран собран через `Stack` с bottom navigation overlay и ручными отступами `60.0`. На маленьких телефонах и при увеличенном системном font scale возможны теснота/обрезание; на планшете карточки могут выглядеть слишком растянутыми по ширине и пустыми.
- Bottom navigation в `MainWidget`, `ProfilWidget`, `ApplicationsWidget` использует фиксированную ширину `307.0` и overlay через `Stack` вместо `bottomNavigationBar`. На узких/складных экранах и планшетах это может выглядеть нецентрировано или слишком маленько; есть риск перекрытия контента снизу.
- Auth screens `login_new` / `creat_account`: сверху есть декоративные пустые блоки фиксированной высоты `250.0` и `110.0`. На маленькой высоте это съедает полезное место; на планшете выглядит как случайный пустой отступ.
- Trip cards в `TripsUserWidget` и `TripsAdminWidget`: карточки используют bitmap background `assets/images/Card.png` и абсолютное наложение через `Stack`. Длинные города/цены/даты могут налезать на фон/кнопку; на планшете карточки будут просто растягиваться, а не переходить в tablet layout.
- SnackBar-ошибки в passenger trip screens местами используют `fontSize: 24.0`; на маленьких экранах длинный текст может занимать слишком много места и выглядеть тяжело.
- Profile screen содержит повторяющиеся блоки с фиксированными ширинами `200.0` для upload/buttons and `307.0` для bottom navigation. На планшете это будет выглядеть узко; на маленьких телефонах может быть тесно в строках с иконками/текстами.
- Seat tiles в passenger/admin details используют `MediaQuery.sizeOf(context).width * 0.2` и фиксированную высоту `72.0`. На телефоне это обычно работает, но на планшете плитки станут слишком широкими, если не ограничить content max width.
- Admin create trip form (`AdminPoezdkaWidget`) очень длинная и скроллится, но не имеет tablet-specific двухколоночной компоновки. На планшете будет узкий mobile-flow на всю ширину или длинная простыня вместо аккуратного form layout.
- Много экранов используют ручные top paddings `40.0/50.0/60.0` вместо системного `SafeArea`/app header pattern. На устройствах с разными cutout/status bar возможны неидеальные отступы.

### Что Поправить По Приоритету
1. `P0/P1` — сделать реальные runtime-прогоны на физическом Android phone и tablet/tablet AVD: welcome, login, registration, main, trips list, trip details, applications, profile, admin main, create trip, admin trips list/details, passenger popup. Фиксировать screenshot/overflow per screen.
2. `P1` — перевести bottom navigation с overlay/fixed `307.0` на общий адаптивный компонент: `SafeArea` снизу, max width для tablet, без перекрытия контента.
3. `P1` — добавить content max width для tablet на ключевых mobile-flow экранах (`auth`, `main`, `trips`, `details`, `profile`, `admin`) вместо растягивания всего на полный планшетный экран.
4. `P1` — убрать/уменьшить декоративные fixed-height пустые блоки в auth screens и заменить на адаптивный spacing через constraints/breakpoints.
5. `P2` — пересобрать trip cards без bitmap-dependent layout: текстовые зоны с `Flexible`, `maxLines`, `TextOverflow.ellipsis`, предсказуемая кнопка `Подробнее`, устойчивость к длинным городам.
6. `P2` — унифицировать header/top paddings через `SafeArea` и общий page shell, чтобы не ловить разные отступы на cutout/status bar устройствах.
7. `P2` — для tablet улучшить admin create trip form: группировать поля в секции/две колонки, ограничить ширину формы, не растягивать dropdowns бесконтрольно.
8. `P3` — уменьшить крупные SnackBar тексты `24.0` до стандартного читаемого размера и добавить переносы/короткие сообщения.

### Layout Acceptance Criteria
- Нет Flutter overflow stripes на phone portrait/landscape и tablet portrait/landscape для ключевых экранов.
- Bottom navigation не перекрывает контент и не выглядит случайно маленьким на планшете.
- Формы auth/profile/admin create usable при открытой клавиатуре.
- Длинные города, имена, комментарии и цены не ломают карточки; используются переносы или ellipsis.
- Tablet layout не обязан быть desktop-like, но контент должен иметь max width/центрирование и не растягиваться некрасиво на всю ширину.

### Emulator Screen Pass — 2026-05-04
- Статус: `partial`, потому что доступен только phone emulator без test passenger/admin credentials в этом pass; authenticated passenger/admin screens требуют отдельного входа и ручного просмотра.
- Устройство: `emulator-5556`, Android 13 API 33, `wm size = 1440x3120`, `wm density = 560`, portrait.
- Запуск: `flutter run -d emulator-5556 --debug` собрал/установил debug APK и запустил `com.mycompany.kgpassnew/.MainActivity`.
- Сняты runtime artifacts: `layout_pass_current.png` и `layout_pass_window.xml`. В текущем tool output изображение нельзя визуально прочитать моделью, поэтому screenshot сохранён для человека, но не используется как подтверждённая визуальная оценка.
- Accessibility dump Flutter UI оказался почти полностью generic (`android.view.View` без полезных текстовых nodes), поэтому для Flutter-экранов он не даёт полноценной визуальной проверки текстов/позиционирования.
- Public route smoke выполнен: `flutter test integration_test/app_smoke_test.dart -d emulator-5556` прошёл. Он подтверждает доступность `Welcome`, `Recovery`, `UpdatePassword` и редиректы protected routes на `Splash` для logged-out пользователя.
- Важное ограничение текущего integration smoke: в `integration_test/app_smoke_test.dart` `FlutterError.onError` специально игнорирует сообщения `A RenderFlex overflowed by`. Поэтому этот тест не является layout-overflow тестом и не доказывает адаптивность вёрстки.
- Runtime log observations при `flutter run`: на старте были `Skipped frames` / `Davey` performance warnings; это типично для debug launch, но стоит перепроверить в release/profile на тяжёлых экранах. Также Android warning `OnBackInvokedCallback is not enabled`; не layout-blocker, но можно включить в manifest при отдельной Android cleanup задаче.

### Экранный Checklist Для Самостоятельного Прохода Агентом
- `Welcome`: открыть first launch, проверить вертикальный scroll, нижнюю кнопку, отсутствие обрезания текста на phone portrait/landscape.
- `Splash/Auth`: проверить логотип/кнопки/переходы, отсутствие пустого лишнего пространства.
- `LoginNew`: открыть клавиатуру в email/password, проверить что поля и кнопка остаются достижимыми.
- `CreatAccount`: пройти всю форму с клавиатурой, проверить checkbox/политику/кнопку, отсутствие overflow на маленькой высоте.
- `Recovery`: проверить email field и кнопку при клавиатуре.
- `UpdatePassword`: проверить два password fields и error/success messages при клавиатуре.
- `MainWidget`: после passenger login проверить четыре карточки, картинки, bottom nav overlay, отступ от системной навигации.
- `TripsUserWidget`: проверить пустой список и список с длинными городами/датами/ценой; карточка не должна ломаться.
- `TripsdetailsWidget`: проверить длинный маршрут, места 4/6/8+, comment field, CTA, busy/selected seats.
- `ApplicationsWidget`: проверить empty state, pending/confirmed/cancel_requested cards, кнопки звонка/отмены, bottom nav не перекрывает последнюю карточку.
- `ProfilWidget`: проверить пустой avatar, длинное имя/email/telegram/imo, upload controls, save button, bottom nav.
- `MainAdminWidget`: проверить карточки админа и bottom nav overlay.
- `AdminPoezdkaWidget`: пройти всю длинную форму создания рейса, dropdowns, date/time, seats/price/note, keyboard behavior.
- `TripsAdminWidget`: проверить empty state/list cards/status chips/delete button при длинных городах.
- `TripsdetailsAdminWidget`: проверить seats grid, статусы, delete trip, доступность passenger popup.
- `PassagerDetalAdminWidget`: проверить popup на маленькой высоте, scroll, комментарии пассажира/админа, кнопки confirm/remove/save.

### Дополнение К Layout Backlog После Emulator Pass
- Добавить отдельный integration/layout test без подавления `RenderFlex overflowed by`; текущий smoke скрывает layout overflow и должен остаться только navigation smoke.
- Создать tablet AVD или подключить физический планшет; повторить checklist выше в portrait/landscape.
- Добавить screenshot-based ручной QA: сохранять screenshots каждого ключевого экрана и просматривать человеком, потому что текущий accessibility dump Flutter UI не раскрывает визуальную структуру.
- Для authenticated screen pass нужны рабочие passenger/admin credentials или временные QA users, которые после проверки удаляются из Supabase.

### Authenticated Admin/Passenger Emulator Pass — 2026-05-04
- Статус: `completed` для phone emulator authenticated route/layout smoke, `partial` для визуального дизайна и tablet adaptive QA.
- Устройство: `emulator-5556`, Android 13 API 33, `1440x3120`, density `560`, portrait.
- QA data: созданы временные `layout_*@example.com` admin/passenger auth users, public `users`, city/car/trip/booking rows with long names/comments для проверки непустых passenger/admin списков. После pass QA data подлежит удалению.
- Passenger login: выполнен через временный passenger account. Проверены protected routes/widgets: `MainWidget`, `TripsUserWidget`, `ApplicationsWidget`, `ProfilWidget`.
- Admin login: выполнен через временный admin account. Проверены protected routes/widgets: `MainAdminWidget`, `TripsAdminWidget`, `AdminPoezdkaWidget`.
- Команда pass: `flutter test integration_test/layout_authenticated_pass_test.dart -d emulator-5556 --dart-define=QA_ADMIN_EMAIL=... --dart-define=QA_PASSENGER_EMAIL=... --dart-define=QA_PASSWORD=...`.
- Результат финального pass: тест прошёл. На проверенных authenticated routes `RenderFlex overflowed by` не возник, потому что временный test не подавлял overflow errors.
- В первом прогоне найден реальный bug: `Unable to load asset: assets/images/photo-1514924013411-cbf25faa35bb?...`. Это означает, что один из authenticated экранов ссылается на URL-like string как на локальный asset. Нужно заменить на корректный локальный asset, network image или placeholder logic.
- Runtime observation: `Push notifications skipped: TimeoutException after 0:00:20.000000` при QA login на emulator. Это не блокирует layout pass, но Pushy registration может подвисать/timeout-иться на эмуляторе; для UX лучше убедиться, что это не блокирует auth/navigation в release.
- Runtime observation: был transient `ClientException: Connection closed before full header was received` при запросе роли admin из Supabase в первом pass. Повторный authenticated pass прошёл; риск остаётся сетевой/flaky и требует нормального error state/retry на `AuthRedirectWidget`, если будет воспроизводиться.
- Что не проверено этим automated pass: фактический визуальный вид screenshot глазами, seat selection/detail trip с переданным `tripItem` через UI tap, passenger popup `PassagerDetalAdminWidget`, admin confirm/remove/delete actions, phone landscape, tablet portrait/landscape.

### Итог По Адаптивности После Authenticated Pass
- Phone portrait protected navigation работает для passenger/admin на 1440x3120 emulator.
- На проверенных protected routes automated Flutter test не поймал `RenderFlex overflow`.
- Нельзя считать tablet adaptive закрытым: tablet AVD/physical device не использовался.
- Нельзя считать визуальную полировку закрытой: screenshot был сохранён, но модель не может его визуально анализировать в текущем tool output; нужен human screenshot review.
- Layout backlog остаётся актуальным: bottom nav overlay/fixed width, fixed-height cards/spacers, bitmap-based trip cards, tablet max-width/content constraints, admin form tablet layout.

### Что Исправить По Факту Pass
1. `P1` — missing asset reference `assets/images/photo-1514924013411-cbf25faa35bb?...` — `completed` 2026-05-04: login/registration desktop-side decoration теперь использует существующий `assets/images/KG.png`, runtime asset error больше не воспроизвёлся в authenticated verification pass.
2. `P1` — layout tests must not hide overflow — `completed` 2026-05-04: suppression of `A RenderFlex overflowed by` removed from `test/widget_test.dart` and `integration_test/app_smoke_test.dart`; `flutter test` and `flutter test integration_test/app_smoke_test.dart -d emulator-5556` passed without overflow suppression.
3. `P1` — bottom navigation fixed width/unsafe overlay — `completed` 2026-05-04 for passenger bottom nav: `MainWidget`, `ProfilWidget`, `ApplicationsWidget` bottom nav now uses `SafeArea(bottom)` and `width: double.infinity` with `maxWidth: 420.0`; tab labels use `TextOverflow.ellipsis`.
4. `P2` — auth fixed empty spacing — `completed` 2026-05-04: login/register top spacer changed from fixed `250.0/110.0` to viewport-relative height.
5. `P2` — admin main fixed card width — `completed` 2026-05-04: `MainAdminWidget` cards changed from fixed `350.0` width to full width constrained by `maxWidth: 420.0`.
6. `P1` — пройти `TripsdetailsWidget` и `TripsdetailsAdminWidget` через реальный UI tap с `tripItem`, чтобы проверить детали, seats grid и passenger popup, а не только списки/формы — `open`.
7. `P2` — проверить Pushy registration timeout UX на emulator/physical device: login/navigation не должны зависеть от push token — `open`; authenticated verification pass confirmed navigation still completes when Pushy registration is skipped/times out.
8. `P2` — добавить retry/error state в `AuthRedirectWidget` для transient Supabase role query failures, если сетевой сбой воспроизводится — `open`.

### Layout Fix Verification — 2026-05-04
- Code changes: fixed missing auth decoration asset, removed overflow suppression from tests, made passenger bottom nav width/safe-area adaptive, added ellipsis for active tab labels, reduced fixed auth spacers, constrained admin main cards.
- Temporary authenticated verification: created temporary Supabase `layout_*@example.com` admin/passenger users and QA trip/booking data; ran authenticated passenger/admin route smoke on `emulator-5556`; removed the temporary integration test and all QA data afterwards.
- Authenticated verification command: `flutter test integration_test/layout_authenticated_pass_test.dart -d emulator-5556 --dart-define=...` passed; this temporary test did not suppress `RenderFlex overflowed by`.
- Permanent checks after cleanup: `flutter analyze` passed; `flutter test` passed; `flutter test integration_test/app_smoke_test.dart -d emulator-5556` passed without overflow suppression.
- Supabase cleanup verification: temporary `layout_*` users/trips/bookings/events counts returned `0`.

## Следующая Практическая Очередь Реализации
1. Layout/adaptive pass: создать или подключить tablet Android device/AVD и пройти checklist из `Layout / Adaptive QA Audit — 2026-05-04`; после фактических screenshots/runtime проверок внести правки по P1/P2.
2. Optional physical-device smoke: перед внешней передачей повторить короткий запуск/логин/профиль/admin-passenger smoke на физическом Android, если это требуется продуктово.
3. Store/product handoff: финально подтвердить `applicationId`, app label, icon, splash, `version` и владельца release signing key.
4. Android toolchain cleanup: установить Android cmdline-tools и принять licenses, если следующий handoff должен использовать именно `flutter build appbundle --release`; прямой Gradle `bundleRelease` уже прошёл.
5. Дальнейшие изменения фиксировать в README и этом плане только после фактических проверок.

## Шаблон Полного Отчёта По Блоку
1. `Контекст блока`: какой блок завершён, цель блока, статус (`completed/in_progress`).
2. `Что реализовано`: полный список сделанных изменений по требованиям блока.
3. `Где реализовано`: конкретные файлы, экраны, ключевые функции/обработчики.
4. `Что изменилось в UI`: что увидит пассажир, что увидит админ, что изменилось в поведении.
5. `Как проверить (пошагово)`: что нажимать на каждом экране и какой результат ожидать.
6. `Технические проверки`: какие команды запускались (`format/analyze/run/test`) и итог каждой.
7. `Открытые вопросы и следующий шаг`: что осталось, риски, и конкретный следующий практический шаг.

## Как Использовать В Новом Чате
- Пиши: `Открой PROJECT_FINISH_PLAN.md и продолжим`.
- Если задача относится к конкретному этапу, указывай номер или раздел из этого файла.
- После каждого завершённого блока обновлять этот файл, чтобы он оставался актуальным центром проекта.

## Update 2026-04-23 — Block 4 (`cancel_requested + звонок + уведомление админу`)
- Кодовая часть потока выполнена:
- пассажирская кнопка отказа переводит бронь в `cancel_requested`;
- выполняется запись события `booking_cancel_requested` в `notification_events` (идемпотентно);
- после этого открывается звонок менеджеру (номер из `trips.created_by -> users.phone`, fallback на дефолтный номер).
- Добавлена backend-очередь событий уведомлений и RLS-политики:
- `supabase/migrations/20260423_block4_cancel_notification_queue.sql`.
- Добавлена Edge Function-consumer очереди:
- `supabase/functions/dispatch-notification-events/index.ts`.
- Миграция в удалённой БД подтверждена:
- REST-проверка `notification_events` вернула `HTTP 200` (таблица доступна).
- Smoke-проверка потока подтверждена фактическими данными:
- создан тестовый пассажир и тестовая бронь;
- бронь обновлена до `cancel_requested`;
- запись события в `notification_events` создана и прочитана по `booking_id`.
- Следующий шаг:
- деплой `dispatch-notification-events` как Supabase Edge Function и подключение internal webhook/test dispatcher.

## Update 2026-04-24 — Edge Function deploy/check
- Функция `dispatch-notification-events` задеплоена в проект `tgdpwygylwdcagupaubr`.
- Проверка вызова `POST /functions/v1/dispatch-notification-events?dry_run=true` выполнена.
- Текущий ответ функции: `409`, `No admin devices found in user_devices.` — это ожидаемо до регистрации device token у аккаунта администратора.
- Следующий технический шаг:
- добавить запись(и) в `user_devices` для admin-пользователя через выбранный non-Firebase client-token flow;
- задать `ADMIN_PUSH_WEBHOOK_URL` (и при необходимости `ADMIN_PUSH_WEBHOOK_SECRET`) в secrets функции;
- повторить `dry_run`, затем обычный запуск без `dry_run` для подтверждения обработки очереди (`processed_at`).

## Update 2026-04-24 — Block 4 & 6 Finalization

- Block 4 status: `completed`.
- Block 6 status: `completed` (backend queue, triggers, periodic reminders, dispatcher, webhook delivery pipeline).

### Implemented
- Passenger cancellation flow (`cancel_requested + call + admin event`) is implemented in app UI and DB writes.
- Notification queue and event model extended for:
  - `booking_created`
  - `booking_confirmed`
  - `booking_cancel_requested`
  - `booking_removed`
  - `trip_deleted`
  - `trip_reminder_1h`
- Periodic reminder SQL producer `enqueue_trip_reminder_events(...)` implemented and exposed via edge function `enqueue-trip-reminders`.
- Dispatcher function processes both admin and passenger recipients and marks only successfully dispatched events as processed.
- RLS for `user_devices` fixed for authenticated self-service token registration:
  - migration `20260424_block6_user_devices_rls.sql`.
- Internal webhook function added and deployed:
  - `supabase/functions/admin-push-webhook/index.ts`
  - deployed with `--no-verify-jwt`.

### Runtime checks completed (project `tgdpwygylwdcagupaubr`)
- Trigger smoke checks confirmed all target event types are generated.
- `dispatch-notification-events?dry_run=true` confirms dispatchable recipients when devices exist.
- Real run `dispatch-notification-events` confirms successful processing with `processed > 0`.
- Target test events confirmed with non-null `processed_at` after successful dispatch run.

### Current operational notes
- `ADMIN_PUSH_WEBHOOK_URL` and `ADMIN_PUSH_WEBHOOK_SECRET` are configured in project secrets.
- Current webhook target is internal edge function `admin-push-webhook` for controlled delivery testing and queue completion.

## Update 2026-04-24 — Block 5 Finalization

- Block 5 status: `completed`.

### Implemented
- Admin trip list now shows compact colored chips for trip status and available seats.
- Admin trip list has a delete action with confirmation; deletion uses `TripsTable().delete(...)` by exact `trip_id`.
- Admin trip details now show trip status, available seats and booking-status legend (`pending`, `confirmed`, `cancel_requested`).
- Admin trip details has a full-width destructive action for deleting the trip with confirmation.
- Occupied seats show color-coded booking status directly in the seat tile.
- Passenger popup explicitly keeps backdrop dismissal enabled and still supports close button.
- Passenger popup confirmation action is limited to `pending -> confirmed`; `cancel_requested` bookings cannot be confirmed again from the admin UI.
- Booking confirmation/removal and trip deletion rely on existing backend triggers from Block 6 for `booking_confirmed`, `booking_removed`, `trip_deleted` queue events.
- `widget_test.dart` replaced the broken default counter test with an app bootstrap smoke test that initializes Supabase and persisted app state.

### Files changed
- `lib/admin_pages/trips_admin/trips_admin_widget.dart`
- `lib/admin_pages/tripsdetails_admin/tripsdetails_admin_widget.dart`
- `lib/components/passager_detal_admin/passager_detal_admin_widget.dart`
- `test/widget_test.dart`
- `PROJECT_FINISH_PLAN.md`

### Runtime checks completed
- `dart format lib\admin_pages\trips_admin\trips_admin_widget.dart lib\admin_pages\tripsdetails_admin\tripsdetails_admin_widget.dart lib\components\passager_detal_admin\passager_detal_admin_widget.dart`
- `dart format test\widget_test.dart`
- `flutter analyze` on the full project: exits non-zero because the FlutterFlow export still has existing lint/info debt.
- `flutter analyze lib\admin_pages\trips_admin\trips_admin_widget.dart lib\admin_pages\tripsdetails_admin\tripsdetails_admin_widget.dart lib\components\passager_detal_admin\passager_detal_admin_widget.dart`: no compile errors; remaining output is lint/style info and old FlutterFlow warnings.
- `flutter test`: passed.
- `flutter build apk --debug`: passed, APK built at `build\app\outputs\flutter-apk\app-debug.apk`.
- `flutter devices`: Android emulator `emulator-5554` detected.
- `flutter install -d emulator-5554 --use-application-binary build\app\outputs\flutter-apk\app-debug.apk`: passed.
- App launched on emulator via Android launcher intent; `pidof com.mycompany.kgpassnew` returned a live process, `MainActivity` is focused, recent logcat contains no `FATAL EXCEPTION`.

### Next step
- Superseded by Block 7 finalization below.

## Update 2026-04-24 — Block 7 Finalization

- Block 7 status: `completed`.

### Implemented
- Added shared UX reliability helpers for safe network images and reusable empty states:
  - `lib/flutter_flow/ux_reliability.dart`.
- Passenger/admin trip lists no longer crash on empty `car_image`; car images now render a placeholder on null, empty or broken URL.
- Passenger/admin trip lists show empty states when there are no active trips.
- Passenger applications screen shows an empty state when the user has no bookings.
- Profile avatar and admin passenger popup no longer force `avatar_url!`; empty or broken avatars render a person placeholder.
- Profile photo upload no longer clears avatar on cancelled picker; upload has a visible overlay loader and Russian success/error messages.
- Admin passenger popup is constrained for mobile/tablet and scrolls inside the modal instead of using a fixed 450x700 layout.
- Auth forms use responsive max-width containers instead of fixed 370 px widths.
- Password recovery flow now:
  - validates email before request;
  - uses `kgpassnew://kgpassnew.com/updatePassword` as mobile reset redirect and `/updatePassword` on web;
  - validates reset session, minimum password length and repeated password match;
  - signs out after successful password update and returns to login;
  - shows Russian success/error messages.
- Russian copy pass for visible leftovers:
  - `Email required!` -> Russian validation;
  - `Passwords don't match!` -> `Пароли не совпадают.`;
  - `Data` fallback -> `Дата`;
  - `Коментарий пользователя` typo fixed;
  - admin-login helper text made neutral/professional.

### Files changed
- `lib/flutter_flow/ux_reliability.dart`
- `lib/poezdka/trips_user/trips_user_widget.dart`
- `lib/admin_pages/trips_admin/trips_admin_widget.dart`
- `lib/poezdka/applications/applications_widget.dart`
- `lib/pages/profil/profil_widget.dart`
- `lib/components/passager_detal_admin/passager_detal_admin_widget.dart`
- `lib/auth/auth_manager.dart`
- `lib/auth/supabase_auth/supabase_auth_manager.dart`
- `lib/singlogin/recovery/recovery_widget.dart`
- `lib/singlogin/update_password/update_password_widget.dart`
- `lib/singlogin/creat_account/creat_account_widget.dart`
- `lib/singlogin/login_new/login_new_widget.dart`
- `PROJECT_FINISH_PLAN.md`

### Runtime checks completed
- `dart format` on all changed Dart files: passed.
- Targeted `flutter analyze` on changed Dart files: no compile errors; remaining warnings are old FlutterFlow null-assertion/null-check warnings in login/registration.
- `flutter test`: passed.
- `flutter build apk --debug`: passed, APK built at `build\app\outputs\flutter-apk\app-debug.apk`.
- `flutter devices`: Android emulator `emulator-5554` detected.
- `flutter install -d emulator-5554 --use-application-binary build\app\outputs\flutter-apk\app-debug.apk`: passed.
- App launched on emulator via Android launcher intent; `pidof com.mycompany.kgpassnew` returned a live process, `MainActivity` is focused, recent logcat contains no `FATAL EXCEPTION`.
- Deep-link route smoke launched with `kgpassnew://kgpassnew.com/updatePassword`; `MainActivity` stayed focused and recent logcat contains no `FATAL EXCEPTION`.

### Next step
- Финал: расширить smoke/integration tests и почистить критичные analyzer warnings.

## Update 2026-04-24 - Final Block Kickoff & Verification

- Historical final status at that time: `in_progress` (critical analyzer debt closed; remaining lint/info backlog was non-blocking style debt). Superseded 2026-05-04: final Android emulator handoff status is `completed`.

### Implemented
- Removed all `unnecessary_import` diagnostics (19 -> 0) across app/navigation/auth screens.
- Kept critical analyzer set at zero: `use_build_context_synchronously`, `unused_import`, `unnecessary_non_null_assertion`.
- Expanded integration smoke coverage (`integration_test/app_smoke_test.dart`) with:
  - logged-out user redirected from `MainAdmin` route to `Splash`.
  - first-launch branch renders `Welcome`.

### Runtime checks completed
- `flutter analyze`: `error=0`, `warning=0`, `info=1000`.
- `flutter test`: passed.
- `flutter test integration_test/app_smoke_test.dart -d emulator-5554`: passed (4 tests).
- `flutter install -d emulator-5554 --use-application-binary build/app/outputs/flutter-apk/app-debug.apk`: passed.
- `adb` runtime smoke: app process exists (`pidof com.mycompany.kgpassnew` non-empty) and focused activity is `com.mycompany.kgpassnew/.MainActivity`.

### Next step
- Optional: reduce non-blocking style/info lint backlog (`prefer_const_*`, `sized_box_for_whitespace`) in batches.

## Update 2026-04-29 - F2 Manual E2E Smoke

- F2 status: `completed` for the core passenger/admin smoke on `emulator-5556` plus real Supabase data operations.

### Completed
- Reviewed F2 acceptance criteria in this plan and README.
- Confirmed Android emulator availability: `emulator-5556` (Pixel 6 Pro API 33). `emulator-5554` was not used after user instruction.
- Ran pre-smoke technical checks:
- `flutter analyze`: passed, no issues found.
- `flutter test`: passed, 2 tests.
- `flutter test integration_test/app_smoke_test.dart -d emulator-5556`: passed, 4 tests; debug APK built, installed and exercised logged-out/welcome/public auth routes.
- `flutter build apk --debug`: passed, APK at `build\app\outputs\flutter-apk\app-debug.apk`.
- Installed and launched the debug APK manually via SDK adb:
- `adb install -r build\app\outputs\flutter-apk\app-debug.apk`: passed.
- Launcher intent for `com.mycompany.kgpassnew`: passed.
- Captured launch screenshot: `f2_pixel6pro_launch.png`.
- Checked recent filtered logcat after launch: no `AndroidRuntime:E`, `Flutter:E`, or `KGPassNew:E` output was returned; no `FATAL EXCEPTION` observed in the checked slice.

### Passenger/Admin Supabase Smoke
- Created disposable passenger account and `users.role = passenger` row through the same public auth/REST path used by the app.
- Created disposable admin account and `users.role = admin` row through the same public auth/REST path used by the app.
- Admin trip creation passed: `trips.created_by` equals the admin user id; `trips_view` returned `status=active`, `total_seats=4`, `available_seats=4`.
- Passenger booking passed: booking created with `status=pending`, selected seat and passenger comment.
- Duplicate booking for the same `trip_id + user_id` was blocked by the DB with `409`.
- Passenger applications readback passed: booking visible with `status=pending` and selected seat.
- Cancel request passed: booking status updated to `cancel_requested`.
- Admin popup-equivalent data checks passed: passenger `user_comment` stayed separate from `admin_comment`.
- Admin comment save passed: `admin_comment` persisted.
- Admin confirm passed: pending booking updated to `confirmed` with admin comment.
- Admin hard delete booking passed: booking removed, readback count `0`.
- Admin hard delete trip passed: trip removed and related bookings cascade removed, readback counts `0`.

### Next step
- Continue with F7 final human QA; F5 password-recovery deep-link runtime was later completed on 2026-05-02.

## Update 2026-04-29 — F3/F4 completion
- F3 status: `completed` for Supabase queue + internal webhook/test delivery, without Firebase/FCM.
- Supabase service-role REST access was verified from local `.env` without printing secrets.
- `user_devices` returned Android test-device rows.
- `notification_events` returned pending rows.
- `dispatch-notification-events?dry_run=true` returned `pending: 28`, `would_process: 7`, `skipped_no_recipients: 21`.
- Real `dispatch-notification-events` returned `processed: 7`; follow-up REST read showed those rows got `processed_at=2026-04-29T08:59:41.956+00:00`.
- The remaining pending passenger events have no matching `user_devices` rows for their `recipient_user_id`, so they correctly remain pending.
- F4 status at that time: `completed` for release-ready config; signed release build was blocked only by local keystore/key.properties. Superseded 2026-05-04: local signing is configured and signed release APK/AAB artifacts are built.
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build apk --debug` passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter build apk --release` correctly failed fast with: `Release signing is not configured. Create android/key.properties with storeFile, storePassword, keyAlias, and keyPassword.`
- Root `.gitignore` now excludes `.env` and `.env.*` while allowing `.env.example`.
- Android release no longer falls back to debug signing and now enables minification/resource shrinking.
- Android manifest now uses `@string/app_name`, disables backup, and disables cleartext traffic.

## Update 2026-04-29 — Project Analysis Refresh And Remaining Steps

- Статус анализа: `completed`.
- Историческая оценка на 2026-04-29 была около `90%` MVP/предрелиза. Superseded 2026-05-04: Android emulator release-candidate готов.
- Основная логика приложения, backend, роли, passenger/admin flows, notification queue, tests, debug build и документация уже реализованы.
- Исторически оставшиеся работы относились к финальной runtime-проверке, human QA, release signing и production push. Superseded: F5/F7/release signing/Pushy закрыты фактами.

### Подтверждено В Коде И Конфигурации
- Flutter-приложение запускается через `AppBootstrap`, Supabase initialization и persisted state initialization вынесены в стартовый flow.
- Есть startup loading и startup failure screen с понятным текстом для пользователя.
- `AppStateNotifier` централизованно грузит `users.role` и участвует в role-based routing.
- Route guards реализованы для `public`, `authenticated`, `passenger`, `admin`.
- Первый запуск ведёт на `Welcome`; флаг `hasSeenWelcome` хранится в persisted state.
- Passenger flow реализует список поездок, детали, выбор места, pending booking, duplicate protection, мои заявки и cancel request через звонок.
- Admin flow реализует создание рейса, просмотр поездок, детали рейса, popup пассажира, `admin_comment`, подтверждение брони, hard delete брони и hard delete рейса.
- Supabase migrations покрывают `bookings.status`, `bookings.admin_comment`, duplicate booking unique index, cascade delete, `trips_view.available_seats`, `user_devices`, notification events, triggers and reminder RPC.
- Edge Functions покрывают dispatch notification queue, enqueue trip reminders and internal webhook/test delivery.
- Android release config подготовлен: release signing не fallback-ится на debug signing, minify/shrink enabled, backup disabled, cleartext disabled.
- Android deep link declaration есть в manifest для `kgpassnew://kgpassnew.com/...`.
- Password reset UI реализует basic validation: нет reset-сессии, длина пароля, повтор пароля, update password, sign out, возврат на login.
- Тестовая база покрыта `test/widget_test.dart` и `integration_test/app_smoke_test.dart`.

### Новое Из Этого Анализа
- План был в целом актуален, но найдено и исправлено противоречие: F2 в детальной секции был `todo`, хотя по фактам уже `completed`.
- Исторический факт на 2026-04-29: F3 тогда был завершён только для Supabase queue + internal webhook/test delivery; production push provider/client-token registration ещё не был реализован. Superseded 2026-05-02: Pushy provider/client-token flow implemented and live delivery confirmed.
- Исторический факт на 2026-04-29: F4 тогда был завершён для release-ready configuration, но signed release build ждал локальный `android/key.properties` и keystore. Superseded 2026-05-04: локальный signing setup создан, signed release APK/AAB built.
- Уточнено, что F5 не требует новой базовой UI-реализации: код и manifest уже есть, нужен именно runtime check с Android deep link и Supabase dashboard/email redirect.
- Уточнено, что F7 не заменяется техническим smoke: нужен отдельный human QA pass и список правок/подтверждение отсутствия критичных правок.
- Зафиксирован риск финального package/app identity: `applicationId = com.mycompany.kgpassnew`, app label `KG - passNew`; перед релизом нужно подтвердить, что это финальные значения.
- Зафиксирован риск секретов: `.env` есть локально и игнорируется git, его нельзя коммитить; service-role keys, keystores and passwords не хранить в репозитории.

## Update 2026-05-04 — Final Emulator QA And Signed Release

- Final status: `completed` for Android emulator pre-release handoff.
- Device: `emulator-5554`, Android 13 API 33, 1080x2400 @ 420 dpi.
- Technical checks passed: `flutter analyze`, `flutter test`, `flutter test integration_test/app_smoke_test.dart`, `flutter build apk --debug`, `flutter build apk --release`.
- Local signing setup created: keystore outside the repo, `android/key.properties` local only; secrets were not printed.
- Release artifacts:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`
- Verification passed: `apksigner verify --verbose --print-certs` for APK, `jarsigner -verify -verbose -certs` for AAB.
- Runtime release smoke passed: signed APK installed on `emulator-5554`, app launched, Welcome/auth screens rendered, notification permission handled, logcat for app process contained no `FATAL EXCEPTION`, `AndroidRuntime`, or `E/flutter`.
- Admin QA passed with temporary Supabase QA users/data: admin login, trips list, trip details, passenger popup, `admin_comment` save, `pending -> confirmed`, booking hard delete, trip hard delete. REST readback confirmed status/comment/delete effects.
- Passenger QA passed: passenger login, Home, bottom navigation, `Мои поездки` empty state, Profile with empty avatar placeholder.
- Cleanup completed: temporary QA trip/booking/users/device rows/events/auth users were removed.
- Known environment note: `flutter build appbundle --release` produced AAB but returned a Flutter post-check error about stripping native debug symbols; direct `android/gradlew.bat bundleRelease` completed successfully. `flutter doctor` reports missing Android cmdline-tools/license status.
- No critical UI/text/runtime fixes were found in this final emulator pass. Superseded 2026-05-05: отдельный пользовательский QA из `Screenshots-bag` нашёл обязательный UX/adaptive bugfix pass.

### Оставшиеся Шаги По Приоритету
Updated 2026-05-06: `QA-UX-2026-05-05` закрыт по коду; перед release-handoff шагами нужен финальный smoke актуальной сборки.

1. F7 final human QA: `completed_by_code` 2026-05-06 по списку `Screenshots-bag`; короткий smoke 2026-05-04 оставлен как исторический факт, нужен повтор на актуальной сборке.
2. Android signed release: `completed` 2026-05-04; APK/AAB собраны локально, APK установлен и проверен на эмуляторе.
3. Production push decision: `completed` 2026-05-02 через Pushy; physical device repeat остаётся опциональным release-handoff smoke.
4. Final verification and closeout: `completed` 2026-05-04; README и план обновлены.

### Definition Of Done Update
- Updated 2026-05-06: технические checks остаются зелёными; `QA-UX-2026-05-05` закрыт по коду, перед Android emulator pre-release handoff нужен повторный smoke актуальной сборки.

## Update 2026-05-05 — Screenshots-bag QA Reopen

- Статус внешней передачи переоткрыт: новый пользовательский QA из `Screenshots-bag/Баги.docx` и скриншотов `3.jpg`-`23.jpg` нашёл обязательный UX/adaptive bugfix pass.
- Предыдущий вывод 2026-05-04 "критичных UI/текстовых правок не найдено" теперь считается ограниченным коротким emulator smoke и не закрывает новый список замечаний.
- В верхнюю часть плана добавлен блок `QA-UX-2026-05-05` со структурой `P0/P1`, зонами кода, критериями проверки и ссылками на документацию Flutter, `image_picker` и `url_launcher`.
- Главное правило для следующей реализации: чинить реальные причины в constraints/state/query/layout, не маскировать проблемы искусственными задержками, дополнительными загрузочными экранами или самодельными обходами.

## Update 2026-05-05 — QA-UX P0.1 First Fix

- Статус `QA-UX-2026-05-05`: `completed_by_code`.
- `P0.1` кодово закрыт для экранов и компонентов с loader-зависаниями из скриншотов `13.jpg`, `14.jpg`, `15.jpg`, `19.jpg`.
- Основание по документации: официальный `FutureBuilder` API требует получать `future` до `build()` (`initState`/`didUpdateWidget`/`didChangeDependencies`) и обрабатывать `snapshot.hasError`, когда future завершился ошибкой.
- Изменения:
- `lib/flutter_flow/ux_reliability.dart`: добавлен общий `KgErrorState` с понятным текстом и кнопкой повтора.
- `lib/poezdka/trips_user/trips_user_widget.dart`: список активных поездок теперь использует cached future, error state, timeout/retry/cache fallback.
- `lib/poezdka/applications/applications_widget.dart`: список заявок и nested trip lookup используют cached futures; после запроса отмены обновляется только нужный future.
- `lib/pages/profil/profil_widget.dart`: профиль использует cached future; после загрузки фото и сохранения профиля данные перечитываются без бесконечного loader.
- `lib/poezdka/tripsdetails/tripsdetails_widget.dart`: схема мест использует cached future; при ошибке показывает error state.
- `lib/admin_pages/trips_admin/trips_admin_widget.dart`: админский список рейсов использует cached future и timeout/retry/cache fallback; после удаления рейса список перечитывается.
- `lib/admin_pages/tripsdetails_admin/tripsdetails_admin_widget.dart`: админская схема мест использует cached future и timeout/retry; после закрытия popup пассажира схема перечитывается.
- `lib/components/passager_detal_admin/passager_detal_admin_widget.dart`: данные пассажира в popup используют cached future и error state.
- Проверки: `dart format` прошёл; targeted `flutter analyze` по изменённым файлам прошёл без issues; `flutter test` прошёл; full `flutter analyze` прошёл без issues; `flutter build apk --debug` собрал `build\app\outputs\flutter-apk\app-debug.apk`.
- Дополнение 2026-05-06: debug APK пересобирался, устанавливался и запускался на `emulator-5554` и `emulator-5556`; отдельные исправления проверялись targeted `flutter analyze`.
- Что остаётся: финальный сквозной smoke актуальной сборки перед external handoff.
- Следующий шаг: пройти финальный passenger/admin smoke и зафиксировать результат.

## Update 2026-05-05 — QA-UX P0.2 Adaptive/Scroll Fix

- Статус `P0.2`: кодовая правка выполнена.
- Основание по документации Flutter: layout правился через constraints, `SafeArea` для системных областей и штатные scrollable widgets (`SingleChildScrollView`/`ListView`) для контента, который не помещается на маленькой высоте или в landscape.
- Изменения:
- `lib/pages/main/main_widget.dart`: главный пассажирский экран теперь в `SafeArea`; карточки лежат в `SingleChildScrollView` с нижним запасом под floating bar; добавлен `ConstrainedBox(maxWidth: 760)`; пара квадратных карточек больше не требует фиксированной суммарной ширины.
- `lib/admin_pages/main_admin/main_admin_widget.dart`: админская главная теперь в `SafeArea`, `SingleChildScrollView` и `ConstrainedBox(maxWidth: 420)`.
- `lib/poezdka/trips_user/trips_user_widget.dart`, `lib/admin_pages/trips_admin/trips_admin_widget.dart`: списки рейсов получили `SafeArea` и безопасный верхний отступ вместо фиксированного 50 px.
- `lib/poezdka/tripsdetails/tripsdetails_widget.dart`, `lib/admin_pages/tripsdetails_admin/tripsdetails_admin_widget.dart`: детали рейса и схема мест получили `SafeArea` и безопасный верхний отступ вместо фиксированного 50/70 px.
- `lib/poezdka/applications/applications_widget.dart`, `lib/pages/profil/profil_widget.dart`: вкладки с нижней навигацией теперь используют корневой `SafeArea` и безопасный верхний отступ.
- `lib/components/passager_detal_admin/passager_detal_admin_widget.dart`: popup пассажира теперь сам в `SafeArea`; высота считается от доступного viewport с учётом `viewInsets`; радиус уменьшается на низкой высоте, чтобы окно не резало контент.
- `lib/admin_pages/tripsdetails_admin/tripsdetails_admin_widget.dart`: bottom sheet пассажира открывается с `useSafeArea: true`.
- Проверки: `dart format` прошёл; targeted `flutter analyze` по 9 изменённым файлам прошёл без issues; full `flutter analyze` прошёл без issues; `flutter test` прошёл; `flutter build apk --debug` собрал `build\app\outputs\flutter-apk\app-debug.apk`.
- Дополнение 2026-05-06: эмуляторы `emulator-5554` и `emulator-5556` доступны и использовались для установки/запуска актуальной debug-сборки.
- Следующий шаг: финальный passenger/admin smoke актуальной сборки.

## Update 2026-05-06 — Trip Details Date Format

- Исправлен формат даты маршрута в деталях рейса passenger/admin: теперь показывается `день месяц год, время`.
- Passenger/admin departure date используют `d MMMM y` + время; admin arrival date использует `d MMMM y, HH:mm`.
- Проверки: `dart format` и targeted `flutter analyze` по `tripsdetails_widget.dart` и `tripsdetails_admin_widget.dart` прошли без issues.
- Debug APK пересобран, установлен и запущен на `emulator-5554` и `emulator-5556`.
