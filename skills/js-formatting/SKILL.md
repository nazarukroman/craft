---
name: js-formatting
description: Канонический формат и тулинг для личных JS/TS-проектов — oxfmt + oxlint, точки с запятой, одинарные кавычки, ширина 120. Использовать при создании нового JS/TS-проекта, при настройке форматтера или линтера, при спорах о стиле, и при миграции существующего проекта на общий формат.
---

# Формат JS/TS-проектов

Единый формат для всех личных JS/TS-проектов.

**Форматтер — `oxfmt`, линтер — `oxlint`** (оба из oxc). Prettier и ESLint считаются
легаси: вся реальная работа идёт через oxc. Не тащите Prettier в новый проект.

## Настройки, которые нельзя менять по вкусу

| Параметр | Значение | Замечание |
| --- | --- | --- |
| Точки с запятой | **есть** | Дефолт `semi: true`. **Не выключать.** Самая частая ошибка при копировании чужого конфига |
| Кавычки | одинарные | `singleQuote: true` |
| Висячая запятая | везде | `trailingComma: 'all'` |
| Ширина строки | 120 | Не 80 и не 100 |
| Отступ | 2 пробела | `useTabs: false` |
| Конец строки | LF | |
| Финальный перевод строки | есть | |

Точки с запятой — не вкусовщина, а то, чем этот формат отличается от дефолта многих
стартеров. Если в проекте их нет, проект не соответствует правилу.

## Файлы конфигурации

### `.oxfmtrc.json`

```json
{
  "$schema": "./node_modules/oxfmt/configuration_schema.json",
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 120,
  "tabWidth": 2,
  "useTabs": false,
  "sortPackageJson": false,
  "ignorePatterns": [
    "**/node_modules/**",
    "**/build/**",
    "**/dist/**",
    "**/coverage/**",
    "**/*.min.js",
    "**/*.d.ts"
  ]
}
```

`semi` не указан намеренно — дефолт `true` и есть то, что нужно.

### `.oxlintrc.json`

Строгость точечная: падаем только на `correctness`, остальные категории выключены.
Линтер ловит ошибки, а не воспитывает.

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "ignorePatterns": ["**/node_modules/**", "**/dist/**", "**/build/**", "**/*.d.ts", "**/*.min.js"],
  "plugins": ["typescript", "import", "oxc"],
  "categories": {
    "correctness": "error",
    "perf": "off",
    "suspicious": "off",
    "pedantic": "off",
    "style": "off",
    "restriction": "off"
  },
  "rules": {
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": "off",
    "no-console": "off",
    "no-debugger": "error"
  }
}
```

Для React добавить в `plugins`: `"react"`, `"react-hooks"`, и в `rules`:
`"react/react-in-jsx-scope": "off"`, `"react/jsx-key": "error"`,
`"react-hooks/rules-of-hooks": "error"`.

Неиспользуемые переменные выключены намеренно — их ловит `tsc`, а дублирующая
диагностика только шумит.

### `.editorconfig`

```ini
# editorconfig.org

root = true

[*]
charset = utf-8
indent_style = space
indent_size = 2
tab_width = 2
end_of_line = lf
max_line_length = 120
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false
```

`*.md` исключён из обрезки пробелов: два пробела в конце строки — это перенос
в Markdown, и обрезка молча ломает вёрстку.

### `.npmrc`

```ini
save-exact=true
auto-install-peers=true
strict-peer-dependencies=false
prefer-frozen-lockfile=true
```

`save-exact=true` обязателен: диапазоны версий превращают лок-файл в
рекомендацию, а сборку — в лотерею.

### `.lintstagedrc.js` + husky

```js
module.exports = {
  '*.{ts,tsx}': ['oxfmt', 'oxlint --fix'],
  '*.css': ['oxfmt', 'stylelint --fix'],
  'package.json': ['oxfmt', 'sort-package-json'],
  '*.{js,jsx,json,md,mjs,cjs}': ['oxfmt'],
};
```

Порядок важен: сначала `oxfmt`, потом `oxlint --fix`. Наоборот линтер будет
чинить то, что форматтер тут же перепишет.

### `package.json`

```json
{
  "scripts": {
    "format": "oxfmt",
    "format:check": "oxfmt --check",
    "lint": "oxlint",
    "typecheck": "tsc --noEmit"
  }
}
```

Менеджер пакетов — `pnpm`, версия пинуется полем `packageManager`. Версия Node
живёт в `.nvmrc`.

## Идиоматика

### Импорты — три группы, разделённые пустой строкой

```ts
import { z } from 'zod';

import { createUser } from '@server/users/create-user';
import { API_URL } from '@shared/config/api';

import type { User } from '@shared/types/user';
```

1. Внешние пакеты.
2. Внутренние по алиасам (`@shared/…`, `@server/…`).
3. **`import type` — последней группой.** Не вперемешку со значениями.

### Прочее

- Верхнеуровневая функция — `export function name() {}`, а не `const name = () => {}`.
  Стрелки — для колбэков и инлайна.
- Скобки вокруг единственного аргумента стрелки: `(c) => c.name`.
- `SCREAMING_SNAKE_CASE` — для настоящих констант-литералов (`API_URL`,
  `MAX_RETRIES`). `camelCase` — для всего вычисляемого, даже на уровне модуля.
- Комментарии объясняют **почему**, а не что. `// the crash reporter works only in
  the browser` полезен, `// set the variable` — мусор.
- Язык комментариев — по проекту, не по этому правилу. В одних проектах JSDoc
  на русском, в `homelab` всё на английском. Следуйте окружающему коду.

## TypeScript

Строгий режим не обсуждается:

```json
{
  "strict": true,
  "noUncheckedIndexedAccess": true,
  "noImplicitOverride": true,
  "noFallthroughCasesInSwitch": true
}
```

## Миграция существующего проекта

Проекты, которые пока **не** соответствуют правилу: `letters`, `verstak`,
`homelab/docs/generators` (там код без точек с запятой и в двойных кавычках).

Порядок, который не превращает историю в кашу:

1. Поставить тулинг: `pnpm add -D oxfmt oxlint`, снести `prettier`, `eslint`
   и их плагины, если они больше ничего не держат.
2. Положить конфиги из этого документа.
3. **Отдельным коммитом, который больше ничего не делает**, прогнать `oxfmt`
   по всему дереву. Смешивать переформатирование с правкой логики нельзя:
   ревью такого диффа невозможно.
4. Занести хеш этого коммита в `.git-blame-ignore-revs`, чтобы `git blame`
   не упирался в него:
   ```
   # Переход на общий формат (oxfmt)
   <хеш коммита>
   ```
   и включить: `git config blame.ignoreRevsFile .git-blame-ignore-revs`.
5. Прогнать `pnpm typecheck` и тесты — форматтер не меняет семантику, но
   пере­нос строк умеет вскрывать уже сломанное.
6. Повесить `lint-staged` через husky, чтобы расхождение не вернулось.

Шаг 3 и шаг 4 идут парой. Без `.git-blame-ignore-revs` каждый `git blame`
после миграции будет показывать один и тот же коммит-переформатирование
вместо автора строки.
