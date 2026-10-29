import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['src/**/*.test.ts', 'worker/**/*.test.ts'],
  },
  resolve: {
    alias: { '@': new URL('./src/', import.meta.url).pathname },
  },
});
