export const defaultLocale = "en" as const;
export const supportedLocales = ["en", "de", "es", "zh"] as const;
export type Locale = (typeof supportedLocales)[number];

export const localeNames: Record<Locale, string> = {
  en: "English",
  de: "Deutsch",
  es: "Español",
  zh: "中文",
};
