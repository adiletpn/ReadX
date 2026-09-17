/// The only place base URLs are written down. Nothing else in the app builds
/// an absolute URL by hand — media paths go through `mediaUrl()`.
library;

/// Все REST-запросы.
const kApiBase = 'https://readx.kz/api';

/// Префикс для относительных путей `/uploads/...`, которые отдаёт API.
const kMediaBase = 'https://readx.kz';
