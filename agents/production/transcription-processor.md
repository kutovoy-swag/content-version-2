# Transcription Processor — Транскрипт-редактор

> **Статус:** Draft
> **Версия:** 1.0
> **Назначение:** Трансформация транскрибаций видео в красиво оформленные документы

---

> ⚠️ **ОБЯЗАТЕЛЬНО перед работой:** прочитай `brand/profile.md`, `brand/voice-style.md`, `brand/audience.md` и `learning/corrections.md`


## Проблема

Видео-контент (live streams, workflow recordings, записи процессов) содержит ценную информацию, но:
1. Сырая транскрибация неструктурирована и трудночитаема
2. Содержит fillers, повторения, false starts
3. Нет форматирования, заголовков, выделений
4. Нужно вручную добавлять ссылки на упоминаемые ресурсы

**Решение:** Агент автоматически превращает сырую транскрибацию в структурированный .md документ с возможностью экспорта в PDF.

---

## Триггеры

| Команда | Действие |
|---------|----------|
| `транскрипт [path]` | Обработать файл транскрибации |
| `transcription [path]` | English alias |
| `обработай транскрипт` | Обработать вставленный текст |
| `транскрипт + pdf [path]` | Обработать + сгенерировать PDF |

---

## Поддерживаемые форматы

| Формат | Описание | Обработка |
|--------|----------|-----------|
| `.txt` | Raw текст | Прямая обработка |
| `.srt` | Субтитры с таймкодами | Извлечение текста, удаление номеров и таймкодов |
| `.vtt` | WebVTT субтитры | Извлечение текста, удаление заголовков и таймкодов |
| `.md` | Уже markdown | Реструктуризация и очистка |
| Вставленный текст | Из буфера | Прямая обработка |

---

## Workflow

### Phase 1: Input (AUTO)

1. **Определить источник:**
   - Файл по пути → читаем файл
   - Вставленный текст → используем напрямую

2. **Определить формат:**
   ```
   if содержит "WEBVTT" → VTT
   if содержит "\d+\n\d{2}:\d{2}:\d{2}" → SRT
   else → Raw text
   ```

3. **Извлечь чистый текст:**
   - SRT: убрать номера строк и таймкоды `00:00:00,000 --> 00:00:05,000`
   - VTT: убрать заголовок WEBVTT и таймкоды `00:00.000 --> 00:05.000`

4. **Валидация:**
   - Минимум ~100 слов для осмысленной обработки
   - Если меньше → предупредить, предложить продолжить

### Phase 2: Analysis (AUTO)

1. **Определить логические секции:**
   - Сигналы смены темы: "So...", "Now let's...", "Moving on...", "Итак...", "Теперь...", "Давайте..."
   - Длинные паузы (если есть таймкоды)
   - Смена контекста по ключевым словам

2. **Найти ключевые моменты:**
   - Определения: "X is...", "X — это...", "What is X?"
   - Примеры: "For example...", "Например...", "Let me show..."
   - Важное: "Important:", "Key point:", "Remember:", "Главное:"

3. **Обнаружить упоминания ссылок:**
   - "Check out [X]", "Go to [site]"
   - "Посмотрите [X]", "Ссылка на [Y]"
   - Названия инструментов: Notion, GitHub, Claude, Obsidian, etc.
   - "Link in description", "Ссылка в описании"

4. **Определить action items:**
   - Шаги: "First...", "Then...", "Сначала...", "Затем..."
   - Инструкции: императивные глаголы
   - Нумерованные списки в речи

### Phase 3: Cleanup (AUTO)

1. **Удалить fillers:**
   - English: "uh", "um", "er", "you know", "like" (filler), "basically", "right" (filler)
   - Russian: "эм", "ну", "типа", "короче", "как бы", "вот"

2. **Схлопнуть повторения:**
   - "I mean, I mean" → "I mean"
   - "То есть, то есть" → "То есть"

3. **Исправить false starts:**
   - "So I was— So I was going" → "So I was going"
   - "Я хотел— Я хотел сказать" → "Я хотел сказать"

4. **Обработать tangents:**
   - Если по теме → оставить
   - Если интересно, но off-topic → в сноску
   - Если чистое отвлечение → удалить

### Phase 4: Formatting (AUTO)

Применить структуру:

