const comum = {
  paths: ['features/**/*.feature'],
  import: ['features/support/**/*.ts', 'features/step_definitions/**/*.ts'],
  language: 'pt',
  tags: 'not @manual',
  format: [
    'progress-bar',
    'html:reports/cucumber-report.html',
    'json:reports/cucumber-report.json',
  ],
  formatOptions: { snippetInterface: 'async-await' },
};

export default comum;

export const ui = { ...comum, tags: '@ui and not @manual' };
export const api = { ...comum, tags: '@api and not @manual' };
// Só o que deveria passar: útil para checar regressão sem o ruído dos bugs conhecidos
export const semBugs = { ...comum, tags: 'not @manual and not @bug' };
