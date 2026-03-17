---
name: nano-banana
description: "Генерация изображений через Nano Banana (LaoZhang API / Gemini 3 Pro Image) — от простых картинок до фотореалистичных портретов и персонажей. $ARGUMENTS = описание желаемого изображения."
---

# Nano Banana — AI Генерация Изображений

Мастер-система для создания изображений через LaoZhang API (Gemini 3 Pro Image): от простых картинок до фотореалистичных портретов и постоянных персонажей.

**Движок:** Gemini 3 Pro Image через LaoZhang API  
**Принцип:** Специфика побеждает неопределённость. Описание сцены > список ключевых слов.

## Быстрый старт

```bash
# Простое изображение
"Создай картинку: предприниматель в офисе"

# Реалистичный портрет
"Создай фотореалистичный портрет 25-летней девушки"

# Face swap с референсом
"Замени лицо на моё" + [прикрепить фото]
```

**Философия:** Один раз зафиксировать → Бесконечно использовать

## API — LaoZhang + Gemini 3 Pro Image

### Endpoint
```
POST https://api.laozhang.ai/v1beta/models/gemini-3-pro-image-preview:generateContent
Authorization: Bearer $API_KEY
```

### Параметры изображения

| Параметр | Значения | Описание |
|----------|----------|----------|
| `aspectRatio` | `"1:1"`, `"3:4"`, `"4:3"`, `"9:16"`, `"16:9"` | Соотношение сторон |
| `imageSize` | `"1K"`, `"2K"`, `"4K"` | Разрешение (4K = лучшее) |
| `responseModalities` | `["IMAGE"]` | Тип ответа |

### Разрешения по формату

| Формат | 4K разрешение | Когда использовать |
|--------|---------------|-------------------|
| 16:9 | 5504×3072 | Баннеры, YouTube обложки |
| 3:4 | 2880×3840 | Портреты, карусели |
| 9:16 | 3072×5504 | Stories, Reels обложки |
| 1:1 | 4096×4096 | Instagram посты, аватары |
| 4:3 | 3840×2880 | Горизонтальные фото |

### Минимальный запрос

```bash
curl -X POST "https://api.laozhang.ai/v1beta/models/gemini-3-pro-image-preview:generateContent" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts": [{"text": "ПРОМПТ"}]}],
    "generationConfig": {
      "responseModalities": ["IMAGE"],
      "imageConfig": {
        "aspectRatio": "16:9",
        "imageSize": "4K"
      }
    }
  }'
```

### С референсным изображением

```json
{
  "contents": [{
    "parts": [
      {
        "inline_data": {
          "mime_type": "image/png",
          "data": "BASE64_ENCODED_IMAGE"
        }
      },
      {"text": "ПРОМПТ с [image1] референсом"}
    ]
  }],
  "generationConfig": {
    "responseModalities": ["IMAGE"],
    "imageConfig": {
      "aspectRatio": "3:4",
      "imageSize": "4K"
    }
  }
}
```

### Таймауты и лимиты

| Размер | Время генерации | Рекомендуемый таймаут |
|--------|-----------------|----------------------|
| 2K | 25-45 сек | 120 сек |
| 4K | 40-70 сек | 180 сек |

⚠️ НЕ убивать процесс раньше 180 секунд!

## Примеры использования

### Фотореалистичный портрет
```
Создай портрет 32-летней женщины, натуральная текстура кожи с видимыми порами,
снято на 85mm f/1.8 с освещением Рембрандта
```

### Face Swap
```
Замени мужчину с [Image1] на человека с [Image2], сохранив черты лица и стиль оригинала
```

### UGC-контент
```
Создай девушку 23 лет для UGC, снимает видео на телефон в кафе, естественное освещение
```

### Обложка YouTube
```
Создай яркую обложку в стиле МрБиста с удивлённым лицом и жёлтыми стрелками
```

## Workflow

### 1. Базовая генерация
- Промпт — описательный абзац (не список слов)
- Указание камеры и объектива для реализма
- Детали освещения и композиции
- Формат и разрешение через API параметры

### 2. Face Swap / Identity Kit
- Референсное фото через inline_data (base64)
- Точное указание что заменить
- Identity Lock блок для сохранения лица
- Сохранение оригинальной атмосферы

### 3. Создание персонажа (Identity Kit)
- Фиксация внешности в референсах
- Создание набора поз и ракурсов
- Использование для всех последующих генераций
- Подробнее → `nano-banana-identity-kit.md`

### 4. Пост-продакшн
- Upscaling — запрос с imageSize "4K"
- Редактирование — отправить изображение + промпт с изменениями
- Мульти-image композиция — несколько inline_data в одном запросе

## Файлы

| Файл | Содержание |
|------|-----------|
| `nano-banana-examples.md` | Примеры трансформации идей в промпты |
| `nano-banana-realism.md` | Техники фотореализма |
| `nano-banana-identity-kit.md` | Создание постоянных персонажей |
| `nano-banana-thumbnails.md` | Обложки в стиле YouTube |
| `nano-banana-ideas.md` | Креативные идеи и концепты |
| `nano-banana-vocabulary.md` | Словарь терминов и техник |