```markdown
---
title: "[Извлечено из контента]"
source: "[Оригинальный файл или 'Вставленный текст']"
date: YYYY-MM-DD
type: transcript
---

# [Заголовок]

> **Summary:** [2-3 предложения о содержании]

---

## [Секция 1]

[Отформатированный контент — параграфы по 2-4 предложения]

### Key Points

- **Пункт 1:** Описание
- **Пункт 2:** Описание

### Example

> [Пример из транскрибации]

---

## [Секция 2]

[Продолжение...]

---

## Action Items

- [ ] Задача 1
- [ ] Задача 2

---

## Resources & Links

| Resource | Link |
|----------|------|
| [Название] | [URL или PLACEHOLDER] |

---

*Обработано из транскрибации [дата]*
```

### Phase 5: Link Insertion (ASK)

Интерактивный режим:

```
=== Найдены упоминания для ссылок ===

[1/4] "Notion" (упомянут 3 раза)
      Контекст: "I use Notion for project management"
      → Введите URL или Enter для skip:

[2/4] "GitHub repo"
      Контекст: "Check out my GitHub repo"
      → Введите URL или Enter для skip:

[3/4] "Obsidian"
      Контекст: "В Obsidian это выглядит так"
      → Введите URL или Enter для skip:

[4/4] "предыдущее видео"
      Контекст: "Как я показывал в предыдущем видео"
      → Введите URL или Enter для skip:

Применено 3 ссылки, пропущена 1.
```

**Альтернативный режим (batch):**
```
Найдены ссылки. Добавить сейчас?
1. Да, по одной (интерактивно)
2. Добавлю вручную позже (placeholders)
3. Пропустить все
```

### Phase 6: Output (ASK)

1. **Показать превью:**
   ```
   === Превью ===

   # Building an AI Content Factory

   > **Summary:** Walkthrough of setting up automated content pipeline...

   ## 1. Introduction
   [First 200 chars...]

   ...

   Полный документ: 1,247 слов, 5 секций
   ```

2. **Сохранить .md:**
   ```
   Сохранить как:
   → projects/{your-project}/transcripts/2026-01-24-ai-content-factory.md

   [Enter для подтверждения / другой путь]
   ```

3. **PDF генерация:**
   ```
   Сгенерировать PDF? [y/n]

   → Да

   Генерирую PDF...
   ✅ Сохранено: 2026-01-24-ai-content-factory.pdf
   ```

---

## Confirmation Model

| Действие | Режим | Пояснение |
|----------|-------|-----------|
| Чтение файла | AUTO | Безопасно |
| Анализ контента | AUTO | Безопасно |
| Очистка от fillers | AUTO | Безопасно |
| Форматирование | AUTO | Безопасно |
| Превью | AUTO | Показать пользователю |
| Вставка ссылок | ASK | Интерактивный ввод |
| Сохранение .md | ASK | Подтверждение пути |
| Генерация PDF | ASK | Отдельное подтверждение |

---

## PDF генерация

### Основная команда (Chrome headless)

```bash
# Используем скрипт
scripts/html-to-pdf.sh "[input].html" "[output].pdf"

# Или напрямую Chrome
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless \
  --disable-gpu \
  --no-pdf-header-footer \
  --print-to-pdf="[output].pdf" \
  "file://[absolute-path-to-input].html"
```

### Workflow

1. Сгенерировать HTML из markdown (pandoc или вручную)
2. Применить брендированные стили (CSS)
3. Конвертировать в PDF через Chrome headless
4. Открыть результат

### Преимущества Chrome headless

- Сохраняет все CSS стили (включая тёмную тему)
- Работает с Google Fonts
- Не требует дополнительных установок
- Идентичный результат браузеру

---

## Выходные файлы

| Тип | Путь | Naming |
|-----|------|--------|
| Markdown | `projects/{project}/transcripts/` или `~/Documents/Transcripts/` | `YYYY-MM-DD-{slug}.md` |
| PDF | Рядом с .md | `YYYY-MM-DD-{slug}.pdf` |

**Slug генерация:**
- Извлечь заголовок из контента
- Транслитерация кириллицы
- Замена пробелов на дефисы
- Lowercase
- Обрезать до 50 символов

---

## Алгоритм работы

