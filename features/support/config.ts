// Carrega o .env se existir; variáveis da linha de comando têm prioridade
try {
  process.loadEnvFile();
} catch {}

export const BASE_URL =
  process.env.BASE_URL ?? 'https://verzel-store.qa-test-verzel-store.workers.dev';

export const HEADLESS = process.env.HEADED !== '1';
export const SLOW_MO = Number(process.env.SLOW_MO ?? 0);
export const TIMEOUT = 30_000;
