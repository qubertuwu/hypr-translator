// Tech and Developer Slang Glossary & Post-Processor
.pragma library

// Exact term dictionary (lowercase English -> Russian IT explanation/translation)
var dictEnToRu = {
    // Core Concepts & Idioms
    "boilerplate": "шаблонный код (бойлерплейт)",
    "boilerplate code": "шаблонный код (бойлерплейт)",
    "deprecated": "устарело / не рекомендуется (депрекейтед)",
    "deprecate": "объявить устаревшим",
    "out of the box": "из коробки (работает без доп. настройки)",
    "under the hood": "под капотом (внутреннее устройство)",
    "side effect": "побочный эффект (сайд-эффект)",
    "side effects": "побочные эффекты (сайд-эффекты)",
    "thread pool": "пул потоков",
    "thread-safe": "потокобезопасный",
    "race condition": "состояние гонки (race condition)",
    "deadlock": "взаимная блокировка (дедлок)",
    "livelock": "активная взаимная блокировка (лайвлок)",
    "garbage collector": "сборщик мусора (GC)",
    "garbage collection": "сборка мусора (GC)",
    "memory leak": "утечка памяти",
    "stack overflow": "переполнение стека",
    "stack trace": "стек вызовов (стектрейс)",
    "null pointer": "нулевой указатель (null / nullptr)",
    "null pointer exception": "исключение нулевого указателя (NPE)",
    "segfault": "ошибка сегментации (сегфолт)",
    "segmentation fault": "ошибка сегментации (сегфолт)",
    "buffer overflow": "переполнение буфера",

    // Git & Workflows
    "pull request": "Pull Request (PR — запрос на слияние)",
    "pr": "Pull Request (PR — запрос на слияние)",
    "merge request": "Merge Request (MR — запрос на слияние)",
    "mr": "Merge Request (MR — запрос на слияние)",
    "commit": "коммит (зафиксировать изменения)",
    "branch": "ветка (бранч)",
    "merge": "слияние (мердж веток)",
    "rebase": "перебазирование (ребейз)",
    "cherry-pick": "черри-пик (выборочный перенос коммита)",
    "stash": "стэш (временный тайник изменений)",
    "fork": "форк (ответвление репозитория)",
    "upstream": "апстрим (вышестоящий репозиторий)",
    "origin": "ориджин (удаленный основной репозиторий)",
    "head": "HEAD (указатель на текущий коммит/ветку)",
    "diff": "дифф (разница между версиями кода)",

    // Chat & Slang
    "lgtm": "LGTM (Looks Good To Me — одобряю, выглядит отлично)",
    "wip": "WIP (Work In Progress — в процессе разработки)",
    "afaik": "AFAIK (насколько мне известно)",
    "iirc": "IIRC (если правильно помню)",
    "tbd": "TBD (будет определено позже)",
    "imo": "IMO (по моему мнению)",
    "imho": "IMHO (по моему скромному мнению)",
    "rfc": "RFC (Request For Comments — запрос на обсуждение)",
    "poc": "PoC (Proof of Concept — доказательство концепции)",
    "mvp": "MVP (Minimum Viable Product — минимальный рабочий продукт)",
    "fyi": "FYI (к вашему сведению)",

    // Architecture & Backend
    "ci/cd": "CI/CD (непрерывная интеграция и доставка)",
    "pipeline": "пайплайн / конвейер сборки",
    "middleware": "мидлвар / промежуточный слой обработки",
    "endpoint": "эндпоинт (конечная точка API)",
    "payload": "полезная нагрузка (тело запроса/данные)",
    "handler": "обработчик",
    "event handler": "обработчик событий",
    "mock": "мок / тестовая заглушка (имитация)",
    "mocks": "моки / тестовые заглушки",
    "stub": "стаб / заглушка",
    "scope": "область видимости (скоуп)",
    "closure": "замыкание",
    "callback": "колбэк (функция обратного вызова)",
    "runtime": "время выполнения (рантайм)",
    "state machine": "конечный автомат (стейт-машина)",
    "tree shaking": "тришейкинг (удаление неиспользуемого кода)",
    "bundle": "бандл (собранный пакет кода)",
    "build": "сборка (билд)",
    "deploy": "развертывание (деплой)",
    "deployment": "развертывание (деплоймент)",
    "hotfix": "срочный патч / хотфикс",
    "patch": "патч (исправление/заплатка)",
    "daemon": "демон (фоновый сервис)",
    "sandbox": "песочница (изолированное окружение)",
    "linter": "линтер (статический анализатор кода)",
    "formatter": "форматтер кода",
    "staging": "стейджинг (предрелизный сервер)",
    "production": "прод / продакшен (боевой рабочий сервер)",
    "prod": "прод (боевое окружение)",
    "issue": "задача / проблема (ишью)",
    "issues": "задачи / проблемы (ишью)",
    "dependency": "зависимость",
    "dependencies": "зависимости",
    "refactoring": "рефакторинг (улучшение структуры кода)",
    "overhead": "накладные расходы (избыточная нагрузка)",
    "throughput": "пропускная способность",
    "latency": "задержка (латентность / пинг)",
    "rate limit": "ограничение частоты запросов",
    "throttling": "троттлинг (ограничение частоты)",
    "debouncing": "дебаунс (устранение дребезга / задержка вызова)",
    "lazy loading": "ленивая загрузка (по требованию)",
    "eager loading": "жадная загрузка (немедленная)",
    "immutable": "неизменяемый (иммутабельный)",
    "mutable": "изменяемый (мутабельный)",
    "idempotent": "идемпотентный (повторный вызов дает тот же результат)",
    "spaghetti code": "спагетти-код (запутанный код)",
    "technical debt": "технический долг (техдолг)",
    "tech debt": "техдолг",
    "hardcode": "хардкод (жестко прописанные данные)",
    "hardcoded": "захардкожено (прописано жестко в коде)",
    "sanity check": "базовая проверка здравого смысла",
    "smoke test": "дымовой тест (первичная экспресс-проверка)",
    "edge case": "граничный случай",
    "corner case": "краевой случай (редкая комбинация условий)",
    "wildcard": "маска подстановки (вайлдкард)",
    "scaffolding": "скаффолдинг (генерация каркаса)",
    "parsing": "парсинг (синтаксический анализ)",
    "parse": "распарсить",
    "pipe": "пайп (канал передачи данных)",
    "concurrency": "конкурентность / многозадачность",
    "multithreading": "многопоточность",
    "thread": "поток выполнения",
    "threads": "потоки выполнения",
    "mutex": "мьютекс (взаимное исключение)",
    "semaphore": "семафор",
    "atomic": "атомарный",
    "marshalling": "маршалинг (упаковка структур в байты)",
    "serialization": "сериализация",
    "deserialization": "десериализация",
    "wrapper": "обёртка (враппер)",
    "polyfill": "полифил (модуль совместимости)",
    "transpiler": "транспилер",
    "transpile": "транспилировать",
    "crutch": "костыль (временный костыль в коде)",
    "hack": "хак / обходной путь",
    "escape": "экранировать (спецсимвол)",
    "escaping": "экранирование",
    "render": "отрисовать / зарендерить",
    "rendering": "рендеринг / отрисовка",
    "hook": "хук (перехватчик / функция React)",
    "hooks": "хуки",
    "duck typing": "утиная типизация",
    "rubber ducking": "метод утёнка",
    "framework": "фреймворк",
    "library": "библиотека (либа)",
    "sdk": "SDK (инструменты разработки)",
    "cli": "CLI (консольный интерфейс)",
    "gui": "GUI (графический интерфейс)",
    "tui": "TUI (терминальный интерфейс)",
    "lookup": "поиск в словаре/таблице (лукап)",
    "handshake": "рукопожатие (согласование соединения)",
    "query": "запрос",
    "mutation": "мутация (изменение состояния)",
    "singleton": "одиночка (паттерн синглтон)",
    "polymorphism": "полиморфизм",
    "inheritance": "наследование",
    "encapsulation": "инкапсуляция",
    "abstraction": "абстракция"
};