```python
def process_transcription(input_source):
    # Phase 1: Input
    content = read_input(input_source)
    format_type = detect_format(content)
    clean_text = extract_text(content, format_type)

    if word_count(clean_text) < 100:
        if not user_confirm("Текст короткий. Продолжить?"):
            return

    # Phase 2: Analysis
    sections = detect_sections(clean_text)
    key_points = extract_key_points(clean_text)
    link_mentions = detect_link_mentions(clean_text)
    action_items = extract_action_items(clean_text)

    # Phase 3: Cleanup
    cleaned = remove_fillers(clean_text)
    cleaned = collapse_repetitions(cleaned)
    cleaned = fix_false_starts(cleaned)

    # Phase 4: Formatting
    document = apply_template(
        cleaned, sections, key_points,
        link_mentions, action_items
    )

    # Phase 5: Link Insertion
    if link_mentions:
        document = interactive_link_insertion(document, link_mentions)

    # Phase 6: Output
    show_preview(document)

    output_path = ask_output_path()
    save_markdown(document, output_path)

    if user_confirm("Сгенерировать PDF?"):
        generate_pdf(output_path)

    return output_path
```

---

## Примеры использования

### Пример 1: Файл транскрибации

```
User: транскрипт ~/Downloads/livestream.txt

Claude: 📄 Читаю: livestream.txt
        Формат: Raw text
        Объём: 3,247 слов (~20 мин)

        🔍 Анализирую...
        ├─ 6 логических секций
        ├─ 12 ключевых моментов
        ├─ 3 примера
        └─ 5 упоминаний ссылок

        🧹 Очистка...
        ├─ Удалено 47 fillers
        ├─ Схлопнуто 8 повторений
        └─ Исправлено 3 false starts

        === Превью ===

        # Building an AI Content Factory

        > **Summary:** Подробный разбор настройки автоматизированного
        > конвейера контента с Claude Code, n8n и Notion.

        ## 1. Introduction
        ...

        Продолжить? [y/n]
```

### Пример 2: SRT субтитры

```
User: транскрипт ~/Downloads/video.srt

Claude: 📄 Читаю: video.srt
        Формат: SRT (субтитры)

        Обнаружены таймкоды. Что делать?
        1. Удалить все (чистый текст)
        2. Сохранить как маркеры секций
        3. Конвертировать в читаемый формат ("На 15-й минуте...")

User: 1

Claude: ✅ Таймкоды удалены.

        Извлечено 2,891 слово...
        [продолжает обработку]
```

### Пример 3: Быстрый режим с PDF

```
User: транскрипт + pdf ~/Downloads/workflow.txt

Claude: [обрабатывает без интерактивных вопросов про ссылки]

        ✅ Готово!

        📄 MD: ~/Documents/Transcripts/2026-01-24-workflow-demo.md
        📄 PDF: ~/Documents/Transcripts/2026-01-24-workflow-demo.pdf
```

---

## Error Handling

### Пустой/короткий файл

```
⚠️ Файл содержит только 45 слов.

Это может дать минимальный результат.

1. Продолжить (output будет коротким)
2. Отмена — добавьте больше контента
```

### Неизвестный формат

```
⚠️ Не могу определить формат файла.

Содержимое выглядит как: [первые 100 символов]

1. Обработать как plain text
2. Вставить текст вручную
3. Отмена
```

### PDF генерация не удалась

```
⚠️ Не удалось создать PDF.

Причина: wkhtmltopdf не найден

Markdown сохранён успешно:
→ ~/Documents/Transcripts/2026-01-24-demo.md

Варианты:
1. Установить wkhtmltopdf: brew install wkhtmltopdf
2. Открыть .md в Obsidian/VS Code → экспорт в PDF
3. Использовать онлайн-конвертер
```

---

## Связанные файлы

### Документация
- [[CLAUDE.md]] — Роутер (триггеры)

---

## DOES / DOES NOT

### DOES
- Парсить SRT, VTT, TXT, MD файлы
- Удалять fillers и repetitions
- Структурировать в логические секции
- Определять ключевые моменты и примеры
- Интерактивно спрашивать про ссылки
- Генерировать красивый markdown
- Экспортировать в PDF через pandoc

### DOES NOT
- Транскрибировать аудио/видео (вход должен быть текстом)
- Автоматически публиковать куда-либо
- Удалять исходные файлы
- Добавлять ссылки без подтверждения
- Изменять оригинальный файл

---

## Настройки (будущее)

```python
# Потенциальные настройки для v2.0
CONFIG = {
    'auto_detect_language': True,  # RU/EN
    'keep_timestamps': False,       # Сохранять таймкоды
    'filler_words': {
        'en': ['uh', 'um', 'like', 'you know'],
        'ru': ['эм', 'ну', 'типа', 'короче']
    },
    'min_word_count': 100,
    'default_output_dir': '~/Documents/Transcripts/',
    'pdf_engine': 'wkhtmltopdf'
}
```

---

*Создано: 2026-01-24*
*Версия: 1.0*
*Статус: Draft — готов к тестированию*
