# Фабрика Контента

AI-система для создания контента в твоём голосе. Работает с Claude Code.

Посты, сценарии, карусели, Reels, YouTube — всё через проверенные методики.

---

## Быстрый старт

### 1. Установи Claude Code

```bash
npm i -g @anthropic-ai/claude-code
```

### 2. Клонируй репо

```bash
git clone https://github.com/maximgalson/content-factory.git
cd content-factory
```

### 3. Запусти

```bash
claude
```

Скажи "привет" — система проведёт онбординг за 5 минут.

---

## Что внутри

### 29 скиллов

| Категория | Скиллы |
|-----------|--------|
| **Форматы** | Telegram, YouTube, Reels, Carousel, SEO Blog |
| **Копирайтинг** | Storytelling, Copywriting, Editing, Headlines, Selling Meanings |
| **Стратегия** | Personal Unpacking, Customer Research, Content Repurposer, Audience Lens |
| **Генерация** | Nano Banana (картинки), HeyGen (аватары), Veo (видео), Timelapse |
| **Система** | Memory System, Prompt Engineer, Agent Architect, Skill Creator, SwipeFile |

### Структура проекта

```
content-factory/
├── .claude/skills/     ← 29 скиллов (подхватываются автоматически)
├── CLAUDE.md           ← инструкции для Claude
├── agents/             ← роли и специализации
├── brand/              ← твой профиль, стиль, примеры
├── docs/               ← справочные материалы
├── learning/           ← система обучения
└── projects/           ← рабочие проекты
```

### Как работает

1. **Онбординг** — 3 вопроса, и система знает твой стиль
2. **Скиллы** — говоришь "напиши пост для Telegram" → активируется нужный скилл
3. **Обучение** — система запоминает твой голос и становится точнее

---

## OpenClaw версия

Полная система с несколькими агентами, Telegram-ботами и памятью между сессиями:

```bash
curl -sSL https://bot.galson.pro/install | bash
```

Токен получишь в [@galsonproAIbot](https://t.me/galsonproAIbot).

---

## Поддержка

- Бот: [@galsonproAIbot](https://t.me/galsonproAIbot?start=support)
- Канал: [@galsonproai](https://t.me/galsonproai)
- Сайт: [galson.pro](https://galson.pro)

---

*Фабрика Контента v2.3 — Макс Галсон • [galson.pro](https://galson.pro)*