## Частые ошибки

❌ **Список ключевых слов** — "woman, portrait, realistic"  
❌ **Слишком общие описания** — "красивая девушка"  
❌ **Игнорирование освещения** — свет решает всё  
❌ **Без указания камеры** — для реализма нужны технические детали  
❌ **Размытое лицо при face swap** — нужен качественный референс  
❌ **Plastic skin эффект** — добавить поры и несовершенства  
❌ **Inconsistent персонаж** — не используется Identity Kit  
❌ **Таймаут < 120 сек** — генерация 4K занимает до 70 секунд  
❌ **Без imageConfig** — изображение будет низкого качества

## Техника трёхслойного реализма

**Layer 1: Камера и объектив**
```
"Shot on Sony A7R IV with 85mm f/1.4 lens, 1/250 shutter, ISO 400"
```

**Layer 2: Освещение и композиция**
```
"Rembrandt lighting, shallow depth of field, soft natural light from window"
```

**Layer 3: Детали и несовершенства**
```
"Natural skin texture with visible pores, fine lines, no airbrushing, unretouched look"
```

## Face Swap формула

```
Replace [КОГО] from [Image1] with [КОГО] from [Image2].
Preserve facial features, body type, and clothing so they look like themselves.
They should organically fit into the atmosphere of [Image1].
```

## Identity Kit процесс

1. **Концепция** — возраст, этничность, стиль
2. **Референсы** — 3-5 фото разных ракурсов (4K, f/8, всё в фокусе)
3. **Тестирование** — проверка консистентности
4. **Использование** — промпты с референсом через inline_data

### Identity Lock блок (вставлять в промпт)

```
IDENTITY LOCK for person from [Image1]:
- Preserve EXACT facial features: bone structure, nose shape, eye spacing, jawline
- Preserve EXACT skin tone, texture, pores, and blemishes
- Preserve EXACT hairstyle, hair color, and hairline
- NO beautification, NO smoothing, NO idealization
- NO age change, NO ethnicity drift, NO face morphing
- The person MUST be 100% recognizable as the same individual
```

## UGC-модели (E-модели)

**Критерии качественной UGC-модели:**
- Возраст 20-28 лет
- Естественная внешность (не модельная)
- Дружелюбное выражение лица
- Релевантная одежда для ниши
- Естественное освещение
- Believable ситуация

**Применение:** реклама, тестимониалы, демонстрация товаров, создание доверия.

## Технические хаки

| Проблема | Решение |
|----------|---------|
| Размытое лицо | `sharp focus, high detail, 85mm lens` |
| Plastic skin | `visible pores, natural skin texture, unretouched` |
| Плохое освещение | Указать тип: `Rembrandt`, `golden hour`, `soft window light` |
| Неестественная поза | `candid moment, natural expression, relaxed pose` |
| Низкое качество | imageSize: "4K", камера в промпте |
| Руки размыты | Использовать f/5.6-f/8 в промпте |
| Лицо "плывёт" | Усилить Identity Lock + больше референсов |
| Rate limit (429) | Подождать 30 сек |
| Таймаут | Увеличить до 180+ сек |

## Identity Kit пути (проекты)

| Проект | Путь к аватарам |
|--------|-----------------|
| **Макс Галсон** | `~/openclaw-ai/{project}/avatars/max/` |
| **Dr. Stoyanov** | `~/openclaw-ai/projects/36hour/avatars/stoyanov/` |

## Python Template

```python
import base64, json, requests

def generate_image(prompt, references=None, aspect_ratio="16:9", size="4K", api_key=None):
    url = "https://api.laozhang.ai/v1beta/models/gemini-3-pro-image-preview:generateContent"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}

    parts = []
    if references:
        for ref_path in references:
            with open(ref_path, "rb") as f:
                b64 = base64.b64encode(f.read()).decode()
            parts.append({"inline_data": {"mime_type": "image/png", "data": b64}})
    parts.append({"text": prompt})

    payload = {
        "contents": [{"parts": parts}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {"aspectRatio": aspect_ratio, "imageSize": size}
        }
    }

    resp = requests.post(url, headers=headers, json=payload, timeout=180)
    resp.raise_for_status()
    data = resp.json()

    # Extract base64 image from response
    for part in data.get("candidates", [{}])[0].get("content", {}).get("parts", []):
        if "inline_data" in part:
            return base64.b64decode(part["inline_data"]["data"])
    return None
```

## Bash Quick Commands

```bash
# Простая генерация (нужен скрипт laozhang-image.sh)
./laozhang-image.sh "промпт" --pro --ratio 16:9 --4k --output result.png

# С референсом
./laozhang-image.sh "промпт с [image1]" --ref reference.png --pro --4k
```