// Reverse dictionary (Russian IT terms -> English equivalents)
var dictRuToEn = {
    "пул потоков": "thread pool",
    "потокобезопасный": "thread-safe",
    "состояние гонки": "race condition",
    "дедлок": "deadlock",
    "взаимная блокировка": "deadlock",
    "сборщик мусора": "garbage collector",
    "сборка мусора": "garbage collection",
    "утечка памяти": "memory leak",
    "стектрейс": "stack trace",
    "стек вызовов": "stack trace",
    "переполнение стека": "stack overflow",
    "переполнение буфера": "buffer overflow",
    "сегфолт": "segfault / segmentation fault",
    "ошибка сегментации": "segmentation fault",
    "шаблонный код": "boilerplate",
    "бойлерплейт": "boilerplate",
    "из коробки": "out of the box",
    "под капотом": "under the hood",
    "сайд-эффект": "side effect",
    "побочный эффект": "side effect",
    "мидлвар": "middleware",
    "эндпоинт": "endpoint",
    "обработчик": "handler",
    "заглушка": "stub / mock",
    "мок": "mock",
    "рантайм": "runtime",
    "время выполнения": "runtime",
    "скоуп": "scope",
    "область видимости": "scope",
    "замыкание": "closure",
    "колбэк": "callback",
    "ветка": "branch",
    "коммит": "commit",
    "слияние": "merge",
    "ребейз": "rebase",
    "деплой": "deploy",
    "развертывание": "deployment",
    "билд": "build",
    "сборка": "build",
    "хотфикс": "hotfix",
    "патч": "patch",
    "ишью": "issue",
    "техдолг": "tech debt / technical debt",
    "хардкод": "hardcode",
    "костыль": "crutch / hack / workaround",
    "экранирование": "escaping",
    "экранировать": "escape",
    "рендерить": "render",
    "отрисовка": "rendering",
    "хук": "hook",
    "хуки": "hooks",
    "фреймворк": "framework",
    "либа": "library",
    "рефакторинг": "refactoring",
    "накладные расходы": "overhead",
    "пайплайн": "pipeline",
    "устарело": "deprecated"
};

// Context-aware regex rules to fix Google's worst literal mistakes in Russian sentences
var sentenceFixesRu = [
    // Deprecated fixes
    { re: /\bосуждаем(ый|ая|ое|ые|ого|ому|ым|ых|ую|ом)\b/gi, sub: "устаревш$1 (deprecated)" },
    { re: /\bосуждается\b/gi, sub: "устарело / не рекомендуется" },

    // Thread pool fixes
    { re: /\bбассейн(а|у|ом|е)?\s+(потоков|нитей)\b/gi, sub: "пул$1 потоков" },
    { re: /\bпул(а|у|ом|е)?\s+нитей\b/gi, sub: "пул$1 потоков" },
    { re: /\bнитей\s+выполнения\b/gi, sub: "потоков выполнения" },
    { re: /\b(фонов(ая|ую|ой|ые|ых))\s+нить\b/gi, sub: "фоновый поток" },

    // Race condition & deadlock
    { re: /\bсостояни(е|я|ю|ем|и)\s+расы\b/gi, sub: "состояни$1 гонки (race condition)" },
    { re: /\bуслови(е|я|ю|ем|и)\s+гонки\b/gi, sub: "состояни$1 гонки" },

    // Boilerplate
    { re: /\bпластин(а|ы|е|у|ой)?\s+котла\b/gi, sub: "шаблонный код (boilerplate)" },
    { re: /\bкод\s+котла\b/gi, sub: "шаблонный код (boilerplate)" },

    // Breakpoint
    { re: /\bточк(а|и|е|у|ой|ами|ах)\s+разрыва\b/gi, sub: "точк$1 останова (breakpoint)" },

    // Hook / Handler
    { re: /\bручк(а|и|е|у|ой)\s+(запрос(а|ов)|событи(й|я))\b/gi, sub: "обработчик $2" },
    { re: /\bкрюч(ок|ка|ку|ком|ке|ки|ков)\s+React\b/gi, sub: "хук$1 React" },
    { re: /\bGit\s+крюч(ок|ка|ку|ком|ке|ки|ков)\b/gi, sub: "Git-хук$1" },

    // Under the hood / Out of the box
    { re: /\bиз\s+коробки\b/gi, sub: "из коробки (out of the box)" },

    // Pull request / Merge request
    { re: /\bзапрос(а|у|ом|е)?\s+на\s+вытягивание\b/gi, sub: "Pull Request" },

    // Garbage collector
    { re: /\bколлектор(а|у|ом|е)?\s+мусора\b/gi, sub: "сборщик$1 мусора (GC)" },

    // Overhead / Payload
    { re: /\bнакладные\s+расходы\b/gi, sub: "накладные расходы (overhead)" },
    { re: /\bполезн(ая|ой|ую|ости)\s+нагрузк(а|и|у|ой)\b/gi, sub: "полезная нагрузка (payload)" },

    // Mock
    { re: /\b(насмешк(а|и|у|ой)|издевательств(о|а))\b(?=.*тест)/gi, sub: "мок-объект" }
];

// Main function to enhance translation
function enhance(sourceText, translatedText, sourceLang, targetLang) {
    if (!sourceText || !translatedText) return translatedText;

    var sTrim = sourceText.trim().toLowerCase();

    // 1. Direct Term Match (EN -> RU)
    if (targetLang === "ru") {
        if (dictEnToRu.hasOwnProperty(sTrim)) {
            return dictEnToRu[sTrim];
        }

        // Apply sentence-level context improvements
        var result = translatedText;
        for (var i = 0; i < sentenceFixesRu.length; i++) {
            result = result.replace(sentenceFixesRu[i].re, sentenceFixesRu[i].sub);
        }
        return result;
    }

    // 2. Direct Term Match (RU -> EN)
    if (targetLang === "en") {
        if (dictRuToEn.hasOwnProperty(sTrim)) {
            return dictRuToEn[sTrim];
        }
    }

    return translatedText;
}
